module Zwerg.Component.HP (
    HP,
    mkHP,
    adjustHP,
    adjustMaxHP,
    fullHeal
    ) where

import Control.Exception.Base (assert)

newtype HP = MkHP (Int,Int)
    deriving (Show, Read, Eq, Ord)

{-# INLINABLE mkHP #-}
mkHP :: (Int,Int) -> HP
mkHP (curHP,maxHP) = assert isValidHP $ MkHP (curHP,maxHP)
    where isValidHP = curHP >= 0 && curHP <= maxHP && maxHP > 0

{-# INLINABLE adjustHP #-}
adjustHP :: (Int -> Int) -> HP -> HP
adjustHP f (MkHP (curHP,maxHP))
    | newHP < 0 = MkHP (0,maxHP)
    | newHP > maxHP = MkHP (maxHP, maxHP)
    | otherwise = MkHP (newHP , maxHP)
  where newHP = f curHP

{-# INLINABLE adjustMaxHP #-}
adjustMaxHP :: (Int -> Int) -> HP -> HP
adjustMaxHP f (MkHP (curHP,maxHP))
    | newMaxHP < 0 = MkHP (1,1)
    | curHP > newMaxHP = MkHP (newMaxHP, newMaxHP)
    | otherwise = MkHP (curHP, newMaxHP)
  where newMaxHP = f maxHP

{-# INLINABLE fullHeal #-}
fullHeal :: HP -> HP
fullHeal (MkHP (_,maxHP)) = MkHP (maxHP,maxHP)