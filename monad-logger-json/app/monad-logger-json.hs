{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TypeApplications #-}
module Main
  ( main
  ) where

import Control.Monad.Logger.CallStack.JSON
import Data.Aeson ((.=))
import Data.Text (Text)
import qualified Control.Monad.Logger.CallStack as Log

-- $ stack run monad-logger-json | jq
-- {
--   "time": "2022-05-07T19:30:58.7354333Z",
--   "level": "info",
--   "context": {
--     "stuff": "things2",
--     "reqId": "345"
--   },
--   "message": {
--     "text": "some message text"
--   }
-- }
-- {
--   "time": "2022-05-07T19:30:58.7355133Z",
--   "level": "debug",
--   "context": {
--     "stuff": "things2",
--     "reqId": "345"
--   },
--   "message": {
--     "text": "some message text"
--   }
-- }
-- {
--   "time": "2022-05-07T19:30:58.7355242Z",
--   "level": "debug",
--   "location": {
--     "package": "main",
--     "module": "Main",
--     "file": "app/monad-logger-json.hs",
--     "line": 137,
--     "char": 13
--   },
--   "context": {
--     "stuff": "things2",
--     "reqId": "345"
--   },
--   "message": {
--     "text": "Some log message without metadata"
--   }
-- }
-- {
--   "time": "2022-05-07T19:30:58.7355428Z",
--   "level": "warn",
--   "location": {
--     "package": "main",
--     "module": "Main",
--     "file": "app/monad-logger-json.hs",
--     "line": 140,
--     "char": 13
--   },
--   "context": {
--     "stuff": "things2",
--     "reqId": "345"
--   },
--   "message": {
--     "text": "foo bar baz"
--   }
-- }
-- {
--   "time": "2022-05-07T19:30:58.7355557Z",
--   "level": "warn",
--   "location": {
--     "package": "main",
--     "module": "Main",
--     "file": "app/monad-logger-json.hs",
--     "line": 141,
--     "char": 13
--   },
--   "context": {
--     "stuff": "things2",
--     "reqId": "345"
--   },
--   "message": {
--     "text": "quux stuff",
--     "meta": {
--       "bloorp": 42,
--       "bonk": "abc"
--     }
--   }
-- }
-- {
--   "time": "2022-05-07T19:30:58.7355695Z",
--   "level": "warn",
--   "location": {
--     "package": "main",
--     "module": "Main",
--     "file": "app/monad-logger-json.hs",
--     "line": 145,
--     "char": 13
--   },
--   "context": {
--     "stuff": "things2",
--     "reqId": "345"
--   },
--   "message": {
--     "text": "quux stuff 2",
--     "meta": {
--       "foo": 42,
--       "bar": null
--     }
--   }
-- }

main :: IO ()
main = do
--  Log.runFileLoggingT "foo.txt" do
--    logInfo "some message text"
--    logDebug "some message text"
--    logDebug $ "some message text" :# ["abc" .= (42 :: Int)]
  withThreadContext ["reqId" .= (123 :: Int)] $
    withThreadContext ["stuff" .= ("things" :: Text)] $
      withThreadContext ["stuff" .= ("things2" :: Text)] $
        withThreadContext ["reqId" .= ("345" :: Text)] $
          runStdoutLoggingT do
            -- We can use functions from 'monad-logger' directly if we want, though we
            -- won't be able to log pairs with these functions.
            Log.logInfoN "some message text"
            Log.logDebugN "some message text"

            -- Pretend 'logSomeJSON' was instead some standard 'monad-logger' name
            -- like 'logInfoNS' (it isn't right now out of laziness/quick testing).
            --
            -- We can leverage the 'IsString' instance of 'Message' in the case when
            -- we don't have pairs.
            logDebug "Some log message without metadata"

            -- When we do have pairs, we can just tack on the pairs list with ':#'.
            logWarn $ "foo bar baz" :# []
            logWarn $ "quux stuff" :#
              [ "bloorp" .= (42 :: Int)
              , "bonk" .= ("abc" :: Text)
              ]
            logWarn $ "quux stuff 2" :#
              [ "foo" .= Just @Int 42
              , "bar" .= Nothing @Int
              ]
