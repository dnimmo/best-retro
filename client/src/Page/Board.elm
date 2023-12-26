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
import Time



-- MODEL


type alias BoardID =
    String


type Model
    = Model BoardID Time.Posix State


type State
    = ReadyToStart
    | DiscussingPreviousActions (List ActionItem)
    | AddingDiscussionItems AddingItemsInputs (List DiscussionItem)


type alias AddingItemsInputs =
    { start : String
    , stop : String
    , continue : String
    }



-- UPDATE


defaultAddingItemsInputs : AddingItemsInputs
defaultAddingItemsInputs =
    { start = ""
    , stop = ""
    , continue = ""
    }


type Field
    = Start
    | Stop
    | Continue


type Msg
    = StartAddingItems
    | PopulateDummyItems
    | ViewPreviousActions
    | BackToStart
    | MarkActionAsStarted ActionItem
    | MarkActionAsNotStarted ActionItem
    | MarkActionAsComplete ActionItem
    | UpdateField Field String
    | SubmitField Field


update : Time.Posix -> (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update now on msg ((Model boardId startTime state) as model) =
    case state of
        ReadyToStart ->
            case msg of
                ViewPreviousActions ->
                    ( Model boardId startTime <|
                        DiscussingPreviousActions <|
                            ActionItem.notCompletedBefore startTime ActionItem.devActionItems
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        DiscussingPreviousActions actionItems ->
            case msg of
                BackToStart ->
                    ( Model boardId startTime ReadyToStart
                    , Cmd.none
                    )

                MarkActionAsNotStarted actionItem ->
                    ( Model boardId startTime <|
                        DiscussingPreviousActions <|
                            ActionItem.setToDo (ActionItem.getId actionItem) actionItems
                    , Cmd.none
                    )

                MarkActionAsStarted actionItem ->
                    ( Model boardId startTime <|
                        DiscussingPreviousActions <|
                            ActionItem.setInProgress (ActionItem.getId actionItem) actionItems
                    , Cmd.none
                    )

                MarkActionAsComplete actionItem ->
                    ( Model boardId startTime <|
                        DiscussingPreviousActions <|
                            ActionItem.setComplete (ActionItem.getId actionItem) actionItems
                    , Cmd.none
                    )

                StartAddingItems ->
                    ( Model boardId startTime <| AddingDiscussionItems defaultAddingItemsInputs []
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        AddingDiscussionItems inputs discussionItems ->
            case msg of
                UpdateField field str ->
                    ( Model boardId startTime <|
                        AddingDiscussionItems
                            (case field of
                                Start ->
                                    { inputs
                                        | start = str
                                    }

                                Stop ->
                                    { inputs
                                        | stop = str
                                    }

                                Continue ->
                                    { inputs
                                        | continue = str
                                    }
                            )
                            discussionItems
                    , Cmd.none
                    )

                SubmitField field ->
                    ( Model boardId startTime <|
                        AddingDiscussionItems
                            (case field of
                                Start ->
                                    { inputs
                                        | start = ""
                                    }

                                Stop ->
                                    { inputs
                                        | stop = ""
                                    }

                                Continue ->
                                    { inputs
                                        | continue = ""
                                    }
                            )
                            ((case field of
                                Start ->
                                    DiscussionItem.createStartItem
                                        { authorID = "TODO - User ID here"
                                        , content = inputs.start
                                        , timestamp = now
                                        }

                                Stop ->
                                    DiscussionItem.createStopItem
                                        { authorID = "TODO - User ID here"
                                        , content = inputs.stop
                                        , timestamp = now
                                        }

                                Continue ->
                                    DiscussionItem.createContinueItem
                                        { authorID = "TODO - User ID here"
                                        , content = inputs.continue
                                        , timestamp = now
                                        }
                             )
                                :: discussionItems
                            )
                    , Cmd.none
                      -- TODO send new item to server
                    )

                PopulateDummyItems ->
                    ( Model boardId startTime <| AddingDiscussionItems inputs DiscussionItem.devDiscussionItems
                    , Cmd.none
                    )

                ViewPreviousActions ->
                    ( Model boardId startTime <|
                        DiscussingPreviousActions <|
                            ActionItem.notCompletedBefore startTime ActionItem.devActionItems
                    , Cmd.none
                    )

                BackToStart ->
                    ( Model boardId startTime ReadyToStart
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )



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

                AddingDiscussionItems _ items ->
                    [ Input.leftIconButton
                        { onPress = on ViewPreviousActions
                        , icon = Icons.back
                        , labelText = "Back"
                        }
                    , if List.isEmpty items then
                        Input.rightIconButton
                            { onPress = on PopulateDummyItems
                            , icon = Icons.forward
                            , labelText = "Add dummy items"
                            }

                      else
                        none
                    ]
            )
        ]


view : Layout -> (Msg -> msg) -> Model -> Element msg
view layout on (Model boardId startTime state) =
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
                PreviousActions.view layout
                    { markActionAsNotStarted = on << MarkActionAsNotStarted
                    , markActionAsInProgress = on << MarkActionAsStarted
                    , markActionAsComplete = on << MarkActionAsComplete
                    }
                    previousActions

            AddingDiscussionItems inputs discussionItems ->
                AddingItems.view layout
                    { msgs =
                        { updateStartField =
                            on << UpdateField Start
                        , updateStopField =
                            on << UpdateField Stop
                        , updateContinueField =
                            on << UpdateField Continue
                        , submitStartItem = on <| SubmitField Start
                        , submitStopItem = on <| SubmitField Stop
                        , submitContinueItem = on <| SubmitField Continue
                        }
                    , values =
                        { startField = inputs.start
                        , stopField = inputs.stop
                        , continueField = inputs.continue
                        }
                    }
                    discussionItems
        , Components.link Route.Dashboard [] "Back to dashboard"
        ]


init : String -> Time.Posix -> Model
init boardId now =
    -- TODO: Add Loading state and fetch board here
    Model boardId now ReadyToStart
