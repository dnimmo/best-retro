module Components.Layout exposing
    ( Layout
    , breakpointOne
    , commonColumnSpacing
    , commonPadding
    , commonRowSpacing
    , containingElement
    , dashboardSpacing
    , getLayout
    , imgSelect
    , isSingleColumn
    , label
    , landingComponentContent
    , rightAlign
    , spacingElement
    , withHeader
    )

import Components.Colours as Colours
import Components.Font as Font
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Route exposing (Route)


type Layout
    = SingleColumn
    | MultipleColumn


breakpointOne : Int
breakpointOne =
    1000


getLayout : Int -> Layout
getLayout int =
    if int < breakpointOne then
        SingleColumn

    else
        MultipleColumn


rightAlign : Layout -> Attribute msg
rightAlign layout =
    case layout of
        SingleColumn ->
            centerX

        MultipleColumn ->
            alignRight


containingElement : Layout -> List (Attribute msg) -> List (Element msg) -> Element msg
containingElement layout =
    case layout of
        SingleColumn ->
            column

        MultipleColumn ->
            row


isSingleColumn : Layout -> Bool
isSingleColumn layout =
    case layout of
        SingleColumn ->
            True

        MultipleColumn ->
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

        MultipleColumn ->
            [ imageElement, childElement ]


spacingElement : Layout -> Element msg
spacingElement layout =
    case layout of
        MultipleColumn ->
            el [ width fill ] <| Element.none

        SingleColumn ->
            Element.none


label : Layout -> { small : String, large : String } -> String
label layout { small, large } =
    case layout of
        SingleColumn ->
            small

        MultipleColumn ->
            large


dashboardSpacing : Layout -> Int
dashboardSpacing layout =
    case layout of
        SingleColumn ->
            40

        MultipleColumn ->
            200


imgSelect : Layout -> String -> String
imgSelect layout filename =
    case layout of
        SingleColumn ->
            "/img/narrow-" ++ filename

        MultipleColumn ->
            "/img/" ++ filename


bannerGradient : Attribute msg
bannerGradient =
    Background.gradient
        { angle = 1.8
        , steps =
            [ Colours.mediumBlue
            , Colours.darkBlue
            ]
        }


header : Route -> Element msg
header route =
    row
        (Font.siteHeading
            ++ [ width fill
               , commonPadding
               , bannerGradient
               , Font.color Colours.white
               , Border.widthEach
                    { top = 0
                    , bottom = 1
                    , left = 0
                    , right = 0
                    }
               , Border.color Colours.grey
               , spacing 10
               , height <| px 100
               ]
        )
    <|
        [ el [ centerX ] <| text "Best Retro"
        ]


footer : Element msg
footer =
    el
        [ width fill
        , paddingXY commonPaddingValue 10
        , bannerGradient
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


withHeader : Route -> Element msg -> Element msg
withHeader route element =
    column
        [ width fill
        , height fill
        ]
        [ header route
        , el
            [ height fill
            , width fill
            , Background.color Colours.skyBlue
            ]
          <|
            element
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
    spacing 12


commonRowSpacing : Attribute msg
commonRowSpacing =
    spacing 20
