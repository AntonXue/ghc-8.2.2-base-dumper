{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE OverloadedStrings #-}

module G2.Liquid.Conversion ( LHDictMap
                                       , DictMaps (..)
                                       , BoundTypes
                                       , mergeLHSpecState
                                       , convertSpecType
                                       , dictMapFromIds
                                       , convertLHExpr
                                       , specTypeToType
                                       , unsafeSpecTypeToType
                                       , symbolName
                                       , lhTCDict') where

import G2.Language
import qualified G2.Language.KnownValues as KV
import G2.Language.Monad
import qualified G2.Language.ExprEnv as E
import G2.Liquid.Types
import G2.Translation.Haskell

import qualified Var as Var

import Language.Fixpoint.Types.Names
import Language.Fixpoint.Types.Sorts
import qualified Language.Fixpoint.Types.Refinements as Ref
import Language.Fixpoint.Types.Refinements hiding (Expr, I)
import Language.Haskell.Liquid.Types

import Data.Coerce
import Data.Foldable
import qualified Data.HashMap.Lazy as HM
import qualified Data.Map as M
import Data.Maybe
import qualified Data.Text as T

-- | A mapping of TyVar Name's, to Id's for the LH dict's
type LHDictMap = M.Map Name Id

-- | A mapping of TyVar Name's, to Id's for the Num dict's
type NumDictMap = M.Map Name Id

-- | A mapping of TyVar Name's, to Id's for the Integral dict's
type IntegralDictMap = M.Map Name Id

-- | A mapping of TyVar Name's, to Id's for the Ord dict's
type OrdDictMap = M.Map Name Id

-- | A collection of all DictMaps required to convert LH refinement types to G2 `Expr`@s@
data DictMaps = DictMaps { lh_dicts :: LHDictMap
                         , num_dicts :: NumDictMap
                         , integral_dicts :: IntegralDictMap
                         , ord_dicts :: OrdDictMap } deriving (Eq, Show, Read)

copyIds :: Name -> Name -> DictMaps -> DictMaps
copyIds n1 n2 dm@(DictMaps { lh_dicts = lhd, num_dicts = nd, integral_dicts = ind, ord_dicts = od }) =
    let
        dm2 = case M.lookup n1 lhd of
                Just lh -> dm { lh_dicts = M.insert n2 lh lhd }
                Nothing -> dm

        dm3 = case M.lookup n1 nd of
                Just num -> dm2 { num_dicts = M.insert n2 num nd }
                Nothing -> dm2

        dm4 = case M.lookup n1 ind of
                Just int -> dm3 { integral_dicts = M.insert n2 int ind }
                Nothing -> dm3

        dm5 = case M.lookup n1 od of
                Just ord -> dm4 { ord_dicts = M.insert n2 ord od }
                Nothing -> dm4
    in
    dm5

-- | A mapping of variable names to the corresponding types
type BoundTypes = M.Map Name Type

mergeLHSpecState :: [(Var.Var, LocSpecType)] -> LHStateM ()
mergeLHSpecState = mapM_ (uncurry mergeLHSpecState')

mergeLHSpecState' :: Var.Var -> LocSpecType -> LHStateM ()
mergeLHSpecState' v lst = do
    eenv <- exprEnv
    let
        (Id (Name n m _ _) _) = mkIdUnsafe v
        g2N = E.lookupNameMod n m eenv

    case g2N of
        Just (n', e) -> do
            case convertVar n' of
                True -> do
                    e' <- mergeSpecType (val lst) n' e
                    insertE n' e'

                    assumpt <- createAssumption (val lst) e
                    insertAssumptionM n' assumpt
                False -> return ()
        Nothing -> return ()

convertVar :: Name -> Bool
convertVar (Name "error" _ _ _) = False
convertVar (Name "patError" _ _ _) = False
convertVar (Name "." _ _ _) = False
convertVar _ = True

mergeSpecType :: SpecType -> Name -> Expr -> LHStateM Expr
mergeSpecType st fn e = do
    lh <- lhTCM

    -- Create new bindings to use in the Ref. Type
    let argT = spArgumentTypes e
    is <- mapM argsFromArgT argT
    let lu = map argTypeToLamUse argT

    -- Gather up LH TC's to use in Assertion
    dm@(DictMaps {lh_dicts = lhm}) <- dictMapFromIds is

    let e' = foldl' (\e_ -> App e_ . Var) e is

    -- Create a variable for the returned value
    -- We do not pass the LH TC to the assertion, since there is no matching
    -- lambda for it in the LH Spec
    r <- freshIdN (typeOf e')
    let is' = filter (not . isTC lh . typeOf) is
    assert <- convertAssertSpecType dm (M.map typeOf lhm) is' r st

    let fc = FuncCall { funcName = fn 
                      , arguments = map Var is
                      , returns = Var r }
    let rLet = Let [(r, e')] $ Assert (Just fc) assert (Var r)
    
    let e''' = foldr (uncurry Lam) rLet $ zip lu is

    return e'''

createAssumption :: SpecType -> Expr -> LHStateM Expr
createAssumption st e = do
    lh <- lhTCM

    -- Create new bindings to use in the Ref. Type
    let argT = spArgumentTypes e
    is <- mapM argsFromArgT argT
    let lu = map argTypeToLamUse argT

    let is' = filter (not . isTC lh . typeOf) is
    dm@(DictMaps {lh_dicts = lhm}) <- dictMapFromIds is

    assume <- convertAssumeSpecType dm (M.map typeOf lhm) is' st

    return . foldr (uncurry Lam) assume $ zip lu is


dictMapFromIds :: [Id] -> LHStateM DictMaps
dictMapFromIds is = do
    lh <- lhTCM
    num <- numTCM
    int <- return . KV.integralTC =<< knownValues
    ord <- ordTCM

    let lhm = tcWithNameMap lh is
    let nm = tcWithNameMap num is
    let im = tcWithNameMap int is
    let om = tcWithNameMap ord is

    return $ DictMaps { lh_dicts = lhm
                      , num_dicts = nm
                      , integral_dicts = im
                      , ord_dicts = om }

tcWithNameMap :: Name -> [Id] -> M.Map Name Id
tcWithNameMap n =
    M.fromList
        . map (\i -> (forType $ typeOf i, i))
        . filter (isTC n . typeOf)
    where
        forType :: Type -> Name
        forType (TyApp _ (TyVar (Id n' _))) = n'
        forType _ = error "Bad type in forType"

isTC :: Name -> Type -> Bool
isTC n t = case tyAppCenter t of
                TyCon n' _ -> n == n'
                _ -> False

argsFromArgT :: ArgType -> LHStateM Id
argsFromArgT (AnonType t) = freshIdN t
argsFromArgT (NamedType i) = return i

convertAssumeSpecType :: DictMaps -> BoundTypes -> [Id] -> SpecType -> LHStateM Expr
convertAssumeSpecType m bt is st = do
    convertSpecType m bt is Nothing st

convertAssertSpecType :: DictMaps -> BoundTypes -> [Id] -> Id -> SpecType -> LHStateM Expr
convertAssertSpecType m bt is r st = do
    convertSpecType m bt is (Just r) st


-- | See also: convertAssumeSpecType, convertAssertSpecType
-- We can Maybe pass an Id for the value returned by the function
-- If we do, our Expr includes the Refinement on the return value,
-- otherwise it does not.  This allows us to use this same function to
-- translate both for assumptions and assertions
convertSpecType :: DictMaps -> BoundTypes -> [Id] -> Maybe Id -> SpecType -> LHStateM Expr
convertSpecType m bt _ r (RVar {rt_var = (RTV v), rt_reft = ref})
    | Just r' <- r = do
        let symb = reftSymbol $ ur_reft ref
        let i = mkIdUnsafe v

        let symbId = convertSymbolT symb (TyVar i)

        let bt' = M.insert (idName symbId) (typeOf symbId) bt

        re <- convertLHExpr m bt' Nothing (reftExpr $ ur_reft ref)

        return $ App (Lam TermL symbId re) (Var r')
    | otherwise = mkTrueE
convertSpecType m bt (i:is) r (RFun {rt_bind = b, rt_in = fin, rt_out = fout }) = do
    t <- unsafeSpecTypeToType fin
    let i' = convertSymbolT b t

    let bt' = M.insert (idName i') t bt

    e <- convertSpecType m bt' is r fout

    case hasFuncType i of
        True -> return $ App (Lam TermL i' e) (Var i)
        False -> do
            e' <- convertSpecType m bt' [] (Just i') fin
            an <- lhAndE
            let e'' = App (App an e) e'
            
            return $ App (Lam TermL i' e'') (Var i)
convertSpecType m bt (i:is) r (RAllT {rt_tvbind = RTVar (RTV v) _, rt_ty = rty}) = do
    let i' = mkIdUnsafe v


    let m' = copyIds (idName i) (idName i') m
    let bt' = M.insert (idName i') (typeOf i) bt

    e <- convertSpecType m' bt' is r rty
    return $ App (Lam TypeL i' e) (Var i)
convertSpecType m bt _ r (RApp {rt_tycon = c, rt_reft = ref, rt_args = as})
    | Just r' <- r = do
        let symb = reftSymbol $ ur_reft ref
        ty <- return . maybe (error "Error in convertSpecType") id =<< rTyConType c as
        let i = convertSymbolT symb ty

        let bt' = M.insert (idName i) ty bt

        argsPred <- polyPredFunc as ty m bt' r'
        re <- convertLHExpr m bt' Nothing (reftExpr $ ur_reft ref)

        an <- lhAndE

        return $ App (App an (App (Lam TermL i re) (Var r'))) argsPred
    | otherwise = mkTrueE
convertSpecType _ _ _ _ (RAppTy { }) = mkTrueE
    -- | Just  <- r = mkTrueE
        -- t <- unsafeSpecTypeToType st
        -- argsPred <- polyPredFunc2 [res] t m bt r'
        -- return argsPred
    -- | otherwise = mkTrueE
convertSpecType _ _ _ _ st@(RFun {}) = error $ "RFun " ++ show st
convertSpecType _ _ _ _ st@(RAllT {}) = error $ "RAllT " ++ show st
convertSpecType _ _ _ _ st@(RAllP {}) = error $ "RAllP " ++ show st
convertSpecType _ _ _ _ st@(RAllS {}) = error $ "RAllS " ++ show st
convertSpecType _ _ _ _ st@(RAllE {}) = error $ "RAllE " ++ show st
convertSpecType _ _ _ _ st@(REx {}) = error $ "REx " ++ show st
convertSpecType _ _ _ _ st@(RExprArg {}) = error $ "RExprArg " ++ show st
convertSpecType _ _ _ _ st@(RRTy {}) = error $ "RRTy " ++ show st
convertSpecType _ _ _ _ st = error $ "Bad st = " ++ show st

polyPredFunc :: [SpecType] -> Type -> DictMaps -> BoundTypes -> Id -> LHStateM Expr
polyPredFunc as ty m bt b = do
    dict <- lhTCDict m ty
    as' <- mapM (polyPredLam m bt) as

    bool <- tyBoolT

    let ar1 = Type (typeOf b)
        ars = [dict] ++ as' ++ [Var b]
        t = TyForAll (NamedTyBndr b) $ foldr1 TyFun $ map typeOf ars ++ [bool]

    lhPP <- lhPPM
    
    return $ mkApp $ Var (Id lhPP t):ar1:ars

polyPredLam :: DictMaps -> BoundTypes -> SpecType -> LHStateM Expr
polyPredLam m bt rapp  = do
    t <- unsafeSpecTypeToType rapp

    let argT = spArgumentTypes $ PresType t
    is <- mapM argsFromArgT argT

    i <- freshIdN . returnType $ PresType t
    
    st <- convertSpecType m bt is (Just i) rapp
    return $ Lam TermL i st

convertLHExpr :: DictMaps -> BoundTypes -> Maybe Type -> Ref.Expr -> LHStateM Expr
convertLHExpr _ _ t (ECon c) = convertCon t c
convertLHExpr _ bt t (EVar s) = convertEVar (symbolName s) bt t
convertLHExpr m bt _ (EApp e e') = do
    f <- convertLHExpr m bt Nothing e

    let at = argumentTypes f
        f_ar_t = case at of
                    (_:_) -> Just $ last at
                    _ -> Nothing

        f_ar_ts = fmap tyAppArgs f_ar_t

    argE <- convertLHExpr m bt f_ar_t e'

    let tArgE = typeOf argE
        ctArgE = tyAppCenter tArgE
        ts = take (numTypeArgs f) $ tyAppArgs tArgE
    
    case (ctArgE, f_ar_ts) of
        (TyCon _ _, Just f_ar_ts') -> do
            let specTo = concatMap (map snd) $ map M.toList $ map (snd . uncurry (specializes M.empty)) $ zip ts f_ar_ts'
                te = map Type specTo

            tcs <- mapM (lhTCDict m) ts

            let fw = mkApp $ f:te

                apps = mkApp $ fw:tcs ++ [argE]
            
            return apps
        _ -> return $ App f argE
convertLHExpr m bt t (ENeg e) = do
    e' <- convertLHExpr m bt t e
    let t' = typeOf e'

    neg <- lhNegateM
    num <- numTCM
    a <- freshIdN TYPE
    let tva = TyVar a
    let negate' = Var $ Id neg 
                        (TyForAll (NamedTyBndr a)
                            (TyFun
                                (TyApp (TyCon num (TyApp TYPE TYPE)) tva)
                                (TyFun
                                    tva
                                    tva
                                )
                            )
                        )

    nDict <- numDict m t'

    return $ mkApp [ negate'
                   , Type t'
                   , nDict
                   , e' ]
convertLHExpr m bt t (EBin b e e') = do
    (e2, e2') <- correctTypes m bt t e e'
    b' <- convertBop b

    let t' = typeOf e2

    nDict <- bopTCDict b m t'

    return $ mkApp [ b'
                   , Type t'
                   , nDict
                   , e2
                   , e2' ]
convertLHExpr m bt _ (ECst e s) = do
    t <- sortToType s
    convertLHExpr m bt (Just t) e
convertLHExpr m bt _ (PAnd es) = do
    es' <- mapM (convertLHExpr m bt Nothing) es

    true <- mkTrueE
    an <- lhAndE

    case es' of
        [] -> return $ true
        [e] -> return e
        _ -> return $ foldr (\e -> App (App an e)) true es'
convertLHExpr m bt _ (POr es) = do
    es' <- mapM (convertLHExpr m bt Nothing) es

    false <- mkFalseE
    orE <- lhOrE

    case es' of
        [] -> return false
        [e] -> return e
        _ -> return $ foldr (\e -> App (App orE e)) false es'
convertLHExpr m bt _ (PNot e) = do
    e' <- convertLHExpr m bt Nothing e
    no <- mkNotE
    return (App no e') 
convertLHExpr m bt t (PImp e1 e2) = do
    e1' <- convertLHExpr m bt t e1
    e2' <- convertLHExpr m bt t e2
    imp <- mkImpliesE
    return $ mkApp [imp, e1', e2']
convertLHExpr m bt t (PIff e1 e2) = do
    e1' <- convertLHExpr m bt t e1
    e2' <- convertLHExpr m bt t e2
    iff <- iffM
    return $ mkApp [iff, e1', e2']
convertLHExpr m bt _ (PAtom brel e1 e2) = do
    (e1', e2') <- correctTypes m bt Nothing e1 e2
    brel' <- convertBrel brel

    let t' = typeOf e1'

    dict <- brelTCDict m t'

    return $ mkApp [brel', Type t', dict, e1', e2']
convertLHExpr _ _ _ e = error $ "Untranslated LH Expr " ++ (show e)

convertBop :: Bop -> LHStateM Expr
convertBop Ref.Plus = convertBop' lhPlusM
convertBop Ref.Minus = convertBop' lhMinusM
convertBop Ref.Times = convertBop' lhTimesM
convertBop Ref.Div = convertBop' lhDivM
convertBop Ref.Mod = convertBop' lhModM
convertBop Ref.RTimes = convertBop' lhTimesM
convertBop Ref.RDiv = convertBop' lhDivM

convertBop' :: LHStateM Name -> LHStateM Expr
convertBop' f = do
    num <- numTCM
    n <- f
    a <- freshIdN TYPE
    let tva = TyVar a
    return $ Var $ Id n (TyForAll (NamedTyBndr a)
                            (TyFun
                                (TyApp (TyCon num (TyApp TYPE TYPE)) tva)
                                (TyFun
                                    tva
                                    (TyFun 
                                        tva 
                                        tva
                                    )
                                )
                            )
                            
                        )

-- | We often end up in the situation of having to compare some value of type a1
-- to an instance of type Integer.  This function, in order:
-- (1) Converts the value of type Integer to the type a1, if a1 is an instance
--     of Num.
-- (2) Converts the value of type a1 to Integer, if a1 is not an instance of Num
-- but is a value of type Integral
-- (3) Fails with an error.
correctTypes :: DictMaps -> BoundTypes -> Maybe Type -> Ref.Expr -> Ref.Expr -> LHStateM (Expr, Expr)
correctTypes m bt mt re re' = do
    fIntgr <- lhFromIntegerM
    tIntgr <- lhToIntegerM
    tyI <- tyIntegerT

    e <- convertLHExpr m bt mt re
    e' <- convertLHExpr m bt mt re'

    let t = typeOf e
    let t' = typeOf e'

    let retT = returnType e
    let retT' = returnType e'

    may_nDict <- maybeNumDict m t
    may_nDict' <- maybeNumDict m t'

    may_iDict <- maybeIntegralDict m t
    may_iDict' <- maybeIntegralDict m t'

    if | t == t' -> return (e, e')
       | retT /= tyI
       , retT' == tyI
       , Just nDict <- may_nDict -> return (e, mkApp [Var fIntgr, Type t, nDict, e'])
       | retT == tyI
       , retT' /= tyI
       , Just nDict' <- may_nDict' -> return (mkApp [Var fIntgr, Type t', nDict', e], e')
       | retT /= tyI
       , retT' == tyI
       , Just iDict <- may_iDict -> return (mkApp [Var tIntgr, Type t, iDict, e], e')
       | retT == tyI
       , retT' /= tyI
       , Just iDict' <- may_iDict' -> return (e, mkApp [Var tIntgr, Type t', iDict', e'])
       | otherwise -> error "correctTypes: Unhandled case"

convertSymbolT :: Symbol -> Type -> Id
convertSymbolT s = Id (symbolName s)

reftSymbol :: Reft -> Symbol
reftSymbol = fst . unpackReft

reftExpr :: Reft -> Ref.Expr
reftExpr = snd . unpackReft

unpackReft :: Reft -> (Symbol, Ref.Expr) 
unpackReft = coerce

-- If possible, we split symbols at the last "." not in parenthesis, to
-- correctly set module names 
symbolName :: Symbol -> Name
symbolName s =
    let
        t = symbolSafeText s
        l = case T.null t of
            True -> Just $ T.last t
            False -> Nothing

        ((m, n), i) =
            case l of
                Just ')' -> (T.breakOnEnd ".(" t, 2)
                _ -> (T.breakOnEnd "." t, 1)

        m' = T.dropEnd i m
    in
    case (m', n) of
        (n', "") -> Name n' Nothing 0 Nothing
        _ -> Name n (Just m') 0 Nothing

convertEVar :: Name -> BoundTypes -> Maybe Type -> LHStateM Expr
convertEVar nm@(Name n md _ _) bt mt
    | Just t <-  M.lookup nm bt = return $ Var (Id nm t)
    | otherwise = do
        meas <- measuresM
        tenv <- typeEnv
        
        if | Just (n', e) <- E.lookupNameMod n md meas ->
                return . Var $ Id n' (typeOf e)
           | Just dc <- getDataConNameMod' tenv nm -> return $ Data dc
           | Just t <- mt -> return $ Var (Id nm t)
           | otherwise -> error $ "convertEVar: Required type not found"

convertCon :: Maybe Type -> Constant -> LHStateM Expr
convertCon (Just (TyCon n _)) (Ref.I i) = do
    (TyCon ti _) <- tyIntT
    dc <- mkDCIntE
    if n == ti
        then return $ App dc (Lit . LitInt $ fromIntegral i)
        else error $ "Unknown Con" ++ show n
convertCon _ (Ref.I i) = do
    dc <- mkDCIntegerE
    return $ App dc (Lit . LitInt $ fromIntegral i)
convertCon _ (Ref.R d) = do
    dc <- mkDCDoubleE
    return $ App dc (Lit . LitDouble $ toRational d)
convertCon _ _ = error "convertCon: Unhandled case"

unsafeSpecTypeToType :: SpecType -> LHStateM Type
unsafeSpecTypeToType st = do
    t' <- specTypeToType st
    case t' of
        Just t'' -> return t''
        Nothing -> error $ "Unhandled SpecType" ++ show st

specTypeToType :: SpecType -> LHStateM (Maybe Type)
specTypeToType (RVar {rt_var = (RTV v)}) = do
    let i = mkIdUnsafe v
    return $ Just (TyVar i)
specTypeToType (RFun {rt_in = fin, rt_out = fout}) = do
    t <- specTypeToType fin
    t2 <- specTypeToType fout
    
    case (t, t2) of
        (Just t', Just t2') -> return $ Just (TyFun t' t2')
        _ -> return Nothing
specTypeToType (RAllT {rt_tvbind = RTVar (RTV v) _, rt_ty = rty}) = do
    let i = mkIdUnsafe v
    t <- specTypeToType rty
    return $ fmap (TyForAll (NamedTyBndr i)) t
specTypeToType (RApp {rt_tycon = c, rt_args = as}) = rTyConType c as
specTypeToType (RAppTy {rt_arg = arg, rt_res = res}) = do
    argT <- specTypeToType arg
    resT <- specTypeToType res
    case (argT, resT) of
        (Just argT', Just resT') -> return $ Just (TyApp argT' resT')
        _ -> return Nothing
specTypeToType rty = error $ "Unmatched pattern in specTypeToType " ++ show (pprint rty)

rTyConType :: RTyCon -> [SpecType]-> LHStateM (Maybe Type)
rTyConType rtc sts = do
    tenv <- typeEnv

    let tcn = mkTyConName HM.empty . rtc_tc $ rtc
        n = nameModMatch tcn tenv

    ts <- mapM specTypeToType sts
    
    case (not . any isNothing $ ts) of
        True -> case fmap (\n' -> mkFullAppedTyCon n' (catMaybes ts) TYPE) n of
                    Nothing -> return $ primType tcn
                    t -> return t
        False -> return Nothing

primType :: Name -> Maybe Type
primType (Name "Int#" _ _ _) = Just TyLitInt
primType (Name "Float#" _ _ _) = Just TyLitFloat
primType (Name "Double#" _ _ _) = Just TyLitDouble
primType (Name "Word#" _ _ _) = Just TyLitInt
primType _ = Nothing

sortToType :: Sort -> LHStateM Type
sortToType FInt = tyIntT
sortToType FReal = tyDoubleT
sortToType _ = error "Unhandled sort"

convertBrel :: Brel -> LHStateM Expr
convertBrel Ref.Eq = convertBrel' lhEqM
convertBrel Ref.Ueq = convertBrel' lhEqM
convertBrel Ref.Ne = convertBrel' lhNeM
convertBrel Ref.Gt = return . Var =<< lhGtE
convertBrel Ref.Ge = return . Var =<< lhGeE
convertBrel Ref.Lt = return . Var =<< lhLtE
convertBrel Ref.Le = return . Var =<<  lhLeE
convertBrel _ = error "convertBrel: Unhandled brel"

convertBrel' :: LHStateM Name -> LHStateM Expr
convertBrel' f = do
    n <- f

    a <- freshIdN TYPE
    lh <- lhTCM
    b <- tyBoolT
    let tva = TyVar a
        t = TyForAll 
                (NamedTyBndr a)
                (TyFun
                    (TyCon lh TYPE)
                    (TyFun 
                        tva 
                        (TyFun tva b)
                    )
                )

    return $ Var $ Id n t

brelTCDict :: DictMaps -> Type -> LHStateM Expr
brelTCDict = lhTCDict

bopTCDict :: Bop -> DictMaps -> Type -> LHStateM Expr
bopTCDict Ref.Mod = integralDict
bopTCDict _ = numDict

lhTCDict :: DictMaps -> Type -> LHStateM Expr
lhTCDict m t = do
    lh <- lhTCM
    tc <- typeClassInstTC (lh_dicts m) lh t
    case tc of
        Just e -> return e
        Nothing -> error $ "No lh dict " ++ show lh ++ "\n" ++ show t ++ "\n" ++ show m

lhTCDict' :: LHDictMap -> Type -> LHStateM Expr
lhTCDict' m t = do
    lh <- lhTCM
    tc <- typeClassInstTC m lh t
    case tc of
        Just e -> return e
        Nothing -> error $ "No lh dict " ++ show lh ++ "\n" ++ show t ++ "\n" ++ show m

maybeNumDict :: DictMaps -> Type -> LHStateM (Maybe Expr)
maybeNumDict m t = do
    num <- numTCM
    typeClassInstTC (num_dicts m) num t

numDict :: DictMaps -> Type -> LHStateM Expr
numDict m t = do
    tc <- maybeNumDict m t
    case tc of
        Just e -> return e
        Nothing -> error $ "No num dict \n" ++ show t ++ "\n" ++ show m

maybeIntegralDict :: DictMaps -> Type -> LHStateM (Maybe Expr)
maybeIntegralDict m t = do
    integral <- return . KV.integralTC =<< knownValues
    typeClassInstTC (integral_dicts m) integral t

integralDict :: DictMaps -> Type -> LHStateM Expr
integralDict m t = do
    tc <- maybeIntegralDict m t
    case tc of
        Just e -> return e
        Nothing ->  error $ "No integral dict\n" ++ show t ++ "\n" ++ show m
