module Main (handler) where

import Prelude

import AWSLambdaEvent (LambdaEvent)

handler :: LambdaEvent -> String
handler _ = "ABDD"