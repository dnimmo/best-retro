module Route exposing (Route(..), fromUrl, toUrlString)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s)


type Route
    = Home
    | CreateAccount
    | SignIn
    | Dashboard
    | MyTeams
    | CreateTeam


slugs =
    { landingPage = "home"
    , createAccount = "create-account"
    , signIn = "sign-in"
    , dashboard = "dashboard"
    , myTeams = "my-teams"
    , createTeam = "create-team"
    }


toUrlString : Route -> String
toUrlString route =
    "/"
        ++ (case route of
                Home ->
                    slugs.landingPage

                CreateAccount ->
                    slugs.createAccount

                SignIn ->
                    slugs.signIn

                Dashboard ->
                    slugs.dashboard

                MyTeams ->
                    slugs.myTeams

                CreateTeam ->
                    slugs.createTeam
           )


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Home (s slugs.landingPage)
        , Parser.map CreateAccount (s slugs.createAccount)
        , Parser.map SignIn (s slugs.signIn)
        , Parser.map Dashboard (s slugs.dashboard)
        , Parser.map MyTeams (s slugs.myTeams)
        , Parser.map CreateTeam (s slugs.createTeam)
        ]


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse parser
