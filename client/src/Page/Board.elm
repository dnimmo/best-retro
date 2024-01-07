module Page.Board exposing (Model, Msg, init, subscriptions, update, view)

import ActionItem exposing (ActionItem)
import Components
import Components.Card exposing (CardVariant(..))
import Components.Colours as Colours
import Components.Font as Font
import Components.Icons as Icons
import Components.Input as Input
import Components.Layout as Layout exposing (Layout, commonRowSpacing)
import Components.Timer as Timer
import DiscussionItem exposing (DiscussionItem)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Page.Board.AddingItems as AddingItems
import Page.Board.Discussing as Discussing
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
    | AddingDiscussionItems AddingItemsInputs (List DiscussionItem) Timer.Model
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
        Timer.Model
    | Discussing
        (List
            { item : DiscussionItem
            , votes : Set String
            }
        )
        (List ActionItem)
        { currentlyDiscussing : Maybe ( DiscussionItem, Timer.Model )
        , actionField : String
        , assignee : String
        , discussed : List DiscussionItem
        }


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
    = TimerMsg Timer.Msg
    | SimulateLoading
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
    | MoveToVoting
    | ToggleVote DiscussionItem
    | StartDiscussing
    | DiscussItem DiscussionItem
    | UpdateActionField String
    | UpdateAssigneeField String
    | SubmitAction
    | CancelDiscussion
    | FinishDiscussingItem DiscussionItem


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
                    ( Model user boardId startTime <|
                        AddingDiscussionItems
                            defaultAddingItemsInputs
                            []
                        <|
                            Timer.init 5
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        AddingDiscussionItems inputs discussionItems timer ->
            case msg of
                TimerMsg timerMsg ->
                    ( Model user boardId startTime <|
                        AddingDiscussionItems inputs discussionItems <|
                            Timer.update timerMsg timer
                    , Cmd.none
                    )

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
                            timer
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
                            timer
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
                    ( Model user boardId startTime <| AddingDiscussionItems inputs DiscussionItem.devDiscussionItems timer
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
                    let
                        newItem =
                            items
                                |> List.filter (\item -> Set.member (UniqueID.toComparable (DiscussionItem.getId item)) toGroup)
                                |> DiscussionItem.merge

                        updatedItemList =
                            items
                                |> List.filter
                                    (\item ->
                                        not <|
                                            Set.member
                                                (UniqueID.toComparable
                                                    (DiscussionItem.getId item)
                                                )
                                                toGroup
                                    )
                    in
                    ( Model user boardId startTime <|
                        GroupingItems
                            { items = newItem :: updatedItemList
                            , toGroup = Set.empty
                            }
                    , Cmd.none
                    )

                MoveToVoting ->
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
                        <|
                            Timer.init 2
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        Voting details timer ->
            case msg of
                TimerMsg timerMsg ->
                    ( Model user boardId startTime <|
                        Voting details <|
                            Timer.update timerMsg timer
                    , Cmd.none
                    )

                ToggleVote item ->
                    ( Model user boardId startTime <|
                        Voting
                            (List.map
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
                            )
                            timer
                    , Cmd.none
                    )

                StartDiscussing ->
                    ( Model user boardId startTime <|
                        Discussing
                            details
                            []
                            { currentlyDiscussing = Nothing
                            , actionField = ""
                            , assignee = ""
                            , discussed = []
                            }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        Discussing discussionItemsAndVotes actions ({ currentlyDiscussing, actionField, assignee, discussed } as currentDiscussion) ->
            case msg of
                MoveToVoting ->
                    ( Model user boardId startTime <|
                        Voting
                            discussionItemsAndVotes
                        <|
                            Timer.init 5
                    , Cmd.none
                    )

                TimerMsg timerMsg ->
                    case currentDiscussion.currentlyDiscussing of
                        Just ( item, timer ) ->
                            ( Model user boardId startTime <|
                                Discussing
                                    discussionItemsAndVotes
                                    actions
                                    { currentDiscussion
                                        | currentlyDiscussing = Just ( item, Timer.update timerMsg timer )
                                    }
                            , Cmd.none
                            )

                        Nothing ->
                            ( model, Cmd.none )

                DiscussItem item ->
                    ( Model user boardId startTime <|
                        Discussing
                            discussionItemsAndVotes
                            actions
                            { currentDiscussion
                                | currentlyDiscussing = Just ( item, Timer.init 5 )
                                , actionField = ""
                                , assignee = ""
                            }
                    , Cmd.none
                    )

                CancelDiscussion ->
                    ( Model user boardId startTime <|
                        Discussing
                            discussionItemsAndVotes
                            actions
                            { currentDiscussion
                                | currentlyDiscussing = Nothing
                                , actionField = ""
                                , assignee = ""
                            }
                    , Cmd.none
                    )

                UpdateActionField str ->
                    ( Model user boardId startTime <|
                        Discussing
                            discussionItemsAndVotes
                            actions
                            { currentDiscussion
                                | actionField = str
                            }
                    , Cmd.none
                    )

                UpdateAssigneeField str ->
                    ( Model user boardId startTime <|
                        Discussing
                            discussionItemsAndVotes
                            actions
                            { currentDiscussion
                                | assignee = str
                            }
                    , Cmd.none
                    )

                SubmitAction ->
                    if (String.isEmpty <| String.trim actionField) || (String.isEmpty <| String.trim assignee) then
                        ( model, Cmd.none )

                    else
                        ( Model user boardId startTime <|
                            Discussing
                                discussionItemsAndVotes
                                (ActionItem.new
                                    { description = String.trim actionField
                                    , author = User.getId user
                                    , now = now
                                    , maybeDiscussionItem =
                                        Maybe.andThen
                                            (\( item, _ ) ->
                                                Just item
                                            )
                                            currentlyDiscussing
                                    , assignee = assignee
                                    }
                                    :: actions
                                )
                                { currentDiscussion
                                    | currentlyDiscussing = currentlyDiscussing
                                    , actionField = ""
                                    , assignee = ""
                                }
                        , Cmd.none
                        )

                FinishDiscussingItem item ->
                    ( Model user boardId startTime <|
                        Discussing
                            discussionItemsAndVotes
                            actions
                            { currentlyDiscussing = Nothing
                            , actionField = ""
                            , assignee = ""
                            , discussed = item :: discussed
                            }
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

                AddingDiscussionItems _ items timer ->
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

                GroupingItems _ ->
                    [ Input.leftIconButton
                        { onPress = on StartAddingItems
                        , icon = Icons.back
                        , labelText = "Back"
                        }
                    , Input.rightIconButton
                        { onPress = on MoveToVoting
                        , icon = Icons.forward
                        , labelText = "Start voting"
                        }
                    ]

                Voting _ _ ->
                    [ Input.leftIconButton
                        { onPress = on StartGroupingItems
                        , icon = Icons.back
                        , labelText = "Back"
                        }
                    , Input.rightIconButton
                        { onPress = on StartDiscussing
                        , icon = Icons.forward
                        , labelText = "Start Discussing"
                        }
                    ]

                Discussing _ _ _ ->
                    [ Input.leftIconButton
                        { onPress = on MoveToVoting
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

            AddingDiscussionItems inputs discussionItems timer ->
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
                        , onTimerMsg = on << TimerMsg
                        }
                    , values =
                        { startField = inputs.start
                        , stopField = inputs.stop
                        , continueField = inputs.continue
                        }
                    , timer = timer
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

            Voting items timer ->
                Voting.view
                    layout
                    user
                    timer
                    { toggleVoteMsg = on << ToggleVote
                    , onTimerMsg = on << TimerMsg
                    }
                    items

            Discussing itemsAndVotes actions { currentlyDiscussing, actionField, discussed, assignee } ->
                Discussing.view layout
                    { startDiscussion = on << DiscussItem
                    , updateActionField = on << UpdateActionField
                    , updateAssigneeField = on << UpdateAssigneeField
                    , finishDiscussingItem = on << FinishDiscussingItem
                    , submitAction = on SubmitAction
                    , cancelDiscussion = on CancelDiscussion
                    , actionField = actionField
                    , discussed = discussed
                    , currentlyDiscussing = currentlyDiscussing
                    , assignee = assignee
                    , onTimerMsg = on << TimerMsg
                    }
                    itemsAndVotes
                    actions
        , Components.link Route.Dashboard [] "Back to dashboard"
        ]


init : User -> String -> Time.Posix -> Model
init user boardId now =
    Model user boardId now Loading


subscriptions : (Msg -> msg) -> Model -> Sub msg
subscriptions on (Model _ _ _ state) =
    case state of
        AddingDiscussionItems _ _ timer ->
            Timer.subscriptions (on << TimerMsg) timer

        Voting _ timer ->
            Timer.subscriptions (on << TimerMsg) timer

        Discussing _ _ { currentlyDiscussing } ->
            case currentlyDiscussing of
                Just ( _, timer ) ->
                    Timer.subscriptions (on << TimerMsg) timer

                Nothing ->
                    Sub.none

        _ ->
            Sub.none
