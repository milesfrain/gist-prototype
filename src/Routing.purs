module MyRouting where

import Prelude
import Common (AuthCode(..), Compressed(..), GistID(..))
import Data.Foldable (oneOf)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Routing.Match (Match, lit, param, root)

data MyRoute
  = AuthorizeCallback AuthCode Compressed
  | LoadCompressed Compressed
  | LoadGist GistID

derive instance genericMyRoute :: Generic MyRoute _

instance showMyRoute :: Show MyRoute where
  show = genericShow

myRoute :: Match MyRoute
myRoute =
  root
    *> oneOf
        [ AuthorizeCallback <$> (AuthCode <$> (lit "callback" *> param "code")) <*> (Compressed <$> param "comp")
        , LoadCompressed <$> Compressed <$> param "comp"
        , LoadGist <$> GistID <$> param "gist"
        ]
