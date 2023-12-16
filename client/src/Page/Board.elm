module Page.Board exposing (Model, Msg, init, update, view)

import Components exposing (edges)
import Components.Card as Card
import Components.Colours as Colours
import Components.Font as Font
import Components.Icons as Icons
import Components.Input as Input
import Components.Label as Label
import Components.Layout as Layout exposing (Layout, commonRowSpacing)
import DiscussionItem exposing (DiscussionItem)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Route



-- MODEL


type alias BoardID =
    String


type Model
    = Model BoardID State


type State
    = ReadyToStart
    | AddingDiscussionItems (List DiscussionItem)



-- UPDATE


type Msg
    = UpdateField String
    | StartSession
    | BackToStart


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg ((Model boardId state) as model) =
    case msg of
        UpdateField str ->
            ( model
            , Cmd.none
            )

        StartSession ->
            ( Model boardId <| AddingDiscussionItems DiscussionItem.devDiscussionItems
            , Cmd.none
            )

        BackToStart ->
            ( Model boardId ReadyToStart
            , Cmd.none
            )



-- VIEW


emptyDiscussionItemView : Element msg
emptyDiscussionItemView =
    el
        [ width fill
        , height fill
        ]
    <|
        column
            [ Layout.commonColumnSpacing
            , width fill
            , centerX
            , centerY
            ]
            [ el
                [ width fill
                , centerY
                ]
              <|
                image
                    [ width (fill |> maximum 300)
                    , centerX
                    , centerY
                    ]
                    { src = "/img/absurd-vial.png"
                    , description = "No items"
                    }
            , paragraph
                [ width (fill |> maximum 300)
                , centerX
                ]
                [ text "No items have been added yet. Add some items to talk about, or this is going to be a very short session!"
                ]
            ]


type Category
    = Start
    | Stop
    | Continue


discussionItemCard : Category -> DiscussionItem -> Element msg
discussionItemCard category discussionItem =
    column Card.styles
        [ row [ width fill ]
            [ paragraph []
                [ text <|
                    DiscussionItem.getContent discussionItem
                ]
            ]
        ]


discussionColumnStyles : List (Attribute msg)
discussionColumnStyles =
    [ width fill
    , Layout.commonColumnSpacing
    , alignTop
    ]


discussionItemColumn : List (Element msg) -> Element msg
discussionItemColumn =
    column
        [ Layout.commonColumnSpacing
        , paddingXY 0 20
        , width fill
        ]


addingDiscussionItemsView : Layout -> (Msg -> msg) -> List DiscussionItem -> Element msg
addingDiscussionItemsView layout on discussionItems =
    column
        [ width fill
        , height fill
        , Layout.commonColumnSpacing
        ]
        [ Layout.containingElement layout
            [ Layout.extraColumnSpacing
            , width fill
            ]
            [ column
                discussionColumnStyles
                [ Label.start
                , Input.inputFieldWithInsetButton
                    { onChange = on << UpdateField
                    , value = ""
                    , labelString = "What should we start doing?"
                    , onSubmit = on <| UpdateField "TODO: Submit"
                    }
                , discussionItemColumn <|
                    List.map (discussionItemCard Start) <|
                        DiscussionItem.getAllStartItems discussionItems
                ]
            , column
                discussionColumnStyles
                [ Label.stop
                , Input.inputFieldWithInsetButton
                    { onChange = on << UpdateField
                    , value = ""
                    , labelString = "What should we stop doing?"
                    , onSubmit = on <| UpdateField "TODO: Submit"
                    }
                , discussionItemColumn <|
                    List.map (discussionItemCard Stop) <|
                        DiscussionItem.getAllStopItems discussionItems
                ]
            , column
                discussionColumnStyles
                [ Label.continue
                , Input.inputFieldWithInsetButton
                    { onChange = on << UpdateField
                    , value = ""
                    , labelString = "What should we keep doing?"
                    , onSubmit = on <| UpdateField "TODO: Submit"
                    }
                , discussionItemColumn <|
                    List.map (discussionItemCard Continue) <|
                        DiscussionItem.getAllContinueItems discussionItems
                ]
            ]
        , if List.isEmpty discussionItems then
            emptyDiscussionItemView

          else
            none
        ]


boardControls : State -> (Msg -> msg) -> Element msg
boardControls state on =
    row
        [ Border.width 1
        , width fill
        , padding 20
        , Background.color Colours.mediumBlueTransparent
        , Border.rounded 5
        , Border.color Colours.darkBlue
        ]
        [ Icons.controls
        , row
            [ alignRight
            , commonRowSpacing
            ]
            (case state of
                ReadyToStart ->
                    [ Input.rightIconButton
                        { onPress = on StartSession
                        , icon = Icons.startSession
                        , labelText = "Start"
                        }
                    ]

                AddingDiscussionItems _ ->
                    [ Input.leftIconButton
                        { onPress = on BackToStart
                        , icon = Icons.back
                        , labelText = "Back"
                        }
                    ]
            )
        ]


view : Layout -> (Msg -> msg) -> Model -> Element msg
view layout on (Model boardId state) =
    column
        [ width fill
        , height fill
        , Layout.commonPadding
        , Layout.commonColumnSpacing
        ]
        [ row [ Layout.lessRowSpacing ]
            [ el [] Icons.facilitator
            , el Font.label <| text <| "Facilitator: " ++ "TODO: Get user name"
            ]
        , boardControls state on -- TODO: Only show these for the facilitator
        , case state of
            ReadyToStart ->
                el
                    [ width fill
                    , height fill
                    ]
                    none

            AddingDiscussionItems discussionItems ->
                addingDiscussionItemsView layout on discussionItems
        , Components.link Route.Dashboard [] "Back to dashboard"
        ]


init : String -> Model
init boardId =
    -- TODO: Add Loading state and fetch board here
    Model boardId <| ReadyToStart
