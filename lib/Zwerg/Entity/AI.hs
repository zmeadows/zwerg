module Zwerg.Entity.AI
  ( runAI
  ) where

import Zwerg.Component
import Zwerg.Data.Position
import Zwerg.Entity
import Zwerg.Event.Queue
import Zwerg.Prelude
import Zwerg.Random
import Zwerg.Util

import Control.Monad.Loops (minimumByM)
import Control.Monad.Random (RandT, evalRandT)
import Data.Maybe (fromJust, catMaybes)

newtype AI a = AI (RandT RanGen (StateT ZwergEventQueue (Reader Components)) a)
  deriving newtype ( Functor
                   , Applicative
                   , Monad
                   , MonadReader Components
                   , MonadState ZwergEventQueue
                   , MonadRandom
                   )

runAI :: ( HasCallStack
         , HasComponents s
         , HasZwergEventQueue s
         , MonadState s m
         , MonadRandom m
         ) => UUID -> m ()
runAI uuid = do
  cmps <- getComponents
  ait <- aiType <@> uuid
  ranWord <- getRandom
  let (AI a)   = enact uuid ait
      (_,evts) = runReader (runStateT (evalRandT a $ pureRanGen ranWord) zDefault) cmps
  mergeEventsM evts

enact :: UUID -> AIType -> AI ()
enact entityUUID SimpleMeleeCreature = do
    whenM (uncurry (==) <$> inM2 getZLevel (playerUUID, entityUUID)) $ do
      tileUUID <- tileOn <~> entityUUID
      entityPos <- position <~> entityUUID
      playerPos <- position <~> playerUUID
      if (isNeighborPos entityPos playerPos)
         then $(newEvent "WeaponAttackAttempt") entityUUID playerUUID
         else do
           possTiles <- catMaybes <$> mapM (`getAdjacentTileUUID` tileUUID) cardinalDirections
           openPossTiles <- filterM (\i -> not <$> tileBlocksPassage i) possTiles
           let distanceToPlayer e1UUID e2UUID = do
                 e1Dis <- distance Euclidean playerPos <$> position <~> e1UUID
                 e2Dis <- distance Euclidean playerPos <$> position <~> e2UUID
                 return $ compare e1Dis e2Dis
           unless (null openPossTiles) $ do
             newTileUUID <- fromJust <$> minimumByM distanceToPlayer openPossTiles
             newPos <- position <~> newTileUUID
             $(newEvent "MoveEntity") entityUUID newPos

enact _ _ = return ()
