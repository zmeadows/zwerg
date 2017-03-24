module Zwerg.Generator.Player.TestPlayer where

import Zwerg.Generator
import Zwerg.UI.Font
import Zwerg.Util

testPlayerGenerator :: UUID -> Generator ()
testPlayerGenerator startLevelUUID = MkGenerator $ do
    let addPlayerComp = addComp playerUUID

    traceM "generating Player..."

    addPlayerComp name "Bob"
    addPlayerComp level startLevelUUID
    addPlayerComp glyph $ Glyph Normal '@' $ mkColor 255 255 255
    zConstruct (10,10) >>= addPlayerComp hp
    addPlayerComp entityType Player
    addPlayerComp equipment emptyEquipment
    addPlayerComp stats zeroStats

    playerTileUUID <- getRandomTile startLevelUUID

    playerTileUUID' <- fromJustErrM playerTileUUID
      (ZError __FILE__ __LINE__ Fatal "Could not find an open tile to place Player")

    demandComp position playerTileUUID' >>= addPlayerComp position
    addOccupant playerUUID playerTileUUID'
          

