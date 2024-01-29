module Components.Font exposing (..)

import Element exposing (..)
import Element.Font as Font
import Element.Region as Region


siteHeading : List (Attribute msg)
siteHeading =
    [ Font.size 32
    , Font.bold
    ]


heading : String -> Element msg
heading str =
    paragraph
        [ Font.extraBold
        , Region.heading 1
        , Font.size 26
        , width fill
        , paddingXY 0 20
        ]
        [ el [ width fill ] <| text str ]


headingTwo : String -> Element msg
headingTwo str =
    paragraph
        [ Font.extraBold
        , Region.heading 2
        , Font.size 22
        , width fill
        , paddingXY 0 12
        ]
        [ el [ width fill ] <| text str ]


title : List (Attribute msg)
title =
    [ Font.size 20
    , Font.bold
    ]


label : List (Attribute msg)
label =
    [ Font.size 16
    ]
