module G2
  ( module G2.Language.Syntax
  , module G2.Language.TypeEnv
  , module G2.Language.Typing
  , module G2.Language.AlgDataTy
  -- , module G2.Language.KnownValues
  , module G2.Language.AST

  , module G2.Translation.Haskell
  , module G2.Translation.TransTypes

  , dumpG2
  ) where


import GHC
import HscTypes

import qualified Data.HashMap.Lazy as HM
import System.Directory
import System.FilePath

import G2.Language.Syntax
import G2.Language.TypeEnv
import G2.Language.Typing
import G2.Language.AlgDataTy
import G2.Language.KnownValues
import G2.Language.AST

import G2.Translation.Haskell
import G2.Translation.TransTypes


g2DumpDir :: FilePath
g2DumpDir = "/home/celery/Desktop/ghc-dump-dir"

dumpG2 :: String -> Dependencies -> CgGuts -> ModDetails -> IO ()
dumpG2 name deps cgguts moddets = do

  let nameMap = HM.empty
  let tyNameMap = HM.empty
  -- TODO: Figure out how to preserve rewrite rules in this pass
  -- see G2/Translation/Haskell.hs for info about mkCgGutsClosure
  let cgcc = mkCgGutsClosure (cg_binds cgguts) cgguts
  let mdcc = mkModDetailsClosure deps moddets

  let g2 = hskToG2ViaCgGuts
              nameMap
              tyNameMap
              [(cgcc, mdcc)]
              simplTranslationConfig

  writeFile (g2DumpDir ++ "/" ++ name ++ ".g2-dump") $ show g2

  return ()

