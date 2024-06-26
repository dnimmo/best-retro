module Components.Card exposing (..)

import ActionItem exposing (ActionItem)
import Components exposing (edges)
import Components.Animation as Animation
import Components.Colours as Colours
import Components.Font as Font
import Components.Icons as Icons
import Components.Input as Input
import Components.Layout as Layout
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Route exposing (..)


type Card msg
    = Card String (CardVariant msg)


type CardVariant msg
    = Display
    | Action ActionItem (ActionMsgs msg)
    | BasicAction ActionItem
    | Link Route


type alias ActionMsgs msg =
    { setComplete : msg
    , setInProgress : msg
    , setNotStarted : msg
    }


styles : { highlight : Bool } -> List (Element.Attribute msg)
styles { highlight } =
    [ Border.rounded 5
    , if highlight then
        Background.color Colours.mediumBlueTransparent

      else
        Background.color Colours.white
    , width fill
    , height fill
    , Border.shadow
        { offset = ( 10, 10 )
        , blur = 10
        , color = Colours.mediumBlueTransparent
        , size = 1
        }
    , Animation.fadeIn
    ]


basicActionCard : ActionItem -> Element msg
basicActionCard item =
    row
        [ width fill
        , height fill
        ]
        [ paragraph
            [ width fill
            , paddingXY 15 25
            ]
            [ el [ width fill ] <| text <| ActionItem.getContent item
            ]
        , el
            [ alignRight
            , width (fill |> minimum 180)
            , paddingXY 0 10
            , height fill
            , alignTop
            , Border.widthEach
                { edges
                    | left = 2
                }
            , Border.color Colours.mediumBlueTransparent
            ]
          <|
            column
                [ Layout.commonColumnSpacing
                , centerX
                , centerY
                ]
                [ row
                    [ Layout.lessRowSpacing
                    ]
                    [ el [] Icons.user
                    , el [] <|
                        text <|
                            ActionItem.getAssignee item
                    ]
                , row [ Layout.lessRowSpacing ]
                    [ el [] <| ActionItem.getIcon item
                    , el [] <|
                        text <|
                            ActionItem.statusToString <|
                                ActionItem.getStatus item
                    ]
                ]
        ]


card : Card msg -> Element msg
card (Card str variant) =
    let
        element =
            column
                (styles
                    { highlight =
                        case variant of
                            Display ->
                                False

                            Action item _ ->
                                ActionItem.isComplete item

                            Link _ ->
                                False

                            BasicAction _ ->
                                False
                    }
                )
            <|
                case variant of
                    Display ->
                        [ el
                            [ paddingXY 15 25
                            ]
                          <|
                            text str
                        ]

                    Action item msgs ->
                        let
                            toDoButton =
                                Input.secondaryActionButton
                                    { onPress = msgs.setNotStarted
                                    , labelString = "Not started"
                                    }

                            inProgressButton =
                                Input.primaryActionButton
                                    { onPress = msgs.setInProgress
                                    , labelString = "Started"
                                    }

                            completedButton =
                                Input.primaryActionButton
                                    { onPress = msgs.setComplete
                                    , labelString = "Complete"
                                    }
                        in
                        [ basicActionCard item
                        , el
                            [ Border.widthEach { edges | top = 2 }
                            , width fill
                            , Border.color Colours.mediumBlueTransparent
                            , paddingXY 0 20
                            ]
                          <|
                            el
                                [ alignRight
                                , paddingXY 20 0
                                ]
                                (if ActionItem.isComplete item then
                                    row [ Layout.commonRowSpacing ]
                                        [ toDoButton
                                        , inProgressButton
                                        ]

                                 else if ActionItem.isInProgress item then
                                    row [ Layout.commonRowSpacing ]
                                        [ toDoButton
                                        , completedButton
                                        ]

                                 else
                                    row [ Layout.commonRowSpacing ]
                                        [ inProgressButton
                                        , completedButton
                                        ]
                                )
                        ]

                    BasicAction item ->
                        [ basicActionCard item
                        ]

                    Link _ ->
                        [ row
                            [ width fill
                            , paddingXY 20 10
                            , Background.color Colours.mediumBlue
                            , Border.rounded 5
                            , Font.color Colours.white
                            ]
                            [ el
                                (centerX :: Font.title)
                              <|
                                text str
                            , el
                                [ alignRight
                                ]
                              <|
                                Icons.rightArrow
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
            element


link : String -> Route -> Element msg
link str route =
    card <| Card str <| Link route


action : ActionItem -> ActionMsgs msg -> Element msg
action item msgs =
    card <|
        Card (ActionItem.getContent item) <|
            Action item msgs


basicAction : ActionItem -> Element msg
basicAction item =
    card <|
        Card (ActionItem.getContent item) <|
            BasicAction item


display : String -> Element msg
display str =
    card <| Card str Display
