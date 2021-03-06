module Zwerg.Prelude
  ( show
  , module EXPORTED
  ) where

import Prelude as EXPORTED hiding (id, (.), show, Monoid(..))
import qualified Prelude as P (show)

import Zwerg.Data.UUID as EXPORTED
import Zwerg.Data.ZColor as EXPORTED
import Zwerg.Prelude.Class as EXPORTED
import Zwerg.Prelude.Primitives as EXPORTED

import Control.Arrow as EXPORTED hiding ((<+>))
import Control.Category as EXPORTED
import Control.Monad.Random.Class as EXPORTED hiding (fromList)
import Control.Monad.Reader as EXPORTED
import Control.Monad.State.Strict as EXPORTED

import Data.Bifunctor as EXPORTED (bimap)
import Data.Binary as EXPORTED (Binary)
import Data.List.NonEmpty as EXPORTED (NonEmpty(..),)
import Data.Maybe as EXPORTED (catMaybes, mapMaybe)
import Data.Semigroup as EXPORTED
import Data.String.Conv (StringConv, toS)
import Data.Text as EXPORTED (Text, pack, unpack, singleton, append)
import Data.Traversable as EXPORTED (forM)
import Data.Tuple.Sequence as EXPORTED (sequenceT)

import GHC.Exts as EXPORTED (IsList(..))
import GHC.Generics as EXPORTED (Generic)
import GHC.Stack as EXPORTED (HasCallStack, CallStack, callStack, prettyCallStack)

{-# SPECIALIZE show :: Show a => a -> Text  #-}
{-# SPECIALIZE show :: Show a => a -> String  #-}
show :: (Show a, StringConv String b) => a -> b
show x = toS (P.show x)

