module Data.HashSet
  ( module Data.Hashable
  , HashSet
  , toList
  , fromList
  , empty
  , map
  , insert
  , foldr
  , show
  ) where

import Prelude hiding (map)
import qualified Data.List as L
import Data.Hashable

-- toList
-- map
-- insert
-- empty


newtype HashSet a = HashSet { get :: [a] } deriving Read

toList :: HashSet a -> [a]
toList = id . get

fromList :: [a] -> HashSet a
fromList = HashSet

empty :: HashSet a
empty = HashSet []

map :: (a -> b) -> HashSet a -> HashSet b
map f = HashSet . L.map f . get

insert :: (Eq a) => a -> HashSet a -> HashSet a
insert x = HashSet . (:) x . filter ((/=) x) . get

instance Foldable (HashSet) where
  foldr f z = L.foldr f z . get

instance Show a => Show (HashSet a) where
  show hs = "fromList " ++ (show $ get hs)

instance Eq a => Eq (HashSet a) where
  hs1 == hs2 = (get $ hs1) == (get $ hs2)


