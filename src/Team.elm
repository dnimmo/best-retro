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


type alias ID =
    String


type Team
    = Team
        { name : String
        , members : List ID
        , description : String
        , id : ID
        , admins : List ID
        , creator : ID
        }


getName : Team -> String
getName (Team team) =
    team.name


getMemberIds : Team -> List String
getMemberIds (Team team) =
    team.members


getDescription : Team -> String
getDescription (Team team) =
    team.description


getId : Team -> String
getId (Team team) =
    team.id


toRoute : Team -> Route
toRoute team =
    Route.Team (getId team)


userIsAdmin : Team -> ID -> Bool
userIsAdmin (Team { admins }) userId =
    List.member userId admins


getTeam : ID -> Maybe Team
getTeam id =
    List.head <|
        List.filter
            (\team ->
                getId team == id
            )
            teams


createTeam : String -> ID -> Team
createTeam name userId =
    Team
        { name = name
        , members = [ userId ]
        , description = ""
        , id = "3"
        , creator = userId
        , admins = [ userId ]
        }



-- Everything below here is just for testing


teams : List Team
teams =
    [ Team
        { name = "Team 1"
        , members = [ "1", "2", "3" ]
        , description = "The first test team"
        , id = "1"
        , creator = "1"
        , admins = [ "1" ]
        }
    , Team
        { name = "Team 2"
        , members = [ "1", "2", "3" ]
        , description = "The second test team"
        , id = "2"
        , creator = "1"
        , admins = [ "1" ]
        }
    ]
