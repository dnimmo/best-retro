module Components.Layout exposing
    ( Layout
    , breakpointOne
    , commonColumnSpacing
    , commonPadding
    , commonRowSpacing
    , containingElement
    , dashboardSpacing
    , extraColumnSpacing
    , getLayout
    , getWidth
    , imgSelect
    , isSingleColumn
    , label
    , landingComponentContent
    , lessRowSpacing
    , page
    , rightAlign
    , spacingElement
    , withHeader
    )

import Components.Colours as Colours
import Components.Font as Font
import Components.Navigation as Navigation
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Route exposing (Route)


type Layout
    = SingleColumn
    | MultipleColumn Int


breakpointOne : Int
breakpointOne =
    1000


getLayout : Int -> Layout
getLayout int =
    if int < breakpointOne then
        SingleColumn

    else
        MultipleColumn int


getWidth : Layout -> Int
getWidth layout =
    -- Probably want to rethink this but right now this is fine
    case layout of
        SingleColumn ->
            1000

        MultipleColumn width ->
            width


rightAlign : Layout -> Attribute msg
rightAlign layout =
    case layout of
        SingleColumn ->
            centerX

        MultipleColumn _ ->
            alignRight


containingElement : Layout -> List (Attribute msg) -> List (Element msg) -> Element msg
containingElement layout =
    case layout of
        SingleColumn ->
            column

        MultipleColumn _ ->
            row


isSingleColumn : Layout -> Bool
isSingleColumn layout =
    case layout of
        SingleColumn ->
            True

        MultipleColumn _ ->
            False


landingComponentContent :
    Layout
    ->
        { imageElement : Element msg
        , childElement : Element msg
        }
    -> List (Element msg)
landingComponentContent layout { imageElement, childElement } =
    case layout of
        SingleColumn ->
            [ childElement ]

        MultipleColumn _ ->
            [ imageElement, childElement ]


spacingElement : Layout -> Element msg
spacingElement layout =
    case layout of
        MultipleColumn _ ->
            el [ width fill ] <| Element.none

        SingleColumn ->
            Element.none


label : Layout -> { small : String, large : String } -> String
label layout { small, large } =
    case layout of
        SingleColumn ->
            small

        MultipleColumn _ ->
            large


dashboardSpacing : Layout -> Int
dashboardSpacing layout =
    case layout of
        SingleColumn ->
            40

        MultipleColumn _ ->
            200


imgSelect : Layout -> String -> String
imgSelect layout filename =
    case layout of
        SingleColumn ->
            "/img/narrow-" ++ filename

        MultipleColumn _ ->
            "/img/" ++ filename


header : Route -> Element msg
header route =
    el
        [ width fill
        , Colours.gradientBlue
        ]
    <|
        row
            (Font.siteHeading
                ++ [ width (fill |> maximum 1000)
                   , centerX
                   , Font.color Colours.white
                   , spacing 10
                   ]
            )
        <|
            [ image
                [ width (fill |> maximum 360)
                , height <| px 80
                , moveLeft 50
                ]
                { src = "/img/logo.svg"
                , description = ""
                }
            ]


footer : Element msg
footer =
    el
        [ width fill
        , paddingXY commonPaddingValue 10
        , Colours.gradientBlue
        , Font.color Colours.white
        , Border.widthEach
            { top = 1
            , bottom = 0
            , left = 0
            , right = 0
            }
        , Border.color Colours.grey
        ]
    <|
        el
            [ alignRight
            , Font.size 10
            ]
        <|
            text "© 2024 Nimmo"


withHeader : Layout -> Route -> Element msg -> Element msg
withHeader layout route element =
    column
        [ width fill
        , height fill
        ]
        [ header route
        , column
            [ height fill
            , width (fill |> maximum 1000)
            , centerX
            , paddingXY 0 <|
                if isSingleColumn layout then
                    0

                else
                    36
            ]
            [ el
                [ width fill
                , if isSingleColumn layout then
                    Background.color Colours.white

                  else
                    Background.color Colours.mediumBlueTransparent
                , paddingXY 20 5
                , Border.rounded 5
                ]
              <|
                Navigation.breadCrumb route
            , el
                [ height fill
                , width fill
                , Background.color Colours.skyBlue
                ]
              <|
                element
            ]
        , footer
        ]


commonPaddingValue : Int
commonPaddingValue =
    20


commonPadding : Attribute msg
commonPadding =
    padding commonPaddingValue


commonColumnSpacing : Attribute msg
commonColumnSpacing =
    spacing 16


extraColumnSpacing : Attribute msg
extraColumnSpacing =
    spacing 40


commonRowSpacing : Attribute msg
commonRowSpacing =
    spacing 20


lessRowSpacing : Attribute msg
lessRowSpacing =
    spacing 5


page : List (Element msg) -> Element msg
page =
    column
        [ width fill
        , height fill
        , commonPadding
        , commonColumnSpacing
        , Background.color Colours.skyBlue
        ]
