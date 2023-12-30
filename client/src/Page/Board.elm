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
import Page.Board.GroupingItems as GroupingItems
import Page.Board.Intro as Intro
import Page.Board.Loading as Loading
import Page.Board.Voting as Voting
import Route
import Set exposing (Set)
import Time
import UniqueID exposing (UniqueID)
import User exposing (User)



-- MODEL


type alias BoardID =
    String


type Model
    = Model User BoardID Time.Posix State


type State
    = Loading
    | ReadyToStart
    | DiscussingPreviousActions (List ActionItem)
    | AddingDiscussionItems AddingItemsInputs (List DiscussionItem)
    | GroupingItems
        { items : List DiscussionItem
        , toGroup : Set String
        }
    | Voting
        (List
            { item : DiscussionItem
            , votes : Set String
            }
        )


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
    = SimulateLoading
    | StartAddingItems
    | PopulateDummyItems
    | ViewPreviousActions
    | BackToStart
    | MarkActionAsStarted ActionItem
    | MarkActionAsNotStarted ActionItem
    | MarkActionAsComplete ActionItem
    | UpdateField Field String
    | SubmitField Field
    | RemoveDiscussionItem DiscussionItem
    | StartGroupingItems
    | AddToGroupingList UniqueID
    | GroupItems
    | StartVoting
    | ToggleVote DiscussionItem


update : Time.Posix -> (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update now on msg ((Model user boardId startTime state) as model) =
    let
        userId =
            User.getId user

        comparableUserId =
            UniqueID.toComparable userId
    in
    case state of
        Loading ->
            case msg of
                SimulateLoading ->
                    ( Model user boardId startTime ReadyToStart, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        ReadyToStart ->
            case msg of
                ViewPreviousActions ->
                    ( Model user boardId startTime <|
                        DiscussingPreviousActions <|
                            ActionItem.notCompletedBefore startTime ActionItem.devActionItems
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        DiscussingPreviousActions actionItems ->
            case msg of
                BackToStart ->
                    ( Model user boardId startTime ReadyToStart
                    , Cmd.none
                    )

                MarkActionAsNotStarted actionItem ->
                    ( Model user boardId startTime <|
                        DiscussingPreviousActions <|
                            ActionItem.setToDo (ActionItem.getId actionItem) actionItems
                    , Cmd.none
                    )

                MarkActionAsStarted actionItem ->
                    ( Model user boardId startTime <|
                        DiscussingPreviousActions <|
                            ActionItem.setInProgress (ActionItem.getId actionItem) actionItems
                    , Cmd.none
                    )

                MarkActionAsComplete actionItem ->
                    ( Model user boardId startTime <|
                        DiscussingPreviousActions <|
                            ActionItem.setComplete (ActionItem.getId actionItem) actionItems
                    , Cmd.none
                    )

                StartAddingItems ->
                    ( Model user boardId startTime <| AddingDiscussionItems defaultAddingItemsInputs []
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        AddingDiscussionItems inputs discussionItems ->
            case msg of
                UpdateField field str ->
                    ( Model user boardId startTime <|
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
                    ( Model user boardId startTime <|
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

                StartGroupingItems ->
                    ( Model user boardId startTime <|
                        GroupingItems
                            { items = discussionItems
                            , toGroup = Set.empty
                            }
                    , Cmd.none
                    )

                PopulateDummyItems ->
                    ( Model user boardId startTime <| AddingDiscussionItems inputs DiscussionItem.devDiscussionItems
                    , Cmd.none
                    )

                ViewPreviousActions ->
                    ( Model user boardId startTime <|
                        DiscussingPreviousActions <|
                            ActionItem.notCompletedBefore startTime ActionItem.devActionItems
                    , Cmd.none
                    )

                BackToStart ->
                    ( Model user boardId startTime ReadyToStart
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        GroupingItems { items, toGroup } ->
            case msg of
                AddToGroupingList id ->
                    let
                        comparableId =
                            UniqueID.toComparable id
                    in
                    ( Model user boardId startTime <|
                        GroupingItems
                            { items = items
                            , toGroup =
                                if Set.member comparableId toGroup then
                                    Set.remove comparableId toGroup

                                else
                                    Set.insert comparableId toGroup
                            }
                    , Cmd.none
                    )

                GroupItems ->
                    ( Model user boardId startTime <|
                        GroupingItems
                            { items = items
                            , toGroup = Set.empty
                            }
                    , Cmd.none
                    )

                StartVoting ->
                    ( Model user boardId startTime <|
                        Voting
                            (List.map
                                (\item ->
                                    { item = item
                                    , votes = Set.empty
                                    }
                                )
                                items
                            )
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        Voting details ->
            case msg of
                ToggleVote item ->
                    ( Model user boardId startTime <|
                        Voting <|
                            List.map
                                (\detail ->
                                    if detail.item == item then
                                        { detail
                                            | votes =
                                                (if Set.member comparableUserId detail.votes then
                                                    Set.remove

                                                 else
                                                    Set.insert
                                                )
                                                    comparableUserId
                                                    detail.votes
                                        }

                                    else
                                        detail
                                )
                                details
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
                Loading ->
                    [ Input.rightIconButton
                        { onPress = on SimulateLoading
                        , icon = Icons.startSession
                        , labelText = "Load"
                        }
                    ]

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
                    , Input.rightIconButton
                        { onPress = on StartGroupingItems
                        , icon = Icons.forward
                        , labelText = "Start grouping"
                        }
                    ]

                GroupingItems { items } ->
                    [ Input.leftIconButton
                        { onPress = on StartAddingItems
                        , icon = Icons.back
                        , labelText = "Back"
                        }
                    , Input.rightIconButton
                        { onPress = on StartVoting
                        , icon = Icons.forward
                        , labelText = "Start voting"
                        }
                    ]

                Voting _ ->
                    [ Input.leftIconButton
                        { onPress = on StartGroupingItems
                        , icon = Icons.back
                        , labelText = "Back"
                        }
                    ]
            )
        ]


view : Layout -> (Msg -> msg) -> Model -> Element msg
view layout on (Model user boardId startTime state) =
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
            Loading ->
                Loading.view

            ReadyToStart ->
                Intro.view

            DiscussingPreviousActions previousActions ->
                PreviousActions.view
                    layout
                    { markActionAsNotStarted = on << MarkActionAsNotStarted
                    , markActionAsInProgress = on << MarkActionAsStarted
                    , markActionAsComplete = on << MarkActionAsComplete
                    }
                    previousActions

            AddingDiscussionItems inputs discussionItems ->
                AddingItems.view
                    layout
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
                        , removeItem = on << RemoveDiscussionItem
                        }
                    , values =
                        { startField = inputs.start
                        , stopField = inputs.stop
                        , continueField = inputs.continue
                        }
                    }
                    discussionItems

            GroupingItems { items, toGroup } ->
                GroupingItems.view
                    layout
                    { addToGroupingList = on << AddToGroupingList
                    , groupItems = on GroupItems
                    , itemsInGroupingList =
                        Set.toList toGroup
                    }
                    items

            Voting items ->
                Voting.view
                    layout
                    user
                    (on << ToggleVote)
                    items
        , Components.link Route.Dashboard [] "Back to dashboard"
        ]


init : User -> String -> Time.Posix -> Model
init user boardId now =
    Model user boardId now Loading
