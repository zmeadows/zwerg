module Zwerg.UI.Port where

import Zwerg.Prelude

import Zwerg.Data.Position
import Zwerg.UI.GlyphMap
import Zwerg.UI.Menu

import qualified Data.List.NonEmpty as NE (repeat, zip)

data Port
  = MainScreen GlyphMap
  | MainMenu (Menu ())
  | ChooseTarget
  | LoadingScreen
  | ViewEquipment
  | ViewInventory (Menu InventoryMenuItem)
  | PickupItems (Menu UUID)
  | ExamineTiles Position
  | DeathScreen
  | ExitScreen
  deriving (Show, Eq, Generic)

data InventoryMenuItem = InventoryMenuItem
  { _itemUUID        :: UUID
  , _longDescription :: Text
  } deriving (Show, Eq, Generic)
makeClassy ''InventoryMenuItem
instance Binary InventoryMenuItem

instance Binary Port

type Portal = [Port]

class HasPortal s where
  portal :: Lens' s Portal

initMainMenu :: Port
initMainMenu =
  MainMenu $ makeMenu $
  NE.zip ("new game" :| ["load game", "options", "about", "exit"]) $ NE.repeat ()
