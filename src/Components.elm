module Components exposing (..)

import Components.Colours as Colours
import Components.Layout as Layout exposing (Layout)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input exposing (labelAbove, labelHidden, labelRight)
import Element.Region as Region
import Html exposing (Html)
import Html.Attributes exposing (attribute)
import Html.Events
import Json.Decode as Decode
import Material.Icons exposing (add, check, clear, devices, edit, filter_2, filter_3, filter_4, filter_5, filter_6, filter_7, filter_8, filter_9, filter_9_plus, home, logout, mark_chat_read, question_answer, thumb_down, thumb_up)
import Material.Icons.Types exposing (Coloring(..), Icon)
import Route exposing (Route)
import User exposing (User)


globalLayout : Element msg -> Html msg
globalLayout =
    Element.layout
        [ Background.color <| Colours.teal
        , Font.color Colours.black
        , width fill
        , height fill
        , defaultFont
        ]


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


transition : List String -> Element.Attribute msg
transition propertyList =
    Element.htmlAttribute <|
        attribute "style" <|
            "transition-property: "
                ++ String.join "," propertyList
                ++ " .3s"


transitionDuration : Float -> Element.Attribute msg
transitionDuration duration =
    Element.htmlAttribute <|
        attribute "style" <|
            "transition-duration: "
                ++ String.fromFloat duration
                ++ "s"


slogan : String
slogan =
    "The grass is greener where you water it"


shadow =
    Border.shadow
        { offset = ( 2, 2 )
        , size = 2
        , blur = 5
        , color = rgba255 0 0 0 0.3
        }


usernameElement : String -> Element msg
usernameElement username =
    el [ width fill ] <|
        text <|
            "Welcome, "
                ++ username


boardIdElement : String -> Element msg
boardIdElement boardId =
    row
        [ width fill
        ]
        [ row
            [ spacing 10
            , Background.color Colours.trueBlack
            , paddingXY 10 10
            , Font.color Colours.white
            , Border.rounded 20
            ]
            [ el [] <|
                icon devices
            , el
                []
              <|
                text boardId
            ]
        ]


upvoteIcon : Icon msg
upvoteIcon =
    thumb_up


icon : (Int -> Coloring -> Html msg) -> Element msg
icon requiredIcon =
    Element.html <| requiredIcon 20 Inherit


controlIcon : (Int -> Coloring -> Html msg) -> Element msg
controlIcon requiredIcon =
    Element.html <| requiredIcon 20 Inherit


flexShrink : Attribute msg
flexShrink =
    Element.htmlAttribute (Html.Attributes.style "flex-shrink" "1")


maxViewportHeight : Int -> Attribute msg
maxViewportHeight int =
    Element.htmlAttribute (Html.Attributes.style "max-height" <| String.fromInt int ++ "vh")


borderWidth : Int
borderWidth =
    1


edges =
    { top = 0
    , left = 0
    , bottom = 0
    , right = 0
    }


corners =
    { topRight = 0
    , topLeft = 0
    , bottomRight = 0
    , bottomLeft = 0
    }


defaultFont : Attribute msg
defaultFont =
    Font.family
        [ Font.external
            { name = "Roboto"
            , url = "https://fonts.googleapis.com/css2?family=Roboto:wght@300&display=swap"
            }
        ]


titleFont : Attribute msg
titleFont =
    Font.family
        [ Font.external
            { name = "Amatic SC"
            , url = "https://fonts.googleapis.com/css2?family=Amatic+SC:wght@700&display=swap"
            }
        ]


img : String -> Element msg
img filepath =
    el
        [ centerX
        , centerY
        , height fill
        , width fill
        , Background.uncropped filepath
        ]
    <|
        Element.none


noContentSection : { description : String, imgSrc : String, fadeInDelay : Float } -> Element msg
noContentSection { description, imgSrc, fadeInDelay } =
    el
        [ paddingEach { edges | bottom = 80 }
        , width fill
        , height fill
        , fadeInWithDelay fadeInDelay
        ]
    <|
        column
            [ centerX
            , centerY
            , padding 20
            , spacing 20
            , height
                (fill
                    |> minimum 250
                    |> maximum 250
                )
            ]
            [ el
                [ centerX
                , centerY
                , width fill
                , height
                    (fill
                        |> minimum 250
                        |> maximum 250
                    )
                ]
              <|
                img imgSrc
            , paragraph [ width fill, centerX ] [ el [ centerX ] <| text description ]
            ]


