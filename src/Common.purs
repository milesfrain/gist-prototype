module Common where

import Prelude

appDomain :: String
--appDomain = "http://localhost:1234"
appDomain = "https://milesfrain.github.io"

-- This is for compatibilty with gh-pages root.
-- May be empty string for local development.
appRootNoSlash :: String
--appRootNoSlash = ""
appRootNoSlash = "gist-prototype"

-- Appending needs the slash,
-- but routing matching cannot have the slash.
appRootWithSlash :: String
appRootWithSlash = case appRootNoSlash of
  "" -> ""
  r -> "/" <> r

tokenServerUrl :: String
--tokenServerUrl = "http://localhost:7071/api/localtrigger"
tokenServerUrl = "https://gistfunction.azurewebsites.net/api/localtrigger?code=bLvuwjDHG1EWLo7J1IOA8xTRUlHCTi52bm/pvnXBHdUuWovaU5eXHg=="

newtype AuthCode
  = AuthCode String

instance showAuthCode :: Show AuthCode where
  show (AuthCode c) = c

newtype Compressed
  = Compressed String

instance showCompressed :: Show Compressed where
  show (Compressed c) = c

newtype Content
  = Content String

instance showContent :: Show Content where
  show (Content c) = c

newtype GistID
  = GistID String

instance showGistID :: Show GistID where
  show (GistID g) = g

newtype Token
  = Token String

instance showToken :: Show Token where
  show (Token t) = t
