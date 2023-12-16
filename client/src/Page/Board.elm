module Page.Board exposing (Model, Msg, init, update, view)

import Components
import Components.Colours as Colours
import Components.Font as Font
import Components.Icons as Icons
import Components.Input as Input
import Components.Layout as Layout exposing (Layout, commonRowSpacing)
import DiscussionItem exposing (DiscussionItem)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Page.Board.AddingItems as AddingItems
import Page.Board.Intro as Intro
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
                Intro.view

            AddingDiscussionItems discussionItems ->
                AddingItems.view layout
                    { updateField =
                        on << UpdateField
                    }
                    discussionItems
        , Components.link Route.Dashboard [] "Back to dashboard"
        ]


init : String -> Model
init boardId =
    -- TODO: Add Loading state and fetch board here
    Model boardId <| ReadyToStart
