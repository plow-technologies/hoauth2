{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}

module IDP.Auth0 where

import Data.Aeson
import Data.Default
import Data.Text.Lazy (Text)
import GHC.Generics
import Network.OAuth.OAuth2
import Types
import URI.ByteString.QQ

newtype Auth0 = Auth0 IDP
  deriving (HasLabel, HasAuthUri, HasTokenRefreshReq, HasTokenReq)

auth0Idp :: IDP
auth0Idp =
  IDP
    { idpName = "auth0",
      oauth2Config = auth0Key,
      oauth2Scopes = [],
      oauth2UserInfoUri = [uri|https://freizl.auth0.com/userinfo|]
    }

auth0Key :: OAuth2
auth0Key =
  def
    { oauth2AuthorizeEndpoint = [uri|https://freizl.auth0.com/authorize|],
      oauth2TokenEndpoint = [uri|https://freizl.auth0.com/oauth/token|]
    }

instance HasUserReq Auth0 where
  userReq (Auth0 IDP {..}) mgr at = do
    re <- authGetJSON mgr at oauth2UserInfoUri
    return (toLoginUser re)

data Auth0User = Auth0User
  { name :: Text,
    email :: Text
  }
  deriving (Show, Generic)

instance FromJSON Auth0User where
  parseJSON =
    genericParseJSON defaultOptions {fieldLabelModifier = camelTo2 '_'}

toLoginUser :: Auth0User -> LoginUser
toLoginUser ouser = LoginUser {loginUserName = name ouser}