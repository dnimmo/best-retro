module Page.Home exposing (view)

import Components
import Element exposing (..)
import Route



-- VIEW


view : Element msg
view =
    column []
        [ Components.heading1 "Home"
        , link []
            { url = Route.toUrlString Route.CreateAccount
            , label = text "Go to create account"
            }
        , link []
            { url = Route.toUrlString Route.SignIn
            , label = text "Go to sign in"
            }
        ]
