module Components exposing (card, globalLayout, heading1, heading2, internalLink, internalLinkCard, page, paragraph)

import Components.Colours as Colours
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Route exposing (Route)


globalLayout : Element msg -> Html msg
globalLayout =
    layout
        [ width fill
        , height fill
        , Background.color Colours.teal
        , padding 60
        ]


heading1 : String -> Element msg
heading1 str =
    text str


heading2 : String -> Element msg
heading2 str =
    text str


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


page : List (Element msg) -> Element msg
page content =
    column
        [ width fill
        , height fill
        , Background.color Colours.white
        ]
        content
