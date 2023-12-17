module Components.Card exposing (..)

import ActionItem exposing (ActionItem)
import Components exposing (edges)
import Components.Colours as Colours
import Components.Font as Font
import Components.Icons as Icons
import Components.Layout as Layout
import Element exposing (..)
import Element.Background as Backround
import Element.Border as Border
import Route exposing (..)


type Card msg
    = Card String (CardVariant msg)


type CardVariant msg
    = Display
    | Action ActionItem msg
    | Link Route


styles : List (Element.Attribute msg)
styles =
    [ Border.rounded 5
    , Backround.color Colours.white
    , paddingXY 15 25
    , Layout.commonColumnSpacing
    , width (fill |> minimum 360)
    , height fill
    , Border.shadow
        { offset = ( 10, 10 )
        , blur = 10
        , color = Colours.mediumBlueTransparent
        , size = 1
        }
    ]


card : Card msg -> Element msg
card (Card str variant) =
    let
        element =
            column
                styles
            <|
                case variant of
                    Display ->
                        [ text str
                        ]

                    Action item msg ->
                        [ row
                            [ width fill
                            , height fill
                            ]
                            [ paragraph
                                [ width fill
                                , height fill
                                ]
                                [ el [ width fill ] <| text str
                                ]
                            , column
                                [ alignRight
                                , height fill
                                , width (fill |> minimum 150)
                                , alignTop
                                , Layout.commonColumnSpacing
                                , Border.widthEach
                                    { edges
                                        | left = 1
                                    }
                                , paddingXY 10 0
                                , Border.color Colours.mediumBlue
                                ]
                                [ row [ Layout.lessRowSpacing ]
                                    [ el [] Icons.user
                                    , el [] <|
                                        text <|
                                            ActionItem.getAssignee item
                                    ]
                                , row [ Layout.lessRowSpacing ]
                                    [ el [] Icons.status
                                    , el [] <|
                                        text <|
                                            ActionItem.statusToString <|
                                                ActionItem.getStatus item
                                    ]
                                ]
                            ]
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


action : ActionItem -> msg -> Element msg
action item msg =
    card <|
        Card (ActionItem.getContent item) <|
            Action item msg


display : String -> Element msg
display str =
    card <| Card str Display
