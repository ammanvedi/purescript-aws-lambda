module Main (handler) where

import Prelude
import AWSLambdaEvent (LambdaEvent)
import Foreign.Object as FO
import AWSAPIGatewayResponse (AWSAPIGatewayResponse)
import Effect.Aff (Aff)
import Data.Either (Either(..))
import Data.Argonaut.Core as A
import Data.Argonaut.Decode (JsonDecodeError(..))
import Data.Argonaut.Encode.Class (class EncodeJson, encodeJson)
import Data.Argonaut.Decode.Class (class DecodeJson)
import Data.Maybe (Maybe(..))
import Data.HTTP.Method (Method(GET))
import Fetch (fetch)
import Effect (Effect)
import Effect.Uncurried (EffectFn1)
import Fetch.Argonaut.Json (fromJson)
import Control.Promise (fromAff, Promise)
import Effect.Aff.Compat (mkEffectFn1)
import Control.Monad.Error.Class (catchError)

type JsonKey = String

-- Definition and typeclass instances for the response from the Pokeomon API

newtype PokemonResponse = PokemonResponse { id:: Number, name :: String }

instance pokemonResponseDecode :: DecodeJson PokemonResponse where
    decodeJson j = do
        jsonObj <- case A.toObject j of
                    Just o -> Right o
                    Nothing -> Left (TypeMismatch "object could not be parsed to a object")
        id <- jsonLookupNumber "id" jsonObj
        name <- jsonLookupString "name" jsonObj
        pure $ PokemonResponse { id: id, name: name}

instance pokemonResponseEncode :: EncodeJson PokemonResponse where
    encodeJson (PokemonResponse p) = encodeJson p

failResponse :: Aff AWSAPIGatewayResponse
failResponse = pure { statusCode: 500, headers: FO.empty, body: "Failed" }



jsonLookup :: JsonKey -> FO.Object A.Json -> Either JsonDecodeError A.Json
jsonLookup k o = case FO.lookup k o of
                    Just j -> Right j
                    Nothing -> Left (AtKey k (MissingValue))

jsonLookupNumber :: JsonKey -> FO.Object A.Json -> Either JsonDecodeError Number
jsonLookupNumber k o = do
    rawJsonValue <- jsonLookup k o
    parsed <- case A.toNumber rawJsonValue of
                Just num -> Right num
                Nothing -> Left (TypeMismatch "value was not a number")
    pure parsed

jsonLookupString :: JsonKey -> FO.Object A.Json -> Either JsonDecodeError String
jsonLookupString k o = do
    rawJsonValue <- jsonLookup k o
    parsed <- case A.toString rawJsonValue of
                Just num -> Right num
                Nothing -> Left (TypeMismatch "value was not a string")
    pure parsed

run :: LambdaEvent -> Aff AWSAPIGatewayResponse
run _ = do
            response <- fetch "https://pokeapi.co/api/v2/pokemon/ditto"
                {
                    method: GET,
                    headers: { "Content-Type": "application/json" }
                }
            responseBody :: PokemonResponse <- fromJson response.json
            jsonString <- pure $ A.stringify $ encodeJson responseBody
            pure { statusCode: 200, headers: FO.empty, body: jsonString }

handlerCurried :: LambdaEvent -> Effect (Promise AWSAPIGatewayResponse)
                    -- convert from an Aff to an Eff
handlerCurried e = fromAff
                    -- Handle the failure scenario
                    $ catchError
                        -- Actually create the effect that will run
                        (run e)
                        -- If it fails then return a failure response
                        (\_ -> failResponse)

-- We want to export an uncurried version of the function so we can call
-- handler(event) and get back a promise instead of handler(event)()
handler :: EffectFn1 LambdaEvent (Promise AWSAPIGatewayResponse)
handler = mkEffectFn1 handlerCurried

