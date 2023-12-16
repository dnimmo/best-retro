module Components.Input exposing
    ( actionButton
    , currentPasswordDisplayed
    , currentPasswordHidden
    , form
    , inputFieldWithInsetButton
    , leftIconButton
    , plainText
    , rightIconButton
    )

import Components exposing (corners, edges)
import Components.Colours as Colours
import Components.Icons as Icons
import Components.Layout as Layout
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Html.Events
import Json.Decode as Decode


onEnter : msg -> Element.Attribute msg
onEnter msg =
    Element.htmlAttribute
        (Html.Events.on "keyup"
            (Decode.field "key" Decode.string
                |> Decode.andThen
                    (\key ->
                        if key == "Enter" then
                            Decode.succeed msg

                        else
                            Decode.fail "Not the enter key - no action taken"
                    )
            )
        )


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


type IconPosition
    = Left
    | Right


iconButton : IconPosition -> { onPress : msg, icon : Element msg, labelText : String } -> Element msg
iconButton iconPosition { onPress, icon, labelText } =
    let
        rowContents =
            [ el
                []
                icon
            , el [ Font.size 16 ] <| text labelText
            ]
    in
    Input.button []
        { onPress = Just onPress
        , label =
            row
                [ Border.rounded 5
                , Border.color Colours.grey
                , Font.color Colours.white
                , Background.color Colours.mediumBlue
                , paddingXY 10 5
                , Layout.lessRowSpacing
                ]
            <|
                case iconPosition of
                    Left ->
                        rowContents

                    Right ->
                        List.reverse rowContents
        }


leftIconButton : { onPress : msg, icon : Element msg, labelText : String } -> Element msg
leftIconButton params =
    iconButton Left params


rightIconButton : { onPress : msg, icon : Element msg, labelText : String } -> Element msg
rightIconButton params =
    iconButton Right params


form : msg -> Element msg -> Element msg
form onEnterMsg childElement =
    el
        [ onEnter onEnterMsg
        , width fill
        ]
        childElement


inputFieldWithInsetButton :
    { onChange : String -> msg
    , value : String
    , labelString : String
    , onSubmit : msg
    }
    -> Element msg
inputFieldWithInsetButton { onChange, value, labelString, onSubmit } =
    column
        [ Layout.commonColumnSpacing
        , width fill
        , onEnter onSubmit
        ]
        [ el [] <| text labelString
        , row [ width fill ]
            [ Input.text
                [ Border.color Colours.grey
                , Border.widthEach
                    { edges
                        | top = 1
                        , bottom = 1
                        , left = 1
                    }
                , Border.roundEach
                    { corners
                        | topLeft = 5
                        , bottomLeft = 5
                    }
                ]
                { onChange = onChange
                , text = value
                , label = Input.labelHidden labelString
                , placeholder = Nothing
                }
            , Input.button
                [ Background.color Colours.white
                , height fill
                , paddingXY 10 0
                , Border.color Colours.grey
                , Border.widthEach
                    { edges
                        | top = 1
                        , bottom = 1
                        , right = 1
                    }
                , Border.roundEach
                    { corners
                        | topRight = 5
                        , bottomRight = 5
                    }
                ]
                { onPress = Just onSubmit
                , label =
                    el
                        [ Border.rounded 5
                        , Border.color Colours.grey
                        , Font.color Colours.white
                        , Background.color Colours.mediumBlue
                        ]
                        Icons.add
                }
            ]
        ]
