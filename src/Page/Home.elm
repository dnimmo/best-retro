module Page.Home exposing (view)

import Components
import Element exposing (..)
import Route



-- VIEW


view : Element msg
view =
    column []
        [ Components.heading1 "Home"
        , Components.internalLink Route.CreateAccount "Go to create account"
        , Components.internalLink Route.SignIn "Go to sign in"
        ]
