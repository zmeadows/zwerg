module Zwerg.Generator.Level
  ( module EXPORTED
  , levelSkeletonGenerator
  ) where

import Zwerg.Generator as EXPORTED

levelSkeletonGenerator :: Generator
levelSkeletonGenerator = do
  levelUUID <- popUUID
  let xs = [0 .. mapWidthINT - 1]
      ys = [0 .. mapHeightINT - 1]
  tileList <- forM [(x, y) | x <- xs, y <- ys] $
    \(x', y') -> do
       uuid <- popUUID
       addComp uuid entityType Tile
       addComp uuid tileType Void
       pos <- zConstruct (x', y')
       addComp uuid position pos
       addComp uuid occupants zEmpty
       addComp uuid blocksPassage True
       addComp uuid needsRedraw True
       addComp uuid level levelUUID
       return (pos, uuid)
  zConstruct tileList >>= setComp levelUUID tileMap
  setComp levelUUID tiles $ zFromList $ fmap snd tileList
  setComp levelUUID entityType Level
  setComp levelUUID name "Test Square Level"
  return levelUUID
