module Components.Font exposing (..)

import Element exposing (Attribute)
import Element.Font as Font


siteHeading : List (Attribute msg)
siteHeading =
    [ Font.size 32
    , Font.bold
    ]


title : List (Attribute msg)
title =
    [ Font.size 20
    , Font.bold
    ]
