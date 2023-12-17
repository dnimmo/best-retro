module Components.Icons exposing (..)

import Color
import Element exposing (Element, html)
import Material.Icons as Icons
import Material.Icons.Types as IconTypes
import Route exposing (Route)


iconSize : Int
iconSize =
    30


smallIconSize : Int
smallIconSize =
    20


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
        Icons.flag 20 IconTypes.Inherit


stop : Element msg
stop =
    html <|
        Icons.front_hand 20 IconTypes.Inherit


continue : Element msg
continue =
    html <|
        Icons.restart_alt 20 IconTypes.Inherit


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


controls : Element msg
controls =
    html <|
        Icons.settings iconSize defaultIconColour


facilitator : Element msg
facilitator =
    html <|
        Icons.supervisor_account iconSize defaultIconColour


startSession : Element msg
startSession =
    html <|
        Icons.start smallIconSize IconTypes.Inherit


back : Element msg
back =
    html <|
        Icons.arrow_back smallIconSize IconTypes.Inherit


forward : Element msg
forward =
    html <|
        Icons.arrow_forward smallIconSize IconTypes.Inherit


status : Element msg
status =
    html <|
        Icons.info smallIconSize defaultIconColour


user : Element msg
user =
    html <|
        Icons.person smallIconSize defaultIconColour
