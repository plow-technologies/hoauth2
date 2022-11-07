{-# LANGUAGE CPP #-}

module Data.ByteString.Contrib where

import qualified Data.ByteString as BS
import qualified Data.ByteString.Lazy as BSL

bsToStrict :: BSL.ByteString -> BS.ByteString
#if MIN_VERSION_bytestring(0,11,0)
bsToStrict = BS.toStrict
#else
bsToStrict = BSL.toStrict
#endif

bsFromStrict :: BS.ByteString -> BSL.ByteString
#if MIN_VERSION_bytestring(0,11,0)
bsFromStrict = BS.fromStrict
#else
bsFromStrict = BSL.fromStrict
#endif