landingComponent : Layout -> Float -> Element msg -> Element msg
landingComponent layout fadeInDelay childElement =
    el
        [ Background.color Colours.mediumBlue
        , width fill
        , height fill
        ]
    <|
        row
            [ centerX
            , centerY
            , Background.color Colours.white
            , shadow
            , padding 0
            , width (fill |> maximum 1000)
            , height (fill |> maximum 600)
            , Border.rounded 8
            ]
        <|
            Layout.landingComponentContent layout
                { imageElement =
                    column
                        [ height fill
                        , width fill
                        , padding 60
                        , spacing 20
                        , Background.color Colours.grey90
                        , Border.roundEach
                            { corners
                                | topLeft = 8
                                , bottomLeft = 8
                            }
                        ]
                        [ img "/img/absurd-lightbulb-waterer.png"
                        , el
                            [ Font.size 24
                            , Font.color Colours.black60transparent
                            , titleFont
                            , centerX
                            ]
                          <|
                            text slogan
                        ]
                , childElement =
                    el
                        [ paddingXY 100 40
                        , width fill
                        , height fill
                        , fadeInWithDelay fadeInDelay
                        ]
                    <|
                        childElement
                }


siteTitle : Element msg
siteTitle =
    el [ width fill ] <|
        Element.link
            [ titleFont
            , width (fill |> maximum 120)
            , Font.size 32
            , Background.color Colours.white
            , alignLeft
            , Border.color Colours.white
            , paddingXY 0 17
            ]
            { label =
                el
                    [ Border.widthEach
                        { edges
                            | bottom = 1
                        }
                    ]
                <|
                    text "BestRetro.app"
            , url = Route.toUrlString Route.Dashboard
            }


link : Route -> List (Attribute msg) -> String -> Element msg
link route attrs labelText =
    Element.link
        attrs
        { label =
            el
                [ centerX
                ]
            <|
                text labelText
        , url = Route.toUrlString route
        }


linkAsText : Route -> String -> Element msg
linkAsText route linkText =
    link route textLinkStyles linkText


textLinkStyles : List (Attribute msg)
textLinkStyles =
    [ Font.underline ]


linkAsButton : ButtonType -> Route -> String -> Element msg
linkAsButton buttonType route labelText =
    link route (buttonStyles buttonType) labelText


linkAsPrimaryButton : Route -> String -> Element msg
linkAsPrimaryButton =
    linkAsButton Primary


linkAsSecondaryButton : Route -> String -> Element msg
linkAsSecondaryButton =
    linkAsButton Secondary


dashboardSection : User -> List (Element msg) -> Element msg
dashboardSection _ contents =
    column
        [ alignTop
        , width fill
        , Background.color Colours.green
        , spacing 40
        , height fill
        ]
        [ header
            [ siteTitle
            , el [ alignRight ] <| logOutButton
            ]
        , el
            [ centerX
            , height fill
            , width fill
            , Background.color Colours.green
            , paddingXY 40 0
            , spacing 20
            ]
          <|
            column
                [ width (fill |> maximum 1200)
                , centerX
                , height fill
                ]
                contents
        ]


heading : String -> Element msg
heading str =
    paragraph
        [ Font.extraBold
        , Region.heading 1
        , Font.size 26
        , width fill
        ]
        [ el [ width fill ] <| text str ]


titleFontHeading : String -> Element msg
titleFontHeading str =
    paragraph
        [ Font.extraBold
        , titleFont
        , Region.heading 1
        , Font.size 40
        , width fill
        ]
        [ el [ width fill ] <| text str ]


headingTwo : String -> Element msg
headingTwo str =
    paragraph
        [ Font.extraBold
        , Region.heading 2
        , Font.size 20
        , width fill
        ]
        [ el [ width fill ] <| text str ]


errorMessage : String -> Element msg
errorMessage str =
    paragraph
        [ Font.color Colours.orangeRed
        , Font.italic
        , Background.color Colours.white
        , padding 20
        , Border.rounded 8
        ]
        [ el [ centerX ] <| text str ]


header : List (Element msg) -> Element msg
header =
    wrappedRow
        [ width fill
        , Background.color Colours.white
        , Border.color Colours.grey
        , Border.widthEach { edges | bottom = borderWidth }
        , paddingXY 40 5
        , spaceEvenly
        ]


