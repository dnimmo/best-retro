module Team exposing
    ( Team
    , createTeam
    , getDescription
    , getMemberIds
    , getName
    , getTeam
    , toRoute
    , userIsAdmin
    )

import Route exposing (Route(..))
import Time
import UniqueID exposing (UniqueID)


type Team
    = Team
        { name : String
        , members : List UniqueID
        , description : String
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
    team.description


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
        , description = ""
        , id = UniqueID.generateID time
        , creator = userId
        , admins = [ userId ]
        }



-- Everything below here is just for testing


teams : List Team
teams =
    [ Team
        { name = "Team 1"
        , members = [ UniqueID.generateDefaultID ]
        , description = "The first test team"
        , id = UniqueID.generateDefaultID
        , creator = UniqueID.generateDefaultID
        , admins = [ UniqueID.generateDefaultID ]
        }
    , Team
        { name = "Team 2"
        , members = [ UniqueID.generateDefaultID ]
        , description = "The second test team"
        , id = UniqueID.generateDefaultID
        , creator = UniqueID.generateDefaultID
        , admins = [ UniqueID.generateDefaultID ]
        }
    ]
