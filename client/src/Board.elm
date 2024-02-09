module Board exposing (Board, createNew, getId, getName)

import Http
import Json.Decode as Decode exposing (Decoder)
import UniqueID exposing (UniqueID)


type Board
    = Board
        { id : UniqueID
        , name : String
        }


getId : Board -> UniqueID
getId (Board { id }) =
    id


getName : Board -> String
getName (Board { name }) =
    name


decode : Decoder Board
decode =
    let
        toBoard id name =
            Board { id = id, name = name }
    in
    Decode.map2 toBoard
        (Decode.field "id" UniqueID.decode)
        (Decode.field "name" Decode.string)


type alias CreateBoardParams =
    ()


createNew : CreateBoardParams -> (Result Http.Error Board -> msg) -> Cmd msg
createNew _ responseMsg =
    Http.get
        { url = "http://localhost:8080/board/new"
        , expect = Http.expectJson responseMsg decode
        }
