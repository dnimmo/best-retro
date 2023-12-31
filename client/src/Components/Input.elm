module Components.Input exposing
    ( addButton
    , checkbox
    , combineButton
    , currentPasswordDisplayed
    , currentPasswordHidden
    , downvoteButton
    , editButton
    , form
    , inputFieldWithInsetButton
    , leftIconButton
    , plainText
    , primaryActionButton
    , removeButton
    , rightIconButton
    , secondaryActionButton
    , startDiscussion
    , textField
    , upvoteButton
    )

import Components exposing (ControlType(..), corners, edges)
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


type ButtonType
    = Primary
    | Secondary


actionButton : ButtonType -> { onPress : msg, labelString : String } -> Element msg
actionButton buttonType { onPress, labelString } =
    let
        colours =
            case buttonType of
                Primary ->
                    [ Background.color Colours.mediumBlue
                    , Font.color Colours.white
                    , Border.color Colours.darkBlue
                    ]

                Secondary ->
                    [ Background.color Colours.white
                    , Font.color Colours.mediumBlue
                    , Border.color Colours.mediumBlue
                    ]
    in
    Input.button
        (colours
            ++ [ Border.rounded 5
               , paddingXY 20 10
               , Font.size 18
               , Border.width 1
               ]
        )
        { onPress = Just onPress
        , label = text labelString
        }


primaryActionButton : { onPress : msg, labelString : String } -> Element msg
primaryActionButton =
    actionButton Primary


secondaryActionButton : { onPress : msg, labelString : String } -> Element msg
secondaryActionButton =
    actionButton Secondary


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
            , addButton onSubmit
            ]
        ]


textField :
    { onChange : String -> msg
    , value : String
    , labelString : String
    }
    -> Element msg
textField { onChange, value, labelString } =
    column
        [ Layout.commonColumnSpacing
        , width fill
        ]
        [ el [] <| text labelString
        , Input.text
            [ Border.color Colours.grey
            , Border.width 1
            , Border.rounded 5
            , width fill
            ]
            { onChange = onChange
            , text = value
            , label = Input.labelHidden labelString
            , placeholder = Nothing
            }
        ]


type ControlType
    = Add
    | Remove
    | Edit
    | GoBack
    | Combine Int
    | Upvote
    | Downvote
    | Discuss


controlButtonStyles : ControlType -> List (Element.Attribute msg)
controlButtonStyles controlType =
    [ Background.color Colours.white
    , Font.color Colours.mediumBlue
    , height fill
    , paddingXY 10 <|
        case controlType of
            Add ->
                0

            _ ->
                10
    , Border.color Colours.grey
    , Border.widthEach
        { edges
            | top =
                case controlType of
                    Add ->
                        1

                    _ ->
                        0
            , bottom =
                case controlType of
                    Add ->
                        1

                    _ ->
                        0
            , right =
                case controlType of
                    Add ->
                        1

                    _ ->
                        0
        }
    , Border.roundEach
        { topRight = 5
        , bottomRight = 5
        , bottomLeft =
            case controlType of
                Add ->
                    0

                _ ->
                    5
        , topLeft =
            case controlType of
                Add ->
                    0

                _ ->
                    5
        }
    ]


controlButton : ControlType -> msg -> Element msg
controlButton controlType msg =
    Input.button
        (controlButtonStyles controlType)
        { label =
            el [ centerY ] <|
                case controlType of
                    Add ->
                        Icons.add

                    GoBack ->
                        Icons.clear

                    Remove ->
                        Icons.remove

                    Edit ->
                        Icons.edit

                    Combine int ->
                        case int of
                            2 ->
                                Icons.combine2

                            3 ->
                                Icons.combine3

                            4 ->
                                Icons.combine4

                            5 ->
                                Icons.combine5

                            6 ->
                                Icons.combine6

                            7 ->
                                Icons.combine7

                            8 ->
                                Icons.combine8

                            _ ->
                                Icons.combine9plus

                    Upvote ->
                        Icons.upvote

                    Downvote ->
                        Icons.downvote

                    Discuss ->
                        Icons.discuss
        , onPress = Just msg
        }


addButton : msg -> Element msg
addButton =
    controlButton Add


removeButton : msg -> Element msg
removeButton =
    controlButton Remove


editButton : msg -> Element msg
editButton =
    controlButton Edit


checkbox : Bool -> (Bool -> msg) -> Element msg
checkbox isChecked toggleMsg =
    Input.checkbox
        [ Background.color <|
            if isChecked then
                Colours.mediumBlue

            else
                Colours.mediumBlueTransparent
        , Border.rounded 5
        , padding 10
        ]
        { checked = isChecked
        , onChange = toggleMsg
        , icon = Input.defaultCheckbox
        , label = Input.labelHidden "combine"
        }


combineButton : Int -> msg -> Element msg
combineButton numberToCombine combineMsg =
    controlButton (Combine numberToCombine) combineMsg


upvoteButton : msg -> Element msg
upvoteButton msg =
    controlButton Upvote msg


downvoteButton : msg -> Element msg
downvoteButton msg =
    controlButton Downvote msg


startDiscussion : msg -> Element msg
startDiscussion msg =
    controlButton Discuss msg