mainBoardSection : Layout -> List (Element msg) -> Element msg
mainBoardSection layout =
    Layout.containingElement layout <|
        [ width fill
        , padding 20
        , spacing 20
        , Background.color Colours.teal
        ]


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


form : msg -> Element msg -> Element msg
form onEnterMsg childElement =
    el
        [ onEnter onEnterMsg
        , width fill
        ]
        childElement


type ButtonType
    = Primary
    | Secondary


buttonStyles : ButtonType -> List (Attribute msg)
buttonStyles buttonType =
    [ width (fill |> maximum 400)
    , case buttonType of
        Primary ->
            Font.color Colours.white

        _ ->
            Font.color Colours.black
    , Font.size 16
    , Background.color <|
        case buttonType of
            Primary ->
                Colours.mediumBlue

            Secondary ->
                Colours.teal
    , Border.rounded 8
    , paddingXY 20 15
    , centerX
    , transition
        [ "background-color"
        , "border-color"
        , "color"
        ]
    , transitionDuration 0.3
    , Border.width 2
    , Border.color <|
        case buttonType of
            Primary ->
                Colours.mediumBlue

            Secondary ->
                Colours.teal
    , mouseOver <|
        case buttonType of
            Primary ->
                [ Background.color Colours.white
                , Font.color Colours.black60transparent
                , Border.color Colours.mediumBlue
                ]

            Secondary ->
                [ Background.color Colours.white
                , Font.color Colours.black60transparent
                , Border.color Colours.mediumBlue
                ]
    ]


button : ButtonType -> String -> msg -> Element msg
button buttonType label msg =
    Input.button
        (buttonStyles buttonType)
        { onPress = Just msg
        , label = el [ centerX ] <| paragraph [] [ text label ]
        }


primaryButton : String -> msg -> Element msg
primaryButton =
    button Primary


secondaryButton : String -> msg -> Element msg
secondaryButton =
    button Secondary


title : String -> Element msg
title str =
    paragraph
        [ Font.size 22
        , Font.bold
        ]
        [ text <| String.toUpper str
        ]


inputStyles : Bool -> List (Attribute msg)
inputStyles fullBorder =
    [ Background.color Colours.white
    , Border.color Colours.grey90
    , if fullBorder then
        Border.width borderWidth

      else
        Border.widthEach
            { edges
                | left = borderWidth
                , top = borderWidth
                , bottom = borderWidth
            }
    , if fullBorder then
        Border.rounded 10

      else
        Border.roundEach
            { bottomLeft = 10
            , topLeft = 10
            , bottomRight = 0
            , topRight = 0
            }
    , Font.color Colours.black
    , paddingXY 25 20
    , Element.focused
        [ Border.color Colours.grey90 ]
    ]


type alias InputParams msg =
    { labelText : String
    , value : String
    , onChange : String -> msg
    , fullBorder : Bool
    }


passwordInput : InputParams msg -> Element msg
passwordInput { labelText, value, onChange, fullBorder } =
    Input.newPassword (inputStyles fullBorder)
        { label =
            labelAbove [] <| el [ paddingEach { edges | bottom = 10 } ] <| text labelText
        , text = value
        , show = False
        , placeholder = Nothing
        , onChange = onChange
        }


currentPasswordInput : InputParams msg -> Element msg
currentPasswordInput { labelText, value, onChange, fullBorder } =
    Input.currentPassword (inputStyles fullBorder)
        { label =
            labelAbove [] <| el [ paddingEach { edges | bottom = 10 } ] <| text labelText
        , text = value
        , show = False
        , placeholder = Nothing
        , onChange = onChange
        }


baseTextInput : InputParams msg -> Bool -> Element msg
baseTextInput { labelText, value, onChange, fullBorder } displayLabel =
    Input.text
        (inputStyles fullBorder)
        { label =
            if displayLabel then
                labelAbove [] <| el [ paddingEach { edges | bottom = 10 } ] <| text labelText

            else
                labelHidden labelText
        , placeholder = Nothing
        , text = value
        , onChange = onChange
        }


textInput : InputParams msg -> Element msg
textInput inputParams =
    baseTextInput inputParams True


textInputWithNoLabel : InputParams msg -> Element msg
textInputWithNoLabel inputParams =
    baseTextInput inputParams False


