module Route exposing (Route(..), fromUrl, toUrlString)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s)


type Route
    = Home
    | CreateAccount
    | SignIn


slugs =
    { landingPage = "home"
    , createAccount = "create-account"
    , signIn = "sign-in"
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
           )


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Home (s slugs.landingPage)
        , Parser.map CreateAccount (s slugs.createAccount)
        , Parser.map SignIn (s slugs.signIn)
        ]


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse parser
