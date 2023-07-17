{-# LANGUAGE QuasiQuotes #-}

-- | [DropBox oauth guide](https://developers.dropbox.com/oauth-guide)
module Network.OAuth2.Provider.Dropbox where

import Data.Aeson
import Data.Map.Strict qualified as Map
import Data.Set qualified as Set
import Data.Text.Lazy (Text)
import GHC.Generics
import Network.OAuth.OAuth2.HttpClient
import Network.OAuth2.Experiment
import URI.ByteString.QQ

data Dropbox = Dropbox deriving (Eq, Show)

type instance IdpUserInfo Dropbox = DropboxUser

defaultDropboxApp :: AuthorizationCodeApplication
defaultDropboxApp =
  AuthorizationCodeApplication
    { acClientId = ""
    , acClientSecret = ""
    , acScope = Set.empty
    , acAuthorizeState = "CHANGE_ME"
    , acAuthorizeRequestExtraParams = Map.empty
    , acRedirectUri = [uri|http://localhost|]
    , acName = "default-dropbox-app"
    , acTokenRequestAuthenticationMethod = ClientSecretBasic
    }

defaultDropboxIdp :: Idp Dropbox
defaultDropboxIdp =
  Idp
    { idpFetchUserInfo = \mgr at url -> authPostJSON @(IdpUserInfo Dropbox) mgr at url []
    , idpAuthorizeEndpoint = [uri|https://www.dropbox.com/1/oauth2/authorize|]
    , idpTokenEndpoint = [uri|https://api.dropboxapi.com/oauth2/token|]
    , idpUserInfoEndpoint = [uri|https://api.dropboxapi.com/2/users/get_current_account|]
    , idpDeviceAuthorizationEndpoint = Nothing
    }

newtype DropboxUserName = DropboxUserName {displayName :: Text}
  deriving (Show, Generic)

data DropboxUser = DropboxUser
  { email :: Text
  , name :: DropboxUserName
  }
  deriving (Show, Generic)

instance FromJSON DropboxUserName where
  parseJSON = genericParseJSON defaultOptions {fieldLabelModifier = camelTo2 '_'}

instance FromJSON DropboxUser
