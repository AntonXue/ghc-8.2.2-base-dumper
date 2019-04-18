-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Digest.SHA224
-- Copyright   :  (c) Russell O'Connor 2006
-- License     :  BSD-style (see the file ReadMe.tex)
-- 
-- Takes the SHA2 module supplied and wraps it so it
-- takes [Octet] and returns [Octet] where the length of the result
-- is always 28.
-- and <http://csrc.nist.gov/publications/fips/fips180-2/fips180-2withchangenotice.pdf>.
--
-----------------------------------------------------------------------------

module Data.Digest.SHA224 (
   -- * Function Types
   hash) where

import Data.Digest.SHA2 as SHA2
import Codec.Utils

-- | Take [Octet] and return [Octet] according to the standard.
--   The length of the result is always 28 octets or 224 bits as required
--   by the standard.

hash :: [Octet] -> [Octet]
hash = SHA2.toOctets . SHA2.sha224