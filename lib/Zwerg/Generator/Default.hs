module Zwerg.Generator.Default
  ( module EXPORTED
  , generateSkeleton
  , generatePlayerSkeleton
  ) where

import Zwerg.Generator as EXPORTED

generatePlayerSkeleton :: Generator' ()
generatePlayerSkeleton = do
  --TODO: check if player already exists and throw error if it does
  addComp playerUUID equipment zDefault
  addComp playerUUID inventory zDefault
  addComp playerUUID stats zDefault
  addComp playerUUID glyph $ Glyph '@' (CellColor yellow Nothing)
  addComp playerUUID blocksPassage True
  addComp playerUUID blocksVision False

generateSkeleton :: EntityType -> Generator' UUID
generateSkeleton etype = do
  entityUUID <- popUUID
  addComp entityUUID entityType etype
  generateSkeleton' entityUUID etype
  return entityUUID

generateSkeleton' :: UUID -> EntityType -> Generator' ()
generateSkeleton' enemyUUID Enemy = do
  addComp enemyUUID equipment zDefault
  addComp enemyUUID stats zDefault
  addComp enemyUUID blocksPassage True
  addComp enemyUUID blocksVision False

generateSkeleton' levelUUID Level = do
  setComp levelUUID tiles zDefault
  emptyTileMap <- zBuildM $ \pos -> do
      tileUUID <- generateSkeleton Tile
      addComp tileUUID position pos
      addComp tileUUID level levelUUID
      modComp levelUUID tiles (zAdd tileUUID)
      return tileUUID
  setComp levelUUID tileMap emptyTileMap
  setComp levelUUID name "Test Square Level"

generateSkeleton' tileUUID Tile = do
  addComp tileUUID tileType Void
  addComp tileUUID occupants zDefault
  addComp tileUUID blocksPassage True
  addComp tileUUID needsRedraw True

generateSkeleton' itemUUID Item = do
  addComp itemUUID blocksPassage False
  addComp itemUUID blocksVision False

generateSkeleton' otherUUID otherType = addComp otherUUID entityType otherType
