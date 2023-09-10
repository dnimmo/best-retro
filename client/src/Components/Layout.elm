module Components.Layout exposing
    ( Layout
    , breakpointOne
    , containingElement
    , dashboardSpacing
    , getLayout
    , imgSelect
    , isSingleColumn
    , label
    , landingComponentContent
    , rightAlign
    , spacingElement
    )

import Element exposing (Attribute, Element, alignRight, centerX, column, el, fill, row, width)


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
