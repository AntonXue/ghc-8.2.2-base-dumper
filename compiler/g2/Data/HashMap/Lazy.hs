module Data.HashMap.Lazy
  ( module Data.Hashable
  , empty
  , fromList
  , toList
  , fromListWith
  , lookup
  , lookupDefault
  , member
  , insert
  , insertWith
  , foldrWithKey
  , HashMap
  ) where


import Prelude hiding (lookup)
import qualified Data.Map as M

import Data.Hashable

newtype HashMap k a = HashMap { get :: M.Map k a } deriving Read

empty :: HashMap k a
empty = HashMap (M.empty)

fromList :: Ord k => [(k, a)] -> HashMap k a
fromList = HashMap . M.fromList

toList :: HashMap k v -> [(k, v)]
toList = M.toList . get

fromListWith :: Ord k => (a -> a -> a) -> [(k,a)] -> HashMap k a
fromListWith f = HashMap . M.fromListWith f

lookup :: Ord k => k -> HashMap k a -> Maybe a
lookup k = M.lookup k . get

lookupDefault :: (Ord k) => v -> k -> HashMap k v -> v
lookupDefault d k hm =
  case lookup k hm of
    Just v -> v
    Nothing -> d

member :: Ord k => k -> HashMap k a -> Bool
member k = M.member k . get

insert :: Ord k => k -> a -> HashMap k a -> HashMap k a
insert k a = HashMap . M.insert k a . get

insertWith :: Ord k => (a -> a -> a) -> k -> a -> HashMap k a -> HashMap k a
insertWith f k a = HashMap . M.insertWith f k a . get

foldrWithKey :: Ord k => (k -> a -> b -> b) -> b -> HashMap k a -> b
foldrWithKey f b = M.foldrWithKey f b . get


instance (Eq k, Eq a) => Eq (HashMap k a) where
  hm1 == hm2 = (get hm1) == (get hm2)


instance Foldable (HashMap k) where
  foldr f b = foldr f b . get

instance Functor (HashMap k) where
  fmap f = HashMap . fmap f . get
  

instance (Show k, Show a) => Show (HashMap k a) where
  show = show . get


{-
instance (Read k, Read a) => Read (HashMap k a) where
  readPrec = HashMap . readPrec
-}

