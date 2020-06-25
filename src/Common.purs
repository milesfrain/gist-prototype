module Common where

import Prelude

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
