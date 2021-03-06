module Zwerg.Generator.Verify (verifyAndReturn) where

import Zwerg.Generator

verifyComponent :: Component a -> UUID -> MonadCompRead ()
verifyComponent !comp !uuid =
  whenM (not <$> canViewComp uuid comp) $ do
      cn <- viewCompName comp
      debug $ "VERIFICATION FAILURE: " <> cn <> " " <> show (unwrap uuid)

verifyAndReturn :: UUID -> MonadCompRead UUID
verifyAndReturn entityUUID = do
  etype <- entityType <~> entityUUID
  verifyAndReturn' entityUUID etype
  return entityUUID

--TODO: continually expand this as new components are added
--and new features are added to the game
verifyAndReturn' :: UUID -> EntityType -> MonadCompRead ()
verifyAndReturn' uuid Enemy = do
    verifyComponent name uuid
    verifyComponent occupants uuid
    verifyComponent itemType uuid
  -- $(hasAll "uuid"
  --  [ "name" , "description" , "species"
  --  , "glyph" , "hp" , "entityType"
  --  , "stats" , "aiType" , "viewRange"
  --  ]
  -- )

verifyAndReturn' _ Level = return ()
    -- $(hasAll "uuid"
    -- $([ "name" , "description", "entityType" ]
   -- $(
   --TODO: loop over entities on level and do extra verification
   -- for example, require all Enemies in level to have position, tileOn, etc.

verifyAndReturn' _ Tile = return ()

verifyAndReturn' _ Item = return ()

verifyAndReturn' _ _ = return ()

