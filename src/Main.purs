module Main (handler) where

import Prelude
import AWSLambdaEvent (LambdaEvent)
import Foreign.Object as FO
import AWSAPIGatewayResponse (AWSAPIGatewayResponse)
import Effect.Aff (Aff, throwError)
import Affjax.Node (request, defaultRequest, Error(..))
import Affjax.ResponseFormat as ResponseFormat
import Data.HTTP.Method (Method(..))
import Data.Either (Either(..))
import Data.Argonaut.Core as A
import Data.Maybe
import Effect.Exception (error)

failResponse :: Aff AWSAPIGatewayResponse
failResponse = pure { statusCode: 500, headers: FO.empty, body: "Failed" }

handler :: LambdaEvent -> Aff AWSAPIGatewayResponse
handler _ = do
    response <- request $ defaultRequest {
            url = "https://pokeapi.co/api/v2/pokemon/ditto",
            responseFormat = ResponseFormat.json
        }
    -- replace with purescript-fetch
    responseBody <- pure $ response <#> (\res -> res.body)
    bodyJson <- pure $ responseBody >>= (\json ->
        case A.toString json of
            Nothing -> Left RequestFailedError
            Just s -> Right s
    )

    case bodyJson of
        Left _ -> failResponse
        Right s -> pure { statusCode: 200, headers: FO.empty, body: s }