textInputWithButton : InputParams msg -> msg -> Element msg
textInputWithButton inputParams buttonMsg =
    column
        [ spacing 20
        , width fill
        , onEnter buttonMsg
        ]
        [ el [] <| text inputParams.labelText
        , row
            [ width fill
            ]
            [ textInputWithNoLabel inputParams
            , buttonForInputFields buttonMsg
            ]
        ]


baseMultilineInput : InputParams msg -> Bool -> Element msg
baseMultilineInput { labelText, value, onChange, fullBorder } displayLabel =
    column
        [ width fill
        , spacing 20
        ]
        [ Input.multiline
            (inputStyles fullBorder)
            { label =
                if displayLabel then
                    labelAbove [] <|
                        el
                            [ paddingEach
                                { edges
                                    | bottom = 10
                                }
                            ]
                        <|
                            text labelText

                else
                    labelHidden labelText
            , placeholder = Nothing
            , text = value
            , onChange = onChange
            , spellcheck = True
            }
        ]


multilineInput : InputParams msg -> Element msg
multilineInput inputParams =
    baseMultilineInput inputParams True


multilineInputWithNoLabel : InputParams msg -> Element msg
multilineInputWithNoLabel inputParams =
    baseMultilineInput inputParams False


multilineInputWithButton : InputParams msg -> msg -> Element msg
multilineInputWithButton inputParams buttonMsg =
    column
        [ width fill
        , spacing 10
        ]
        [ el [] <| text inputParams.labelText
        , row
            [ width fill
            ]
            [ multilineInputWithNoLabel inputParams
            , buttonForInputFields buttonMsg
            ]
        ]


type ControlType
    = Add
    | Edit
    | Remove
    | CombineTwo
    | CombineThree
    | CombineFour
    | CombineFive
    | CombineSix
    | CombineSeven
    | CombineEight
    | CombineNine
    | CombineNinePlus
    | Upvote
    | Downvote
    | FinishDiscussion
    | GoBack
    | StartDiscussion
    | LogOut
    | Home
    | MarkComplete


controlButtonStyles : ControlType -> List (Element.Attribute msg)
controlButtonStyles controlType =
    [ Font.color <|
        case controlType of
            GoBack ->
                Colours.black60transparent

            MarkComplete ->
                Colours.black

            _ ->
                Colours.white
    , Background.color <|
        case controlType of
            Remove ->
                Colours.orangeRed

            GoBack ->
                Colours.white

            MarkComplete ->
                Colours.green

            _ ->
                Colours.black60transparent
    , Border.width <|
        case controlType of
            GoBack ->
                1

            _ ->
                0
    , height fill
    , width fill
    , padding 10
    , Border.rounded 8
    , transition
        [ "background-color"
        , "color"
        , "border-color"
        ]
    , transitionDuration 0.3
    , mouseOver
        [ Background.color Colours.mediumBlue
        , Font.color Colours.white
        ]
    ]


controlButton : ControlType -> msg -> Element msg
controlButton controlType msg =
    Input.button
        (controlButtonStyles controlType)
        { label =
            controlIcon <|
                case controlType of
                    Add ->
                        add

                    Edit ->
                        edit

                    Remove ->
                        clear

                    CombineTwo ->
                        filter_2

                    CombineThree ->
                        filter_3

                    CombineFour ->
                        filter_4

                    CombineFive ->
                        filter_5

                    CombineSix ->
                        filter_6

                    CombineSeven ->
                        filter_7

                    CombineEight ->
                        filter_8

                    CombineNine ->
                        filter_9

                    CombineNinePlus ->
                        filter_9_plus

                    Upvote ->
                        upvoteIcon

                    Downvote ->
                        thumb_down

                    FinishDiscussion ->
                        mark_chat_read

                    GoBack ->
                        clear

                    StartDiscussion ->
                        question_answer

                    LogOut ->
                        logout

                    Home ->
                        home

                    MarkComplete ->
                        check
        , onPress = Just msg
        }


markCompleteButton : msg -> Element msg
markCompleteButton =
    controlButton MarkComplete


homeButton : msg -> Element msg
homeButton =
    controlButton Home


logOutButton : Element msg
logOutButton =
    Element.link (controlButtonStyles LogOut)
        { label = controlIcon logout
        , url = Route.toUrlString Route.Home
        }


