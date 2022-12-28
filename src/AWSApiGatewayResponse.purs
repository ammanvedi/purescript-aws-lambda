module AWSAPIGatewayResponse where

import Foreign.Object as FO

type AWSAPIGatewayResponse = {
    statusCode :: Int,
    headers :: FO.Object String,
    body :: String
}