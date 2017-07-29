module Zwerg.Prelude.Primitives
  ( UUID
  , playerUUID
  , Direction(..)
  , cardinalDirections
  , TargetType(..)
  , Color(..)
  , Glyph(..)
  , EntityType(..)
  , Parent(..)
  , TileType(..)
  , Stat(..)
  , Stats(..)
  , zeroStats
  , lookupStat
  , replaceStat
  , AIType(..)
  , ItemType(..)
  , mapWidthDOUBLE
  , mapWidthINT
  , mapHeightDOUBLE
  , mapHeightINT
  ) where

import Protolude
import Zwerg.Prelude.Class
import Zwerg.Data.ZError

import Data.Binary as EXPORTED (Binary)

import Data.Map.Lazy (Map)
import qualified Data.Map.Lazy as M

newtype UUID = MkUUID Int
  deriving (Show, Eq, Bounded, Enum, Num, Ord, Generic, Binary)
-- instance Binary UUID

instance ZWrapped UUID Int where
  unwrap (MkUUID uuid) = uuid

instance ZConstructable UUID Int where
  zConstruct x =
    if | x >= 0 -> return $ MkUUID x
       | otherwise -> $(throw) EngineFatal "Attempted to construct UUID < 0"

playerUUID :: UUID
playerUUID = MkUUID 0

data Direction
  = North
  | South
  | East
  | West
  | NorthWest
  | NorthEast
  | SouthWest
  | SouthEast
  deriving (Show, Eq, Generic)
instance Binary Direction

cardinalDirections :: [Direction]
cardinalDirections = [North,South,East,West]

data TargetType
  = SingleTarget
  | AOE Double
  | Line Direction Int
  deriving (Show, Eq, Generic)
instance Binary TargetType

--TODO: map this onto 256 color?
  --TODO: fallback 8 bit color?
data Color
  = Green0 | Green1 | Green2 | Green3
  | Blue0  | Blue1  | Blue2  | Blue3
  | Red0   | Red1   | Red2   | Red3
  | Black0 | Black1 | Black2 | Black3
  | White0 | White1 | White2 | White3
  deriving (Eq, Show, Generic)
instance Binary Color

-- type ColoredText = [(Color, Text)]

data Glyph = Glyph
  { char :: Char
  , fgColorVIS :: Color
  , fgColorFOG :: Color
  , bgColorVIS :: Maybe Color
  , bgColorFOG :: Maybe Color
  } deriving (Show, Eq, Generic)
instance Binary Glyph

data EntityType
  = Level
  | Container
  | Tile
  | Item
  | Enemy
  | Player
  deriving (Show, Eq, Ord, Enum, Generic)
instance Binary EntityType

data Parent = Alive UUID | Dead
  deriving (Show, Eq, Generic)
instance Binary Parent

data TileType = Floor | Wall | Door | Void
  deriving (Show, Eq, Generic)
instance Binary TileType

data Stat = STR | DEX | INT | CHA | CON | WIS
  deriving (Show, Eq, Ord, Enum, Generic)
instance Binary Stat

newtype Stats = MkStats (Map Stat Int)
  deriving (Show, Eq, Generic)
instance Binary Stats

zeroStats :: Stats
zeroStats = MkStats $ M.fromList $ fmap (, 0) $ enumFrom $ toEnum 0

lookupStat :: Stat -> Stats -> Int
lookupStat s (MkStats m) = m M.! s

replaceStat :: Stat -> Int -> Stats -> Stats
replaceStat s v (MkStats m) = MkStats $ M.insert s v m

-- TODO: modifyStat (Int -> Int)
-- TODO: maximum stat == 100?

data ItemType = Armor | Weapon | Potion | Scroll
  deriving (Show, Eq, Ord, Enum, Generic)
instance Binary ItemType

data AIType = SimpleMeleeCreature | SimpleRangedCreature
  deriving (Show, Eq, Ord, Enum, Generic)
instance Binary AIType

------------
-- CONSTS --
------------
mapWidthDOUBLE :: Double
mapWidthDOUBLE = 100

mapHeightDOUBLE :: Double
mapHeightDOUBLE = 25

mapWidthINT :: Int
mapWidthINT = round mapWidthDOUBLE

mapHeightINT :: Int
mapHeightINT = round mapHeightDOUBLE