completeButton : msg -> Element msg
completeButton =
    controlButton FinishDiscussion


addButton : msg -> Element msg
addButton =
    controlButton Add


editButton : msg -> Element msg
editButton =
    controlButton Edit


deleteButton : msg -> Element msg
deleteButton =
    controlButton Remove


goBackButton : msg -> Element msg
goBackButton =
    controlButton GoBack


combineButton : Int -> msg -> Element msg
combineButton numberOfItems =
    controlButton
        (if numberOfItems == 2 then
            CombineTwo

         else if numberOfItems == 3 then
            CombineThree

         else if numberOfItems == 4 then
            CombineFour

         else if numberOfItems == 5 then
            CombineFive

         else if numberOfItems == 6 then
            CombineSix

         else if numberOfItems == 7 then
            CombineSeven

         else if numberOfItems == 8 then
            CombineEight

         else if numberOfItems == 9 then
            CombineNine

         else
            CombineNinePlus
        )


upvoteButton : msg -> Element msg
upvoteButton =
    controlButton Upvote


downvoteButton : msg -> Element msg
downvoteButton =
    controlButton Downvote


startDiscussionButton : msg -> Element msg
startDiscussionButton =
    controlButton StartDiscussion


buttonForInputFields : msg -> Element msg
buttonForInputFields msg =
    el
        [ height fill
        , Background.color Colours.white
        , Border.widthEach
            { edges
                | top = borderWidth
                , right = borderWidth
                , bottom = borderWidth
            }
        , Border.roundEach
            { bottomLeft = 0
            , topLeft = 0
            , bottomRight = 10
            , topRight = 10
            }
        , Border.color Colours.grey90
        , padding 10
        ]
    <|
        el
            [ centerY
            , Background.color Colours.orangeRed
            , Font.color Colours.white
            , width fill
            , Border.rounded 10
            ]
        <|
            addButton msg


checkbox : Bool -> String -> (Bool -> msg) -> Element msg
checkbox isChecked labelText msg =
    Input.checkbox
        [ height fill
        ]
        { onChange = msg
        , icon = Input.defaultCheckbox
        , checked = isChecked
        , label =
            labelRight
                []
            <|
                paragraph [ paddingEach { edges | left = 10 } ]
                    [ text labelText ]
        }


card : Element msg -> Element msg
card =
    el
        [ width fill
        , Background.color Colours.white
        , Border.rounded 10
        , Border.color Colours.grey90
        , Border.width borderWidth
        , Font.bold
        , Font.size 18
        , Font.color Colours.black
        , Border.shadow
            { offset = ( 0, 8 )
            , size = 1
            , blur = 12
            , color = rgba255 0 0 0 0.2
            }
        , padding 20
        , spacing 20
        , alignTop
        ]


cardControls : List (Element msg) -> Element msg
cardControls =
    row
        [ width fill
        , paddingEach { edges | bottom = 20 }
        ]


baseCard : Layout -> { a | comment : String } -> Maybe (List (Element msg)) -> Element msg
baseCard _ { comment } maybeChildren =
    case maybeChildren of
        Just children ->
            card <|
                column
                    [ width fill
                    ]
                    [ cardControls children
                    , paragraph [ width fill ]
                        [ el
                            []
                          <|
                            text comment
                        ]
                    ]

        Nothing ->
            card <|
                paragraph [ width fill ]
                    [ el
                        []
                      <|
                        text comment
                    ]


baseColumn : List (Element msg) -> Element msg
baseColumn children =
    column
        [ height fill
        , width fill
        , paddingXY 40 20
        , spacing 20
        , Background.color Colours.teal
        , alignTop
        ]
        children


actionCard : { a | description : String, assignee : String } -> Maybe (Element msg) -> Element msg
actionCard { description, assignee } maybeChildElement =
    card <|
        column
            [ spacing 20
            , width (fill |> minimum 300)
            , height fill
            ]
            [ paragraph [ height fill ]
                [ text description
                ]
            , paragraph
                [ alignBottom
                , width fill
                , paddingEach { edges | top = 20 }
                ]
                [ text <|
                    "Assigned to: "
                        ++ assignee
                ]
            , Maybe.withDefault Element.none maybeChildElement
            ]


centeredElement : Element msg -> Element msg
centeredElement =
    el
        [ width fill
        , height fill
        ]
        << el
            [ centerX
            , centerY
            ]
