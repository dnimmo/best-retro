module Page.Board exposing (Model, Msg, init, update, view)

import ActionItem exposing (ActionItem)
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
import Page.Board.DiscussingPreviousActions as PreviousActions
import Page.Board.Intro as Intro
import Route



-- MODEL


type alias BoardID =
    String


type Model
    = Model BoardID State


type State
    = ReadyToStart
    | DiscussingPreviousActions (List ActionItem)
    | AddingDiscussionItems (List DiscussionItem)



-- UPDATE


type Msg
    = UpdateField String
    | StartAddingItems
    | ViewPreviousActions
    | BackToStart
    | MarkActionAsComplete ActionItem


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg ((Model boardId state) as model) =
    case msg of
        UpdateField str ->
            ( model
            , Cmd.none
            )

        StartAddingItems ->
            ( Model boardId <| AddingDiscussionItems DiscussionItem.devDiscussionItems
            , Cmd.none
            )

        ViewPreviousActions ->
            ( Model boardId <| DiscussingPreviousActions ActionItem.devActionItems
            , Cmd.none
            )

        BackToStart ->
            ( Model boardId ReadyToStart
            , Cmd.none
            )

        MarkActionAsComplete actionItem ->
            ( model
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
                        { onPress = on ViewPreviousActions
                        , icon = Icons.startSession
                        , labelText = "Start"
                        }
                    ]

                DiscussingPreviousActions _ ->
                    [ Input.leftIconButton
                        { onPress = on BackToStart
                        , icon = Icons.back
                        , labelText = "Back"
                        }
                    , Input.rightIconButton
                        { onPress = on StartAddingItems
                        , icon = Icons.forward
                        , labelText = "Add items"
                        }
                    ]

                AddingDiscussionItems _ ->
                    [ Input.leftIconButton
                        { onPress = on ViewPreviousActions
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

            DiscussingPreviousActions previousActions ->
                PreviousActions.view layout { markActionAsComplete = on << MarkActionAsComplete } previousActions

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
