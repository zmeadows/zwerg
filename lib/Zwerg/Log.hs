module Zwerg.Log (Log, pushLogMsg, splitLog) where

import Zwerg.Prelude

import Data.Sequence (Seq)
import qualified Data.Sequence as S (empty, (|>))
import qualified Data.Text as T (splitAt, empty)

newtype Log = MkLog (Seq Text)
    deriving stock Generic
    deriving anyclass Binary

instance ZWrapped Log (Seq Text) where
  unwrap (MkLog l) = l
  wrap l = Just $ MkLog l

instance ZDefault Log where
    zDefault = MkLog S.empty


pushLogMsg :: Text -> Log -> Log
pushLogMsg message (MkLog l) = MkLog $ l S.|> message

splitLog :: Int -> Int -> Log -> [[Text]]
splitLog xMax yMax (MkLog l) = splitLog' xMax yMax (reverse $ toList l) []

splitLog' :: Int -> Int -> [Text] -> [[Text]] -> [[Text]]
splitLog' _ _ [] splitLogMsgs = splitLogMsgs
splitLog' xMax yMax (l:ls) splitLogMsgs =
  let newSplitMsg = splitLogMsg xMax l
  in if | length (concat splitLogMsgs) + length newSplitMsg > yMax ->
          reverse splitLogMsgs
        | length (concat splitLogMsgs) + length newSplitMsg == yMax ->
          reverse $ newSplitMsg : splitLogMsgs
        | otherwise -> splitLog' xMax yMax ls (newSplitMsg : splitLogMsgs)

splitLogMsg :: Int -> Text -> [Text]
splitLogMsg maxLen m = splitLogMsg' maxLen m []

splitLogMsg' :: Int -> Text -> [Text] -> [Text]
splitLogMsg' maxLen remainingMsg splitMsg =
  let (cutMsg, moreMsg) = T.splitAt maxLen remainingMsg
  in if | moreMsg == T.empty -> reverse $ cutMsg : splitMsg
        | otherwise -> splitLogMsg' maxLen moreMsg (cutMsg : splitMsg)
