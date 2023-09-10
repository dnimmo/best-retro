module User exposing
    ( CreateUserParams
    , LogInParams
    , User
    , attemptToLogIn
    , createUser
    , encode
    , getId
    , getName
    , getTeams
    , getUser
    , storeUser
    )

import Http
import Json.Encode as Encode
import Json.Decode.Pipeline as Decode
import Team exposing (Team)
import UniqueID exposing (UniqueID)
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline

type User
    = User Details

type alias Details =
    { id : UniqueID
    , name : String
    , email : String
    , teams : List UniqueID
    }


getName : User -> String
getName (User { name }) =
    name


getId : User -> UniqueID
getId (User { id }) =
    id


getUser : User
getUser =
    -- Eventually this will actually fetch a user properly
    User
        { id = UniqueID.generateDefaultID
        , name = "John Doe"
        , email = "dnimmo@gmail.com"
        , teams = [ UniqueID.generateDefaultID ]
        }


getTeams : User -> List Team
getTeams (User { teams }) =
    teams
        |> List.map (\id -> Team.getTeam id)
        |> List.filterMap identity


type alias CreateUserParams =
    { username : String
    , password : String
    , emailAddress : String
    }


createUser : CreateUserParams -> Cmd msg
createUser params =
    Cmd.none


storeUser : Encode.Value -> Cmd msg
storeUser user =
    Cmd.none




encode : User -> Encode.Value
encode (User user) =
    Encode.object
        [ ( "id", UniqueID.encode user.id )
        , ( "name", Encode.string user.name )
        , ( "email", Encode.string user.email )
        , ( "teams", Encode.list UniqueID.encode user.teams )
        ]



decode : Decode.Decoder User
decode =
    let 
        toUser id name email teams =
            User
                { id = id
                , name = name
                , email = email
                , teams = teams
                }
    in 
    Decode.map4 toUser
        (Decode.field "id" UniqueID.decode)
        (Decode.field "name" Decode.string)
        (Decode.field "email" Decode.string)
        (Decode.field "teams" (Decode.list UniqueID.decode))
        


type alias LogInParams =
    { emailAddress : String, password : String }


attemptToLogIn : LogInParams -> (Result Http.Error User -> msg) -> Cmd msg
attemptToLogIn _ responseMsg =
    Http.get
        { url = "http://localhost:8080/user"
        , expect = Http.expectJson responseMsg decode
        }