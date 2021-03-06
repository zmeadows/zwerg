module Zwerg.Data.UUIDMap
  ( UUIDMap
  , getMinimumUUIDs
  , toUUIDSet
  ) where

import Zwerg.Prelude

import Zwerg.Data.UUIDSet (UUIDSet)

import Data.IntMap.Strict (IntMap)
import qualified Data.IntMap.Strict as IM
import Data.Maybe (fromJust)

newtype UUIDMap a = MkUUIDMap (IntMap a)
    deriving stock (Functor, Generic)
    deriving anyclass Binary

instance ZDefault (UUIDMap a) where
  zDefault = MkUUIDMap IM.empty

instance ZEmptiable (UUIDMap a) where
  zIsNull (MkUUIDMap m) = IM.null m
  zSize (MkUUIDMap m) = IM.size m

instance ZMapContainer UUIDMap UUID where
  zModifyAt f uuid (MkUUIDMap m)   = MkUUIDMap $ IM.adjust f (unwrap uuid) m
  zElems (MkUUIDMap m)           = IM.elems m

instance ZIncompleteMapContainer UUIDMap UUID where
  zLookup uuid (MkUUIDMap m)     = IM.lookup (unwrap uuid) m
  zInsert uuid val (MkUUIDMap m) = MkUUIDMap $ IM.insert (unwrap uuid) val m
  zRemoveAt uuid (MkUUIDMap m)   = MkUUIDMap $ IM.delete (unwrap uuid) m
  zContains uuid (MkUUIDMap m)   = IM.member (unwrap uuid) m
  zKeys (MkUUIDMap m)            = (catMaybes . map wrap) $ IM.keys m

instance ZFilterable (UUIDMap a) (UUID, a) where
    zFilter f (MkUUIDMap m) = MkUUIDMap $ IM.filterWithKey (\x -> curry f (fromJust $ wrap x)) m
    zFilterM f (MkUUIDMap m) = (MkUUIDMap . IM.fromAscList)
                               <$> (filterM (\(x,a) -> f (unsafeWrap x, a)) $ IM.toAscList m)

getMinimumUUIDs :: (Ord a, Bounded a) => UUIDMap a -> (a, [UUID])
getMinimumUUIDs (MkUUIDMap um) =
  let (amin, ids) = IM.foldrWithKey f (minBound, []) um
  in (amin, ) $ map unsafeWrap ids
  where
    f uuid x (_, []) = (x, [uuid])
    f uuid x (xmin, uuids) =
      if | x == xmin -> (x, uuid : uuids)
         | x < xmin -> (x, [uuid])
         | otherwise -> (xmin, uuids)

{-# INLINABLE toUUIDSet #-}
toUUIDSet :: UUIDMap a -> UUIDSet
toUUIDSet m = unsafeWrap $ zKeys m
