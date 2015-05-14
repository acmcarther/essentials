{-# LANGUAGE DeriveDataTypeable, NoMonomorphismRestriction, MultiParamTypeClasses, ImplicitParams #-}
-------------------------------------------------------------------------------
-- | Allows per workspace working directories
-- ----------------------------------------------------------------------------

module PerWorkspaceDirs (
                        currentWorkspace
                        , changeDir
                        , getDir
                        ) where

import qualified XMonad.Util.ExtensibleState as XS
import XMonad.Core
import XMonad.StackSet (currentTag)

data WorkingDirs = WD [(WorkspaceId, String)] deriving Typeable

instance ExtensionClass WorkingDirs where
  initialValue = WD []

changeDir :: String -> WorkspaceId -> X ()
changeDir dir ws = do (WD cdirs) <- XS.get
                      XS.put . WD $ (ws, dir) : filter (\(a,_) -> a /= ws) cdirs

getDir :: WorkspaceId -> X String
getDir ws = do (WD dirs) <- XS.get
               return $ maybe "~/" id (lookup ws dirs)

currentWorkspace :: X WorkspaceId
currentWorkspace = withWindowSet (return . currentTag)
