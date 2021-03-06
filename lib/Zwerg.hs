module Zwerg
  ( ZwergState
  , HasZwergState(..)
  , initZwergState
  ) where

#define DEBUG_CALLSTACK

import Zwerg.Prelude hiding ((<>))

import Zwerg.Component
import Zwerg.Game
import Zwerg.Random

import Data.ByteString (ByteString)

import Lens.Micro.Platform (makeClassy)

-- TODO: actually use 'quitting' variable
-- probably needs to be moved to GameState
data ZwergState = ZwergState
  { _zsGameState :: GameState
  , _ranGen      :: RanGen
  , _quitting    :: Bool
  , _pastState   :: [ByteString]
  }
makeClassy ''ZwergState

instance HasGameState ZwergState where
  gameState = zsGameState
instance HasComponents ZwergState where
  components = gameState . components

initZwergState :: ZwergState
initZwergState = ZwergState
  { _zsGameState = emptyGameState
  , _ranGen      = pureRanGen 0
  , _quitting    = False
  , _pastState   = []
  }


