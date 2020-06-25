module Editor where

import Prelude
import Common (Compressed(..), Content(..), GistID(..), Token)
import Control.Monad.State (class MonadState)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class.Console (log)
import Halogen (liftEffect)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP
import LzString (compressToEncodedURIComponent, decompressFromEncodedURIComponent)
import MyRouting (MyRoute(..))
import Request (ghCreateGist, ghGetGist, ghRequestToken)
import Web.HTML (window)
import Web.HTML.Location (setHref)
import Web.HTML.Window (location)

type SetRoute
  = String -> Effect Unit

type Input
  = SetRoute

-- Will assume token is valid if it exists. May refresh to reset.
type State
  = { route :: Maybe MyRoute
    , token :: Maybe Token
    , setRoute :: SetRoute
    , gistID :: Maybe GistID
    , content :: Content
    }

initialState :: Input -> State
initialState setRoute =
  { route: Nothing
  , token: Nothing
  , setRoute
  , gistID: Nothing
  , content: Content "Welcome"
  }

-- Query must be (Type -> Type)
data Query a
  = Nav MyRoute a

data Action
  = SaveGist
  | SetContent Content

component :: forall o m. MonadAff m => H.Component HH.HTML Query Input o m
component =
  H.mkComponent
    { initialState
    , render
    , eval:
        H.mkEval
          $ H.defaultEval
              { handleQuery = handleQuery
              , handleAction = handleAction
              }
    }

compress :: Content -> Compressed
compress (Content c) = Compressed $ compressToEncodedURIComponent c

decompress :: Compressed -> Content
decompress (Compressed c) = Content $ decompressFromEncodedURIComponent c

render :: forall m. MonadAff m => State -> H.ComponentHTML Action () m
render state =
  let
    gistButtonOrLink = case state.gistID of
      Nothing ->
        HH.button
          [ HE.onClick \_ -> Just SaveGist
          ]
          [ HH.text "Save Gist"
          ]
      Just (GistID id) ->
        HH.a
          [ HP.href $ "https://gist.github.com/" <> id
          , HP.target "_blank" -- Open in new tab
          ]
          [ HH.text "View Gist" ]
  in
    HH.div_
      [ HH.div_
          [ HH.textarea
              [ HP.value $ show state.content
              , HE.onValueInput \str -> Just (SetContent $ Content str)
              , HP.rows 20
              , HP.cols 80
              ]
          ]
      , HH.div_ [ gistButtonOrLink ]
      ]

handleQuery ∷ forall a o m. MonadAff m => Query a → H.HalogenM State Action () o m (Maybe a)
handleQuery (Nav route a) = do
  -- multiple state modifications, but not a performance issue now.
  H.modify_ _ { route = Just route }
  case route of
    AuthorizeCallback authCode compressed -> do
      -- Todo - should probably render a "saving" dialog or something
      log "in auth callback"
      -- Immediately show new content
      H.modify_ _ { content = decompress compressed }
      -- Make token request to private app server
      res <- liftAff $ ghRequestToken authCode
      case res of
        Left err -> log err
        Right token -> do
          -- Save token
          H.modify_ _ { token = Just token }
          -- Save gist
          doSaveGist token
    LoadCompressed compressed -> do
      let
        content = decompress compressed
      log $ "Got content from url: " <> show content
      H.modify_ _ { content = content }
    LoadGist gistId -> do
      eitherContent <- liftAff $ ghGetGist gistId
      let
        content = case eitherContent of
          Left err -> Content err
          Right c -> c
      log $ "Got content from gist: " <> show content
      H.modify_ _ { content = content, gistID = Just gistId }
  -- Required boilerplate for handleQuery
  pure (Just a)

-- Token is a parameter rather than picked-up from state
-- to ensure it is not Nothing
doSaveGist ∷ forall m. MonadState State m => MonadAff m => Token -> m Unit
doSaveGist token = do
  st <- H.get
  eitherId <- liftAff $ ghCreateGist token st.content
  case eitherId of
    Left err -> log err
    Right id -> do
      H.modify_ _ { gistID = Just id }
      liftEffect $ st.setRoute $ "/?gist=" <> (show id)

handleAction ∷ forall o m. MonadAff m => Action -> H.HalogenM State Action () o m Unit
handleAction = case _ of
  SaveGist -> do
    st <- H.get
    log $ "incoming content in SaveGist: " <> show st.content
    case st.token of
      Nothing -> liftEffect $ ghAuthorize st.content
      Just token -> doSaveGist token
  -- New content clears existing gistID
  SetContent content -> do
    st <- H.get
    log $ "writing in SetContent: " <> show content
    H.modify_ _ { gistID = Nothing, content = content }
    liftEffect $ st.setRoute $ "/?comp=" <> (show $ compress content)

ghAuthorize :: Content -> Effect Unit
ghAuthorize content = do
  win <- window
  loc <- location win
  -- I believe it's fine for client ID to be public information
  let
    authUrl =
      "https://github.com/login/oauth/authorize?"
        <> "client_id=bbaa8fdc61cceb40c899&scope=gist"
        <> "&redirect_uri=http://localhost:1234/callback"
        <> "?comp="
        <> (show $ compress content)
  setHref authUrl loc
