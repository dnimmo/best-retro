module Components.Icons exposing (..)

import Color
import Element exposing (Element, html)
import Material.Icons as Icons
import Material.Icons.Types as IconTypes
import Route exposing (Route)


iconSize : Int
iconSize =
    30


type Colour
    = Default
    | Inherit


defaultIconColour : IconTypes.Coloring
defaultIconColour =
    IconTypes.Color <| Color.rgb255 68 150 250


rightArrowInternal : Colour -> Element msg
rightArrowInternal colour =
    html <|
        Icons.keyboard_double_arrow_right iconSize <|
            case colour of
                Default ->
                    defaultIconColour

                Inherit ->
                    IconTypes.Inherit


rightArrow : Element msg
rightArrow =
    rightArrowInternal Default


home : Element msg
home =
    html <|
        Icons.home iconSize IconTypes.Inherit


start : Element msg
start =
    html <|
        Icons.flag iconSize defaultIconColour


stop : Element msg
stop =
    html <|
        Icons.front_hand iconSize defaultIconColour


continue : Element msg
continue =
    html <|
        Icons.restart_alt iconSize defaultIconColour


fromRoute : Route -> Element msg
fromRoute route =
    case route of
        Route.Dashboard ->
            home

        _ ->
            rightArrowInternal Inherit


add : Element msg
add =
    html <|
        Icons.add iconSize IconTypes.Inherit
