module Zwerg.Generator.Level.TestSquare where

import Zwerg.Entity
import Zwerg.Generator
import Zwerg.Generator.Enemy.Goblin
import Zwerg.Generator.Level
import Zwerg.Util

import Data.Map.Strict (traverseWithKey)

testSquareGenerator :: Generator UUID
testSquareGenerator =
  MkGenerator $ do
    traceM "generating Test Square..."
    testSquareLevelUUID <- popUUID
    generate $ levelSkeletonGenerator testSquareLevelUUID
    testSquareTiles <- demandComp tileMap testSquareLevelUUID
    _ <-
      flip traverseWithKey (unwrap testSquareTiles) $ \pos tileUUID -> do
        let (x, y) = unPosition pos
            isWallTile =
              x == 0 || x == mapWidthINT - 1 || y == 0 || y == mapHeightINT - 1
        if isWallTile
          then do
            setComp tileUUID tileType Wall
            setComp tileUUID glyph $ Glyph 'X' 15 248 Nothing Nothing
          else do
            setComp tileUUID tileType Floor
            setComp tileUUID blocked False
            setComp tileUUID glyph $ Glyph '·' 15 48 Nothing Nothing
    traceM "generating Goblins..."
    replicateM_ 50 $ do
      goblinUUID <- generate goblinGenerator
      addComp goblinUUID level testSquareLevelUUID
      goblinTileUUID <- getRandomTile testSquareLevelUUID
      goblinTileUUID' <-
        fromJustErrM goblinTileUUID $
        ZError
          __FILE__
          __LINE__
          Fatal
          "Could not find an open tile to place Goblin"
      demandComp position goblinTileUUID' >>= addComp goblinUUID position
      addOccupant goblinUUID goblinTileUUID'
      addComp goblinTileUUID' blocked True
    return testSquareLevelUUID
