module Zwerg.Entity.AI
  ( runAI
  ) where

import Zwerg.Class
import Zwerg.Component
import Zwerg.Component.All
import Zwerg.Data.Error
import Zwerg.Event
import Zwerg.Prelude
import Zwerg.Random

import Control.Lens (use)
import Control.Monad.Random
import Control.Monad.Random.Class (getSplit)
import Control.Monad.State.Class (modify)

newtype AI a =
  AI (ExceptT ZError (RandT RanGen (StateT EventQueue (Reader Components))) a)
  deriving ( Functor
           , Applicative
           , Monad
           , MonadReader Components
           , MonadError ZError
           , MonadState EventQueue
           , MonadRandom
           )

runAI
  :: ( HasComponents s
     , HasEventQueue s
     , MonadError ZError m
     , MonadState s m
     , MonadSplit RanGen m
     )
  => UUID -> m ()
runAI uuid = do
  cmps <- use components
  ait <- demandComp aiType uuid
  gen <- getSplit
  let (AI a) = enact uuid ait
      (err, evts) =
        runReader (runStateT (evalRandT (runExceptT a) gen) zEmpty) cmps
  case err of
    Left zErr -> throwError zErr
    Right () -> pushEventsM evts

enact :: UUID -> AIType -> AI ()
enact entityUUID SimpleMeleeCreature =
  modify . pushEvent $ MoveEntityEvent $ MoveEntityEventData 0
enact entityUUID SimpleRangedCreature = return ()
