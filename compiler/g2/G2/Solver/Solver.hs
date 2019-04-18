{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TupleSections #-}

module G2.Solver.Solver ( Solver (..)
                        , TrSolver (..)
                        , Tr (..)
                        , SomeSolver (..)
                        , SomeTrSolver (..)
                        , Result (..)
                        , GroupRelated (..)
                        , CombineSolvers (..)) where

import G2.Language
import qualified G2.Language.PathConds as PC
import qualified Data.Map as M

-- | The result of a Solver query
data Result = SAT
            | UNSAT
            | Unknown String
            deriving (Show, Eq)

-- | Defines an interface to interact with Solvers
class Solver solver where
    -- | Checks if the given `PathConds` are satisfiable.
    check :: forall t . solver -> State t -> PathConds -> IO Result
    
    -- | Checks if the given `PathConds` are satisfiable, and, if yes, gives a `Model`
    -- The model must contain, at a minimum, a value for each passed `Id`
    solve :: forall t . solver -> State t -> [Id] -> PathConds -> IO (Result, Maybe Model)

    -- | Cleans up when the solver is no longer needed.  Default implementation
    -- does nothing
    close :: solver -> IO ()
    close _ = return ()

-- | Defines an interface to interact with Tracking Solvers-
-- solvers that can track some sort of state.
-- Every solver is also a tracking solver, so this is the more general type.
-- Typically, all functions should be written using TrSolver, rather than Solver.
class TrSolver solver where
    -- | Checks if the given `PathConds` are satisfiable.
    -- Allows modifying the solver, to track some state.
    checkTr :: forall t . solver -> State t -> PathConds -> IO (Result, solver)
    
    -- | Checks if the given `PathConds` are satisfiable, and, if yes, gives a `Model`
    -- The model must contain, at a minimum, a value for each passed `Id`
    -- Allows modifying the solver, to track some state.
    solveTr :: forall t . solver -> State t -> [Id] -> PathConds -> IO (Result, Maybe Model, solver)

    -- | Cleans up when the solver is no longer needed.  Default implementation
    -- does nothing
    closeTr :: solver -> IO ()
    closeTr _ = return ()

-- | A wrapper to turn something that is a Solver into a TrSolver
newtype Tr solver = Tr { unTr :: solver }

instance Solver solver => TrSolver (Tr solver) where
    checkTr (Tr sol) s pc = return . (, Tr sol) =<< check sol s pc
    solveTr (Tr sol) s is pc = return . (\(r, m) -> (r, m, Tr sol)) =<< solve sol s is pc
    closeTr = close . unTr

data SomeSolver where
    SomeSolver :: forall solver
                . Solver solver => solver -> SomeSolver

data SomeTrSolver where
    SomeTrSolver :: forall solver
                  . TrSolver solver => solver -> SomeTrSolver

-- | Splits path constraints before sending them to the rest of the solvers
data GroupRelated a = GroupRelated a

checkRelated :: TrSolver a => a -> State t -> PathConds -> IO (Result, a)
checkRelated solver s pc =
    checkRelated' solver s $ PC.relatedSets (known_values s) pc

checkRelated' :: TrSolver a => a -> State t -> [PathConds] -> IO (Result, a)
checkRelated' sol _ [] = return (SAT, sol)
checkRelated' sol s (p:ps) = do
    (c, sol') <- checkTr sol s p
    case c of
        SAT -> checkRelated' sol' s ps
        r -> return (r, sol')

solveRelated :: TrSolver a => a -> State t -> [Id] -> PathConds -> IO (Result, Maybe Model, a)
solveRelated sol s is pc = do
    solveRelated' sol s M.empty is $ PC.relatedSets (known_values s) pc

solveRelated' :: TrSolver a => a -> State t -> Model -> [Id] -> [PathConds] -> IO (Result, Maybe Model, a)
solveRelated' sol s m is [] =
    let 
        is' = filter (\i -> idName i `M.notMember` m) is
        nv = map (\(Id n t) -> (n, fst $ arbValue t (type_env s) (arb_value_gen s))) is'
        m' = foldr (\(n, v) -> M.insert n v) m nv
    in
    return (SAT, Just m', sol)
solveRelated' sol s m is (p:ps) = do
    let is' = concat $ PC.map (PC.varIdsInPC (known_values s)) p
    let is'' = ids p
    rm <- solveTr sol s is' p
    case rm of
        (SAT, Just m', sol') -> solveRelated' sol' s (M.union m m') (is ++ is'') ps
        rm' -> return rm'

instance Solver solver => Solver (GroupRelated solver) where
    check (GroupRelated sol) s pc = return . fst =<< checkRelated (Tr sol) s pc
    solve (GroupRelated sol) s is pc =
        return . (\(r, m, _) -> (r, m)) =<< solveRelated (Tr sol) s is pc
    close (GroupRelated s) = close s

instance TrSolver solver => TrSolver (GroupRelated solver) where
    checkTr (GroupRelated sol) s pc = do
        (r, sol') <- checkRelated sol s pc
        return (r, GroupRelated sol')
    solveTr (GroupRelated sol) s is pc = do
        (r, m, sol') <- solveRelated sol s is pc
        return (r, m, GroupRelated sol')
    closeTr (GroupRelated s) = closeTr s

-- | Allows solvers to be combined, to exploit different solvers abilities
-- to solve different kinds of constraints
data CombineSolvers a b = a :<? b -- ^ a :<? b - Try solver b.  If it returns Unknown, try solver a
                        | a :?> b -- ^ a :>? b - Try solver a.  If it returns Unknown, try solver b

checkWithEither :: (TrSolver a, TrSolver b) => a -> b -> State t -> PathConds -> IO (Result, CombineSolvers a b)
checkWithEither a b s pc = do
    (ra, a') <- checkTr a s pc 
    case ra of
        SAT -> return (SAT, a' :?> b)
        UNSAT -> return (UNSAT, a' :?> b)
        Unknown ua -> do
            (rb, b') <- checkTr b s pc
            case rb of
                Unknown ub -> return $ (Unknown $ ua ++ ",\n" ++ ub, a' :?> b')
                rb' -> return (rb', a' :?> b')

solveWithEither :: (TrSolver a, TrSolver b) => a -> b -> State t -> [Id] -> PathConds -> IO (Result, Maybe Model, CombineSolvers a b)
solveWithEither a b s is pc = do
    ra <- solveTr a s is pc 
    case ra of
        (SAT, m, a') -> return (SAT, m, a' :?> b)
        (UNSAT, m, a') -> return (UNSAT, m, a' :?> b)
        (Unknown ua, _, a') -> do
            rb <- solveTr b s is pc
            case rb of
                (Unknown ub, _, b') -> return $ (Unknown $ ua ++ ",\n" ++ ub, Nothing, a' :?> b')
                (r, m, b') -> return (r, m, a' :?> b')

instance (Solver a, Solver b) => Solver (CombineSolvers a b) where
    check (a :<? b) s pc = return . fst =<< checkWithEither (Tr b) (Tr a) s pc
    check (a :?> b) s pc = return . fst =<< checkWithEither (Tr a) (Tr b) s pc

    solve (a :<? b) s is pc =
        return . (\(r, m, _) -> (r, m)) =<< solveWithEither (Tr b) (Tr a) s is pc
    solve (a :?> b) s is pc =
        return . (\(r, m, _) -> (r, m)) =<< solveWithEither (Tr a) (Tr b) s is pc

    close (a :<? b) = do
        close a
        close b
    close (a :?> b) = do
        close a
        close b

instance (TrSolver a, TrSolver b) => TrSolver (CombineSolvers a b) where
    checkTr (a :<? b) s pc = do
        (r, sol') <- checkWithEither b a s pc
        case sol' of
            b' :?> a' -> return (r, a' :<? b')
            b' :<? a' -> return (r, a' :?> b')
    checkTr (a :?> b) s pc = checkWithEither a b s pc

    solveTr (a :<? b) s is pc = do
        (r, m, sol') <- solveWithEither b a s is pc
        case sol' of
            b' :?> a' -> return (r, m, a' :<? b')
            b' :<? a' -> return (r, m, a' :?> b')
    solveTr (a :?> b) s is pc = solveWithEither a b s is pc

    closeTr (a :<? b) = do
        closeTr a
        closeTr b
    closeTr (a :?> b) = do
        closeTr a
        closeTr b
