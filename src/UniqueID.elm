module UniqueID exposing (UniqueID, decode, encode, generateDefaultID, generateID, getID, toString)

import Json.Decode as Decode
import Json.Encode as Encode
import Random
import Time
import UUID exposing (UUID)


type UniqueID
    = UniqueID UUID


getID : UniqueID -> UUID
getID (UniqueID id) =
    id


generateID : Time.Posix -> UniqueID
generateID posix =
    Random.step UUID.generator
        (Random.initialSeed <| Time.posixToMillis posix)
        |> Tuple.first
        |> UniqueID


generateDefaultID : UniqueID
generateDefaultID =
    -- This function will always return the same ID
    generateID <| Time.millisToPosix 0


toString : UniqueID -> String
toString (UniqueID id) =
    UUID.toString id


encode : UniqueID -> Encode.Value
encode (UniqueID id) =
    Encode.string <| UUID.toString id


decode : Decode.Decoder UniqueID
decode =
    Decode.string
        |> Decode.andThen
            (\str ->
                case UUID.fromString str of
                    Ok id ->
                        Decode.succeed <| UniqueID id

                    Err _ ->
                        Decode.fail <| "Invalid UUID"
            )
