module Route exposing (Route(..), fromUrl, pushUrl, toUrlString)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s)


type Route
    = Home
    | CreateAccount
    | SignIn
    | Dashboard
    | MyTeams
    | Team String
    | CreateTeam


slugs =
    { landingPage = "home"
    , createAccount = "create-account"
    , signIn = "sign-in"
    , dashboard = "dashboard"
    , myTeams = "my-teams"
    , createTeam = "create-team"
    , viewingTeam = "team"
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

                Team teamId ->
                    slugs.viewingTeam ++ "/" ++ teamId
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
        , Parser.map Team (s slugs.viewingTeam </> Parser.string)
        ]


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse parser


pushUrl : Nav.Key -> Route -> Cmd msg
pushUrl key route =
    Nav.pushUrl key (toUrlString route)
