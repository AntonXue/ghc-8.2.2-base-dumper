module G2 where


import HscTypes

import G2.Translation.TransTypes


-- data ModDetailsClosure

-- data CgGutsClosure

-- data ExtractedG2


{-
hskToG2ViaCgGuts :: NameMap
  -> TypeNameMap
  -> [(CgGutsClosure, ModDetailsClosure)]
  -> (NameMap, TypeNameMap, ExtractedG2)

mkCgGutsClosure :: CgGuts -> CgGutsClosure

mkModDetailsClosure :: ModDetails -> ModDetailsClosure
-}

dumpG2 :: String -> Dependencies -> CgGuts -> ModDetails -> IO ()


