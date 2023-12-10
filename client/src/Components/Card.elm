module Components.Card exposing (..)

import Components.Colours as Colours
import Components.Font as Font
import Components.Icons as Icons
import Element exposing (..)
import Element.Background as Backround
import Element.Border as Border
import Route exposing (..)


type Card msg
    = Card String (CardVariant msg)


type CardVariant msg
    = Display
    | Action msg
    | Link Route


card : Card msg -> Element msg
card (Card str variant) =
    let
        element =
            column
                [ Border.rounded 5
                , Backround.color Colours.white
                , paddingXY 15 25
                , width fill
                , Border.shadow
                    { offset = ( 10, 10 )
                    , blur = 10
                    , color = Colours.mediumBlueTransparent
                    , size = 1
                    }
                ]
            <|
                case variant of
                    Display ->
                        [ text str
                        ]

                    Action msg ->
                        [ text <| str ++ "TODO action"
                        ]

                    Link _ ->
                        [ row [ width fill ]
                            [ el
                                Font.title
                              <|
                                text str
                            , el [ alignRight ] <| Icons.rightArrow
                            ]
                        ]
    in
    case variant of
        Link route ->
            Element.link
                [ width fill ]
                { url = Route.toUrlString route
                , label = element
                }

        _ ->
            el
                [ width fill ]
                element


link : String -> Route -> Element msg
link str route =
    card <| Card str <| Link route


action : String -> msg -> Element msg
action str msg =
    card <| Card str <| Action msg


display : String -> Element msg
display str =
    card <| Card str Display
