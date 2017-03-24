module Zwerg.Class where

import Zwerg.Prelude
import Zwerg.Data.Error

class ZConstructable a b | a -> b where
  zConstruct :: (MonadError ZError m) => b -> m a

class ZWrapped a b | a -> b where
  unwrap :: a -> b

class ZIsList a b | a -> b where
  zToList   :: a -> [b]
  zFromList :: [b] -> a

class ZEmptiable a where
  zEmpty :: a
  zIsNull :: a -> Bool

class ZContainer a b | a -> b where
  zAdd     :: b -> a -> a
  zDelete  :: b -> a -> a
  zMember  :: b -> a -> Bool

class ZMapContainer a b c | a -> b c where
  zLookup   :: b -> a -> Maybe c
  zAdjust   :: (c -> c) -> b -> a -> a
  zInsert   :: b -> c -> a -> a
  zRemoveAt :: b -> a -> a
  zContains :: b -> a -> Bool

class ZFilterable a b | a -> b where
  zFilter  :: (b -> Bool) -> a -> a
  zFilterM :: (Monad m) => (b -> m Bool) -> a -> m a
