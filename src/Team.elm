module Team exposing
    ( Team
    , fakeTeams
    , getDescription
    , getMemberIds
    , getName
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


userIsAdmin : Team -> String -> Bool
userIsAdmin (Team { admins }) userId =
    List.member userId admins



-- EVEYTHING BELOW IS JUST FOR TESTING


fakeTeams : List Team
fakeTeams =
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
