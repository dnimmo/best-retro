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

import Json.Encode as Encode
import Team exposing (Team)
import UniqueID exposing (UniqueID)


type User
    = User
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


type alias LogInParams =
    { emailAddress : String, password : String }


attemptToLogIn : LogInParams -> Cmd msg
attemptToLogIn _ =
    Cmd.none


encode : User -> Encode.Value
encode (User user) =
    Encode.object
        [ ( "id", UniqueID.encode user.id )
        , ( "name", Encode.string user.name )
        , ( "email", Encode.string user.email )
        , ( "teams", Encode.list UniqueID.encode user.teams )
        ]
