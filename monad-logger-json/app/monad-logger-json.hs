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
--   "timestamp": "2022-05-03T01:18:44.0026364Z",
--   "level": "info",
--   "message": {
--     "text": "some message text"
--   }
-- }
-- {
--   "timestamp": "2022-05-03T01:18:44.0027108Z",
--   "level": "debug",
--   "message": {
--     "text": "some message text"
--   }
-- }
-- {
--   "timestamp": "2022-05-03T01:18:44.0027213Z",
--   "level": "debug",
--   "location": {
--     "package": "main",
--     "module": "Main",
--     "file": "app/monad-logger-json.hs",
--     "line": 105,
--     "char": 5
--   },
--   "message": {
--     "text": "Some log message without metadata"
--   }
-- }
-- {
--   "timestamp": "2022-05-03T01:18:44.0027377Z",
--   "level": "warn",
--   "location": {
--     "package": "main",
--     "module": "Main",
--     "file": "app/monad-logger-json.hs",
--     "line": 108,
--     "char": 5
--   },
--   "message": {
--     "text": "foo bar baz"
--   }
-- }
-- {
--   "timestamp": "2022-05-03T01:18:44.0027493Z",
--   "level": "warn",
--   "location": {
--     "package": "main",
--     "module": "Main",
--     "file": "app/monad-logger-json.hs",
--     "line": 109,
--     "char": 5
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
--   "timestamp": "2022-05-03T01:18:44.0027636Z",
--   "level": "warn",
--   "location": {
--     "package": "main",
--     "module": "Main",
--     "file": "app/monad-logger-json.hs",
--     "line": 113,
--     "char": 5
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
  withCommonMeta ["reqId" .= (123 :: Int)] $
    withCommonMeta ["stuff" .= ("things" :: Text)] $
      withCommonMeta ["stuff" .= ("things2" :: Text)] $
        withCommonMeta ["reqId" .= ("345" :: Text)] $
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
