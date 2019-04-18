{-# LANGUAGE FlexibleContexts #-}

module G2.Postprocessing.Undefunctionalize (undefunctionalize) where

import G2.Language
import qualified G2.Language.ExprEnv as E

--Switches every occurence of a Var in the Func SLT from datatype to function
undefunctionalize :: ASTContainer m Expr => State t -> m -> m
undefunctionalize s e = modifyASTs (replaceFuncSLT s) e

replaceFuncSLT :: State t -> Expr -> Expr
replaceFuncSLT s v@(Data (DataCon n _)) =
    let
        n' = lookupFuncInterps n (func_table s)
    in
    case n' of
            Just (n'', _) -> Var $ Id n'' (case functionType s n'' of
                                                  Just t -> t
                                                  Nothing -> TyBottom)
            Nothing -> v
replaceFuncSLT _ e = e

functionType :: State t -> Name -> Maybe Type
functionType s n = typeOf <$> E.lookup n (expr_env s)
