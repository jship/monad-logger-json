{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
module TestCase.LogDebug.MetadataNoThreadContextYes
  ( testCase
  ) where

import Control.Monad.Logger.CallStack.JSON
  ( Loc(..), LogLevel(..), LoggedMessage(..), logDebug, withThreadContext
  )
import Data.Aeson ((.=))
import Data.Aeson.QQ.Simple (aesonQQ)
import Data.Time (UTCTime(..))
import TestCase (TestCase(..))
import qualified Data.Time as Time

testCase :: FilePath -> TestCase
testCase logFilePath =
  TestCase
    { actionUnderTest = do
        withThreadContext ["reqId" .= ("74ec1d0b" :: String)] do
          logDebug "No metadata"
    , logFilePath
    , expectedValue =
        [aesonQQ|
          {
            "time": "2022-05-07T20:03:54.0000000Z",
            "level": "debug",
            "location": {
              "package": "main",
              "module": "TestCase.LogDebug.MetadataNoThreadContextYes",
              "file": "test-suite/TestCase/LogDebug/MetadataNoThreadContextYes.hs",
              "line": 23,
              "char": 11
            },
            "context": {
              "tid": "ThreadId 1",
              "reqId": "74ec1d0b"
            },
            "message": {
              "text": "No metadata"
            }
          }
        |]
    , expectedPatch =
        [aesonQQ|
          [
            { "op": "replace", "path": "/context/tid", "value": "ThreadId 1" },
            { "op": "replace", "path": "/time", "value": "2022-05-07T20:03:54.0000000Z" }
          ]
        |]
    , expectedLoggedMessage =
        LoggedMessage
          { loggedMessageTimestamp =
              UTCTime
                { utctDay = Time.fromGregorian 2022 05 07
                , utctDayTime = 72234
                }
          , loggedMessageLevel = LevelDebug
          , loggedMessageLoc =
              Just Loc
                { loc_package = "main"
                , loc_module = "TestCase.LogDebug.MetadataNoThreadContextYes"
                , loc_filename = "test-suite/TestCase/LogDebug/MetadataNoThreadContextYes.hs"
                , loc_start = (23, 11)
                , loc_end = (0, 0)
                }
          , loggedMessageLogSource = Nothing
          , loggedMessageThreadContext =
              [ "reqId" .= ("74ec1d0b" :: String)
              , "tid" .= ("ThreadId 1" :: String)
              ]
          , loggedMessageMessage = "No metadata"
          }
    }
