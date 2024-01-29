port module User exposing
    ( CreateUserParams
    , LogInParams
    , User
    , attemptToLogIn
    , createUser
    , decode
    , encode
    , getFocusedTeamId
    , getId
    , getName
    , getTeams
    , storeUser
    , userLoaded
    )

import Http
import Json.Decode as Decode
import Json.Encode as Encode
import UniqueID exposing (UniqueID)


type User
    = User Details


type alias Details =
    { id : UniqueID
    , name : String
    , email : String
    , teams : List UniqueID
    , focusedTeam : Maybe UniqueID
    }


getName : User -> String
getName (User { name }) =
    name


getId : User -> UniqueID
getId (User { id }) =
    id


getTeams : User -> List UniqueID
getTeams (User { teams }) =
    teams


getFocusedTeamId : User -> Maybe UniqueID
getFocusedTeamId (User { focusedTeam }) =
    focusedTeam


type alias CreateUserParams =
    { username : String
    , password : String
    , emailAddress : String
    }


createUser : CreateUserParams -> Cmd msg
createUser params =
    Cmd.none


port storeUser : Encode.Value -> Cmd msg


port userLoaded : (Decode.Value -> msg) -> Sub msg


encode : User -> Encode.Value
encode (User user) =
    Encode.object
        [ ( "id", UniqueID.encode user.id )
        , ( "name", Encode.string user.name )
        , ( "email", Encode.string user.email )
        , ( "teams", Encode.list UniqueID.encode user.teams )
        , ( "focusedTeam"
          , case user.focusedTeam of
                Just id ->
                    UniqueID.encode id

                Nothing ->
                    Encode.null
          )
        ]


decode : Decode.Decoder User
decode =
    let
        toUser id name email teams focusedTeam =
            User
                { id = id
                , name = name
                , email = email
                , teams = teams
                , focusedTeam = focusedTeam
                }
    in
    Decode.map5 toUser
        (Decode.field "id" UniqueID.decode)
        (Decode.field "name" Decode.string)
        (Decode.field "email" Decode.string)
        (Decode.field "teams" (Decode.list UniqueID.decode))
        (Decode.field "focusedTeam" (Decode.maybe UniqueID.decode))


type alias LogInParams =
    { emailAddress : String, password : String }


attemptToLogIn : LogInParams -> (Result Http.Error User -> msg) -> Cmd msg
attemptToLogIn _ responseMsg =
    Http.get
        { url = "http://localhost:8080/auth"
        , expect = Http.expectJson responseMsg decode
        }
