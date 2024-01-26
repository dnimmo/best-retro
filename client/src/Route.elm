module Route exposing (Route(..), fromUrl, pushUrl, toUrlString)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s)


type Route
    = Home
    | CreateAccount
    | ForgottenPassword
    | SignIn
    | Dashboard
    | MyTeams
    | Team String
    | CreateTeam
    | AddTeamMembers String
    | Board String
    | Error


slugs =
    { landingPage = "home"
    , createAccount = "create-account"
    , signIn = "sign-in"
    , forgottenPassword = "forgotten-password"
    , dashboard = "dashboard"
    , myTeams = "my-teams"
    , createTeam = "create-team"
    , viewingTeam = "team"
    , error = "something-has-gone-wrong"
    , viewingBoard = "board"
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

                ForgottenPassword ->
                    slugs.forgottenPassword

                Dashboard ->
                    slugs.dashboard

                MyTeams ->
                    slugs.myTeams

                CreateTeam ->
                    slugs.createTeam

                AddTeamMembers teamId ->
                    slugs.viewingTeam ++ "/" ++ teamId ++ "/add-members"

                Team teamId ->
                    slugs.viewingTeam ++ "/" ++ teamId

                Board boardId ->
                    slugs.viewingBoard ++ "/" ++ boardId

                Error ->
                    slugs.error
           )


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Home (s slugs.landingPage)
        , Parser.map CreateAccount (s slugs.createAccount)
        , Parser.map SignIn (s slugs.signIn)
        , Parser.map ForgottenPassword (s slugs.forgottenPassword)
        , Parser.map Dashboard (s slugs.dashboard)
        , Parser.map MyTeams (s slugs.myTeams)
        , Parser.map CreateTeam (s slugs.createTeam)
        , Parser.map AddTeamMembers (s slugs.viewingTeam </> Parser.string </> s "add-members")
        , Parser.map Team (s slugs.viewingTeam </> Parser.string)
        , Parser.map Board (s slugs.viewingBoard </> Parser.string)
        , Parser.map Error (s slugs.error)
        ]


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse parser


pushUrl : Nav.Key -> Route -> Cmd msg
pushUrl key route =
    Nav.pushUrl key (toUrlString route)
