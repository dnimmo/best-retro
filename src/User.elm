module User exposing
    ( CreateUserParams
    , User
    , createUser
    , encode
    , getId
    , getName
    , getTeams
    , getUser
    , storeUser
    )

import Json.Encode as Encode
import Team exposing (Team)


type alias ID =
    String


type User
    = User
        { id : ID
        , name : String
        , email : String
        , teams : List ID
        }


getName : User -> String
getName (User { name }) =
    name


getId : User -> ID
getId (User { id }) =
    id


getUser : User
getUser =
    -- Eventually this will actually fetch a user properly
    User
        { id = "123"
        , name = "John Doe"
        , email = "dnimmo@gmail.com"
        , teams = [ "1", "2" ]
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
        [ ( "id", Encode.string user.id )
        , ( "name", Encode.string user.name )
        , ( "email", Encode.string user.email )
        , ( "teams", Encode.list Encode.string user.teams )
        ]
