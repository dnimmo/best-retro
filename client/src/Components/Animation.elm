module Components.Animation exposing (..)

import Element exposing (..)
import Html.Attributes exposing (attribute)


fadeInWithDelay : Float -> Element.Attribute msg
fadeInWithDelay delay =
    Element.htmlAttribute <|
        attribute "style" <|
            "animation: wait "
                ++ String.fromFloat delay
                ++ "s, "
                ++ "fadeIn 0.5s linear "
                ++ String.fromFloat delay
                ++ "s;"


fadeIn : Element.Attribute msg
fadeIn =
    fadeInWithDelay 0
