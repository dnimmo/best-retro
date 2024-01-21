module Team exposing
    ( MemberDetails
    , Team
    , createTeam
    , getActionItems
    , getDescription
    , getMemberDetails
    , getMemberIds
    , getName
    , getTeam
    , getTeamsForUser
    , testTeam
    , toRoute
    , userIsAdmin
    )

import ActionItem exposing (ActionItem)
import Http
import Json.Decode as Decode
import Route exposing (Route(..))
import Time
import UniqueID exposing (UniqueID)


type Team
    = Team
        { name : String
        , members : List UniqueID
        , id : UniqueID
        , admins : List UniqueID
        , creator : UniqueID
        }


getName : Team -> String
getName (Team team) =
    team.name


getMemberIds : Team -> List UniqueID
getMemberIds (Team team) =
    team.members


getDescription : Team -> String
getDescription (Team team) =
    team.name


getId : Team -> UniqueID
getId (Team team) =
    team.id


toRoute : Team -> Route
toRoute team =
    Route.Team (UniqueID.toString <| getId team)


userIsAdmin : Team -> UniqueID -> Bool
userIsAdmin (Team { admins }) userId =
    List.member userId admins


getTeam : UniqueID -> Maybe Team
getTeam id =
    List.head <|
        List.filter
            (\team ->
                getId team == id
            )
            teams


createTeam : Time.Posix -> String -> UniqueID -> Team
createTeam time name userId =
    Team
        { name = name
        , members = [ userId ]
        , id = UniqueID.generateID time
        , creator = userId
        , admins = [ userId ]
        }


getTeamsForUser : UniqueID -> (Result Http.Error (List Team) -> msg) -> Cmd msg
getTeamsForUser userId responseMsg =
    let
        x =
            Debug.log "use userId" userId
    in
    Http.get
        { url = "http://localhost:8080/teams"
        , expect = Http.expectJson responseMsg decodeTeams
        }


decode : Decode.Decoder Team
decode =
    let
        toTeam name members id admins creator =
            Team
                { name = name
                , members = members
                , id = id
                , admins = admins
                , creator = creator
                }
    in
    Decode.map5 toTeam
        (Decode.field "name" Decode.string)
        (Decode.field "members" (Decode.list UniqueID.decode))
        (Decode.field "id" UniqueID.decode)
        (Decode.field "admins" (Decode.list UniqueID.decode))
        (Decode.field "creator" UniqueID.decode)


decodeTeams : Decode.Decoder (List Team)
decodeTeams =
    Decode.list decode


type alias MemberDetails =
    { name : String
    , email : String
    , id : UniqueID
    }


getMemberDetails : UniqueID -> (Result Http.Error (List MemberDetails) -> msg) -> Cmd msg
getMemberDetails teamId responseMsg =
    let
        x =
            Debug.log "todo use teamId" teamId

        decodeMemberDetails =
            Decode.map3 MemberDetails
                (Decode.field "name" Decode.string)
                (Decode.field "email" Decode.string)
                (Decode.field "id" UniqueID.decode)
    in
    Http.get
        { url = "http://localhost:8080/team/someId"
        , expect =
            Http.expectJson
                responseMsg
            <|
                Decode.list decodeMemberDetails
        }


getActionItems : UniqueID -> (Result Http.Error (List ActionItem) -> msg) -> Cmd msg
getActionItems teamId responseMsg =
    let
        x =
            Debug.log "todo use teamId" teamId
    in
    Http.get
        { url = "http://localhost:8080/actions/team/someId"
        , expect =
            Http.expectJson
                responseMsg
            <|
                Decode.list ActionItem.decode
        }



-- Everything below here is just for testing


testTeam : Team
testTeam =
    Team
        { name = "Team 1"
        , members =
            [ UniqueID.generateID <|
                Time.millisToPosix 800000000
            ]
        , id = UniqueID.generateDefaultID
        , creator =
            UniqueID.generateID <|
                Time.millisToPosix 800000000
        , admins =
            [ UniqueID.generateID <|
                Time.millisToPosix 800000000
            ]
        }


teams : List Team
teams =
    [ testTeam
    , Team
        { name = "Team 2"
        , members =
            [ UniqueID.generateID <|
                Time.millisToPosix 800000000
            ]
        , id = UniqueID.generateDefaultID
        , creator =
            UniqueID.generateID <|
                Time.millisToPosix 800000000
        , admins =
            [ UniqueID.generateID <|
                Time.millisToPosix 800000000
            ]
        }
    ]
