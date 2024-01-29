module Components.Transition exposing (..)

import Element exposing (..)
import Html.Attributes exposing (attribute)


common : List String -> Element.Attribute msg
common propertyList =
    Element.htmlAttribute <|
        attribute "style" <|
            "transition-property: "
                ++ String.join "," propertyList
                ++ " .3s"


duration : Float -> Element.Attribute msg
duration x =
    Element.htmlAttribute <|
        attribute "style" <|
            "transition-duration: "
                ++ String.fromFloat x
                ++ "s"
