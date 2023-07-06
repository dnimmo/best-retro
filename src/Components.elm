module Components exposing (..)

import Element exposing (..)
import Html exposing (Html)


globalLayout : Element msg -> Html msg
globalLayout =
    layout
        [ width fill
        , height fill
        ]


heading1 : String -> Element msg
heading1 str =
    text str
