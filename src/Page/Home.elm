module Page.Home exposing (view)

import Components
import Element exposing (..)
import Route



-- VIEW


view : Element msg
view =
    column []
        [ Components.heading "Home"
        , Components.link Route.CreateAccount [] "Go to create account"
        , Components.link Route.SignIn [] "Go to sign in"
        ]
