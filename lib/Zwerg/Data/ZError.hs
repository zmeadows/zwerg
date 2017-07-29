module Zwerg.Data.ZError
  ( ZErrorLevel(..)
  , ZError(..)
  , ZConstructable(..)
  , throw
  ) where

import Protolude (Show, Read, Eq, Text, Int, MonadError, ($))
import Lens.Micro.Platform (makeClassy)
import Language.Haskell.TH
import Language.Haskell.TH.Syntax

data ZErrorLevel = PlayerWarning | EngineWarning | EngineFatal
  deriving (Show, Read, Eq)

data ZError = ZError
  { _file :: Text
  , _line :: Int
  , _errLevel :: ZErrorLevel
  , _explanation :: Text
  } deriving (Show, Read, Eq)
makeClassy ''ZError

{-
printZError :: ZError -> Text
printZError zerr = T.concat [
    "File: ", zerr ^. file, "\n",
    "Line: ", show $ zerr ^. line, "\n",
    "ErrorLevel: ", show $ zerr ^. errLevel, "\n",
    "Description: ", show $ zerr ^. description, "\n"
  ]
-}

throw :: Language.Haskell.TH.Syntax.Quasi m => m Exp
throw = runQ [| \l d -> throwError $ ZError __FILE__ __LINE__ l d|]

class ZConstructable a b | a -> b where
  zConstruct :: (MonadError ZError m) => b -> m a


