module Zwerg.Event.Queue
    ( ZwergEventQueue
    , HasZwergEventQueue(..)
    , popEvent
    , pushEventM
    , mergeEventsM
    , module EXPORTED
    ) where

import Zwerg.Prelude

import Zwerg.Event as EXPORTED

import Lens.Micro.Platform (Lens', use, (.=), (%=))
import Data.Sequence (Seq, (|>), ViewL(..), (><))
import qualified Data.Sequence as S (viewl, empty, length, null)

newtype ZwergEventQueue = MkZwergEventQueue (Seq ZwergEvent)
    deriving stock Generic
    deriving anyclass Binary

class HasZwergEventQueue s where
    eventQueue :: Lens' s ZwergEventQueue

instance HasZwergEventQueue ZwergEventQueue where
    eventQueue = id

instance ZEmptiable ZwergEventQueue where
    zIsNull (MkZwergEventQueue q) = S.null q
    zSize (MkZwergEventQueue q) = S.length q

instance ZDefault ZwergEventQueue where
    zDefault = MkZwergEventQueue S.empty

popEvent :: (HasZwergEventQueue s, MonadState s m) => m (Maybe ZwergEvent)
popEvent = do
    (MkZwergEventQueue q) <- use eventQueue
    case S.viewl q of
      EmptyL -> return Nothing
      evt :< eq' -> do
          eventQueue .= MkZwergEventQueue eq'
          return $ Just evt

{-# INLINABLE pushEventM #-}
pushEventM :: (HasZwergEventQueue s, MonadState s m) => ZwergEvent -> m ()
pushEventM evt = eventQueue %= \(MkZwergEventQueue q) -> MkZwergEventQueue $ q |> evt

{-# INLINABLE mergeEventsM #-}
mergeEventsM :: (HasZwergEventQueue s, MonadState s m) => ZwergEventQueue -> m ()
mergeEventsM (MkZwergEventQueue q') =
    eventQueue %= \(MkZwergEventQueue q) -> MkZwergEventQueue $ q >< q'
