module Components exposing (actionButton, card, currentPasswordDisplayed, currentPasswordHidden, globalLayout, heading1, heading2, internalLink, internalLinkCard, paragraph, plainText)

import Browser.Events exposing (Visibility(..))
import Element exposing (..)
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Route exposing (Route)


globalLayout : Element msg -> Html msg
globalLayout =
    layout
        [ width fill
        , height fill
        ]


heading1 : String -> Element msg
heading1 str =
    text str


heading2 : String -> Element msg
heading2 str =
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


internalLink : Route -> Element msg -> Element msg
internalLink route label =
    Element.link
        [ width fill
        , height fill
        , Font.underline
        ]
        { url = Route.toUrlString route
        , label = label
        }


paragraph : List String -> Element msg
paragraph text =
    Element.paragraph [] <|
        List.map Element.text text


card : List (Element msg) -> Element msg
card content =
    column
        [ width fill
        , height fill
        ]
        content


internalLinkCard : Route -> List (Element msg) -> Element msg
internalLinkCard route =
    internalLink route << card
