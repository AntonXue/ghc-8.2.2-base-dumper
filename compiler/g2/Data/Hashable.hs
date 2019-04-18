module Data.Hashable
  ( Hashable
  , defaultHashWithSalt
  , hash
  , hashWithSalt
  ) where

import Data.Char


defaultSalt :: Int
defaultSalt = 420

defaultHashWithSalt :: Hashable a => Int -> a -> Int
defaultHashWithSalt salt x = salt + hash x


class Hashable a where
  hashWithSalt :: Int -> a -> Int

  hash :: a -> Int
  hash = hashWithSalt defaultSalt


instance Hashable Int where
  hashWithSalt = defaultHashWithSalt


instance Hashable Char where
  hashWithSalt salt = (hashWithSalt salt) . digitToInt

instance Hashable a => Hashable (Maybe a) where
  hashWithSalt salt (Just x) = hashWithSalt salt x
  hashWithSalt salt Nothing = defaultSalt


instance Hashable a => Hashable [a] where
  hashWithSalt = foldr (\a b -> b + hashWithSalt b a)


