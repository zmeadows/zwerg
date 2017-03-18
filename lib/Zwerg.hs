module Zwerg (zwerg) where

import Zwerg.Game
import Zwerg.Graphics.SDL
import Zwerg.Graphics.SDL.Core
import Zwerg.Graphics.SDL.Util
import Zwerg.Graphics.SDL.MainMenu
import Zwerg.Data.RanGen
import Zwerg.UI.Port
import Zwerg.Util

import Control.Monad.State (StateT, MonadState, runStateT)
import Control.Monad.IO.Class (MonadIO)
import Control.Monad (unless)

import Control.Lens (makeClassy, use, assign)
import qualified SDL

data ZwergState = ZwergState
    { _sdlContext  :: ContextSDL
    , _zsGameState :: GameState
    , _ranGen      :: RanGen
    , _quitting    :: Bool
    }
makeClassy ''ZwergState

instance HasGameState ZwergState where
    gameState = zsGameState
instance HasContextSDL ZwergState where
    contextSDL = sdlContext
instance HasCoreContextSDL ZwergState where
    coreContextSDL = sdlContext . core
instance HasMainMenuContextSDL ZwergState where
    mainMenuContextSDL = sdlContext . mainMenuContext

initZwergState :: ZwergState
initZwergState = ZwergState
    { _sdlContext  = uninitializedContextSDL
    , _zsGameState = emptyGameState
    , _ranGen      = pureRanGen 0
    , _quitting    = False
    }

newtype Zwerg a = Zwerg (StateT ZwergState IO a)
    deriving (
        Functor,
        Applicative,
        Monad,
        MonadState ZwergState,
        MonadIO
    )

runZwerg :: Zwerg a -> IO (a, ZwergState)
runZwerg (Zwerg a) = runStateT a initZwergState

test :: Zwerg ()
test = do
    newPureRanGen >>= assign ranGen
    initSDL
    mainLoop

zwerg :: IO ((), ZwergState)
zwerg = runZwerg test

mainLoop :: Zwerg ()
mainLoop = do
    currentPort <- use (gameState . port)
    drawZwergScreen currentPort
    whenJustM (fmap SDL.eventPayload <$> SDL.pollEvent) $ \case
        SDL.KeyboardEvent ked -> whenJust (keyboardEventToKey ked) $ \keycode -> do
            st <- use gameState
            gen <- use ranGen
            let (st', _, gen') = runGame (processUserInput keycode) gen st
            assign gameState st'
            assign ranGen gen'
        SDL.QuitEvent       -> assign quitting True
        _                   -> return ()

    use quitting >>= \q -> unless q mainLoop
    quitZwerg

drawZwergScreen :: Port -> Zwerg ()
drawZwergScreen (MainMenu m) = do
    ren <- use (sdl . renderer)
    SDL.clear ren
    drawMainMenu m
    SDL.present ren

drawZwergScreen _ = return ()

quitZwerg :: Zwerg ()
quitZwerg = shutdownSDL
