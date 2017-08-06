module Zwerg.Data.HP
  ( HP
  , adjustHP
  , adjustMaxHP
  ) where

import Zwerg.Prelude

newtype HP = MkHP (Int, Int)
  deriving (Show, Eq, Ord, Generic)

validHP :: (Int,Int) -> Bool
validHP (curHP, maxHP) = curHP >= 0 && curHP <= maxHP && maxHP > 0

instance Binary HP

instance ZWrapped HP (Int, Int) where
  unwrap (MkHP hp) = hp
  wrap intPair = if validHP intPair then Just (MkHP intPair) else Nothing

instance ZDefault HP where
    zDefault = MkHP (1,1)

adjustHP :: (Int -> Int) -> HP -> HP
adjustHP f (MkHP (curHP, maxHP))
  | newHP < 0 = MkHP (0, maxHP)
  | newHP > maxHP = MkHP (maxHP, maxHP)
  | otherwise = MkHP (newHP, maxHP)
  where
    newHP = f curHP

adjustMaxHP :: (Int -> Int) -> HP -> HP
adjustMaxHP f (MkHP (curHP, maxHP))
  | newMaxHP < 0 = MkHP (1, 1)
  | curHP > newMaxHP = MkHP (newMaxHP, newMaxHP)
  | otherwise = MkHP (curHP, newMaxHP)
  where newMaxHP = f maxHP
