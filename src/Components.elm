module Components exposing (actionButton, currentPasswordDisplayed, currentPasswordHidden, globalLayout, heading1, plainText)

import Browser.Events exposing (Visibility(..))
import Element exposing (..)
import Element.Input as Input
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


type TextInput
    = PlainText
    | CurrentPassword { show : Bool }
    | NewPassword { show : Bool }
    | Email


textInput :
    TextInput
    ->
        { onChange : String -> msg
        , text : String
        , placeholder : Maybe (Input.Placeholder msg)
        , labelString : String
        }
    -> Element msg
textInput inputType { onChange, text, placeholder, labelString } =
    let
        attrs =
            []

        label =
            Input.labelAbove [] <| Element.text labelString

        args =
            { onChange = onChange
            , text = text
            , label = label
            , placeholder = placeholder
            }
    in
    case inputType of
        PlainText ->
            Input.text attrs args

        CurrentPassword { show } ->
            Input.currentPassword attrs
                { onChange = onChange
                , text = text
                , label = label
                , show = show
                , placeholder = placeholder
                }

        NewPassword { show } ->
            Input.newPassword attrs
                { onChange = onChange
                , text = text
                , label = label
                , show = show
                , placeholder = placeholder
                }

        Email ->
            Input.email attrs args


plainText :
    { onChange : String -> msg
    , text : String
    , placeholder : Maybe (Input.Placeholder msg)
    , labelString : String
    }
    -> Element msg
plainText =
    textInput PlainText


currentPasswordHidden :
    { onChange : String -> msg
    , text : String
    , placeholder : Maybe (Input.Placeholder msg)
    , labelString : String
    }
    -> Element msg
currentPasswordHidden =
    textInput <| CurrentPassword { show = False }


currentPasswordDisplayed :
    { onChange : String -> msg
    , text : String
    , placeholder : Maybe (Input.Placeholder msg)
    , labelString : String
    }
    -> Element msg
currentPasswordDisplayed =
    textInput <| CurrentPassword { show = True }


actionButton : { onPress : msg, labelString : String } -> Element msg
actionButton { onPress, labelString } =
    Input.button []
        { onPress = Just onPress
        , label = text labelString
        }
