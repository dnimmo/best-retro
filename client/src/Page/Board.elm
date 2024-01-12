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
import Team exposing (Team)
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
    | ReadyToStart { facilitator : User }
    | DiscussingPreviousActions
        { facilitator : User
        , actions : List ActionItem
        }
    | AddingDiscussionItems
        { facilitator : User
        , inputs : AddingItemsInputs
        , items : List DiscussionItem
        , timer : Timer.Model
        }
    | GroupingItems
        { facilitator : User
        , items : List DiscussionItem
        , toGroup : Set String
        }
    | Voting
        { facilitator : User
        , items :
            List
                { item : DiscussionItem
                , votes : Set String
                }
        , timer : Timer.Model
        }
    | Discussing
        { facilitator : User
        , items :
            List
                { item : DiscussionItem
                , votes : Set String
                }
        , actions :
            List ActionItem
        , discussed : List DiscussionItem
        , currentDiscussion :
            Maybe
                { item : DiscussionItem
                , timer : Timer.Model
                , actionField : String
                , assignee : String
                }
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
                    ( Model user
                        boardId
                        startTime
                        (ReadyToStart { facilitator = user }
                         -- TODO load the facilitator from the server
                        )
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ReadyToStart _ ->
            case msg of
                ViewPreviousActions ->
                    ( Model user boardId startTime <|
                        DiscussingPreviousActions
                            { facilitator = user
                            , actions = ActionItem.notCompletedBefore startTime ActionItem.devActionItems
                            }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        DiscussingPreviousActions data ->
            case msg of
                BackToStart ->
                    ( Model user boardId startTime <| ReadyToStart { facilitator = user }
                    , Cmd.none
                    )

                MarkActionAsNotStarted actionItem ->
                    ( Model user boardId startTime <|
                        DiscussingPreviousActions
                            { data
                                | actions =
                                    ActionItem.setToDo (ActionItem.getId actionItem) data.actions
                            }
                    , Cmd.none
                    )

                MarkActionAsStarted actionItem ->
                    ( Model user boardId startTime <|
                        DiscussingPreviousActions
                            { data
                                | actions =
                                    ActionItem.setInProgress (ActionItem.getId actionItem) data.actions
                            }
                    , Cmd.none
                    )

                MarkActionAsComplete actionItem ->
                    ( Model user boardId startTime <|
                        DiscussingPreviousActions
                            { data
                                | actions =
                                    ActionItem.setComplete (ActionItem.getId actionItem) data.actions
                            }
                    , Cmd.none
                    )

                StartAddingItems ->
                    ( Model user boardId startTime <|
                        AddingDiscussionItems
                            { inputs = defaultAddingItemsInputs
                            , items = []
                            , timer = Timer.init 5
                            , facilitator = user
                            }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        AddingDiscussionItems data ->
            let
                inputs =
                    data.inputs
            in
            case msg of
                TimerMsg timerMsg ->
                    ( Model user boardId startTime <|
                        AddingDiscussionItems
                            { data
                                | timer =
                                    Timer.update timerMsg data.timer
                            }
                    , Cmd.none
                    )

                UpdateField field str ->
                    ( Model user boardId startTime <|
                        AddingDiscussionItems
                            { data
                                | inputs =
                                    case field of
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
                            }
                    , Cmd.none
                    )

                SubmitField field ->
                    ( Model user boardId startTime <|
                        AddingDiscussionItems
                            { data
                                | inputs =
                                    case field of
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
                                , items =
                                    (case field of
                                        Start ->
                                            DiscussionItem.createStartItem
                                                { authorID = User.getId user
                                                , content = inputs.start
                                                , timestamp = now
                                                }

                                        Stop ->
                                            DiscussionItem.createStopItem
                                                { authorID = User.getId user
                                                , content = inputs.stop
                                                , timestamp = now
                                                }

                                        Continue ->
                                            DiscussionItem.createContinueItem
                                                { authorID = User.getId user
                                                , content = inputs.continue
                                                , timestamp = now
                                                }
                                    )
                                        :: data.items
                            }
                    , Cmd.none
                      -- TODO send new item to server
                    )

                RemoveDiscussionItem item ->
                    ( Model user boardId startTime <|
                        AddingDiscussionItems
                            { data
                                | items =
                                    data.items
                                        |> List.filter (\i -> item /= i)
                            }
                    , Cmd.none
                    )

                StartGroupingItems ->
                    ( Model user boardId startTime <|
                        GroupingItems
                            { facilitator = user
                            , items = data.items
                            , toGroup = Set.empty
                            }
                    , Cmd.none
                    )

                PopulateDummyItems ->
                    ( Model user boardId startTime <|
                        AddingDiscussionItems
                            { data
                                | items =
                                    data.items
                                        ++ DiscussionItem.devDiscussionItems
                            }
                    , Cmd.none
                    )

                ViewPreviousActions ->
                    ( Model user boardId startTime <|
                        DiscussingPreviousActions
                            { facilitator = user
                            , actions =
                                ActionItem.notCompletedBefore startTime ActionItem.devActionItems
                            }
                    , Cmd.none
                    )

                BackToStart ->
                    ( Model user boardId startTime <|
                        ReadyToStart { facilitator = user }
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
                            { facilitator = user
                            , items = items
                            , toGroup =
                                if Set.member comparableId toGroup then
                                    Set.remove comparableId toGroup

                                else
                                    Set.insert comparableId toGroup
                            }
                    , Cmd.none
                    )

                GroupItems ->
                    case
                        List.filter
                            (\item ->
                                Set.member
                                    (UniqueID.toComparable
                                        (DiscussionItem.getId item)
                                    )
                                    toGroup
                            )
                            items
                    of
                        head :: remainingItems ->
                            let
                                newItem =
                                    DiscussionItem.merge ( head, remainingItems )

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
                                    { facilitator = user
                                    , items = newItem :: updatedItemList
                                    , toGroup = Set.empty
                                    }
                            , Cmd.none
                            )

                        _ ->
                            ( model, Cmd.none )

                MoveToVoting ->
                    ( Model user boardId startTime <|
                        Voting
                            { facilitator = user
                            , items =
                                items
                                    |> List.map
                                        (\item ->
                                            { item = item
                                            , votes = Set.empty
                                            }
                                        )
                            , timer = Timer.init 2
                            }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        Voting data ->
            case msg of
                TimerMsg timerMsg ->
                    ( Model user boardId startTime <|
                        Voting
                            { data
                                | timer =
                                    Timer.update timerMsg data.timer
                            }
                    , Cmd.none
                    )

                ToggleVote item ->
                    ( Model user boardId startTime <|
                        Voting
                            { data
                                | items =
                                    data.items
                                        |> List.map
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
                            }
                    , Cmd.none
                    )

                StartDiscussing ->
                    ( Model user boardId startTime <|
                        Discussing
                            { facilitator = user
                            , items = data.items
                            , currentDiscussion = Nothing
                            , actions = []
                            , discussed = []
                            }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        Discussing data ->
            case msg of
                MoveToVoting ->
                    ( Model user boardId startTime <|
                        Voting
                            { facilitator = user
                            , items = data.items
                            , timer = Timer.init 5
                            }
                    , Cmd.none
                    )

                TimerMsg timerMsg ->
                    case data.currentDiscussion of
                        Just details ->
                            ( Model user boardId startTime <|
                                Discussing
                                    { data
                                        | currentDiscussion =
                                            Just
                                                { details
                                                    | timer = Timer.update timerMsg details.timer
                                                }
                                    }
                            , Cmd.none
                            )

                        Nothing ->
                            ( model, Cmd.none )

                DiscussItem item ->
                    ( Model user boardId startTime <|
                        Discussing
                            { data
                                | currentDiscussion =
                                    Just
                                        { item = item
                                        , timer = Timer.init 5
                                        , actionField = ""
                                        , assignee = ""
                                        }
                            }
                    , Cmd.none
                    )

                CancelDiscussion ->
                    ( Model user boardId startTime <|
                        Discussing
                            { data
                                | currentDiscussion = Nothing
                            }
                    , Cmd.none
                    )

                UpdateActionField str ->
                    ( Model user boardId startTime <|
                        Discussing
                            { data
                                | currentDiscussion =
                                    Maybe.map
                                        (\details ->
                                            { details
                                                | actionField = str
                                            }
                                        )
                                        data.currentDiscussion
                            }
                    , Cmd.none
                    )

                UpdateAssigneeField str ->
                    ( Model user boardId startTime <|
                        Discussing
                            { data
                                | currentDiscussion =
                                    data.currentDiscussion
                                        |> Maybe.map
                                            (\details ->
                                                { details
                                                    | assignee = str
                                                }
                                            )
                            }
                    , Cmd.none
                    )

                SubmitAction ->
                    ( Model user boardId startTime <|
                        Discussing
                            { data
                                | currentDiscussion =
                                    Maybe.map
                                        (\details ->
                                            { details
                                                | actionField = ""
                                                , assignee = ""
                                            }
                                        )
                                        data.currentDiscussion
                                , actions =
                                    case data.currentDiscussion of
                                        Just { item, actionField, assignee } ->
                                            if (String.isEmpty <| String.trim actionField) || (String.isEmpty <| String.trim assignee) then
                                                data.actions

                                            else
                                                ActionItem.new
                                                    { description = String.trim actionField
                                                    , author = User.getId user
                                                    , now = now
                                                    , maybeDiscussionItem = Just item
                                                    , assignee = assignee
                                                    }
                                                    :: data.actions

                                        Nothing ->
                                            data.actions
                            }
                    , Cmd.none
                    )

                FinishDiscussingItem item ->
                    ( Model user boardId startTime <|
                        Discussing
                            { data
                                | discussed = item :: data.discussed
                                , currentDiscussion = Nothing
                            }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )



-- VIEW


addFacilitatorControls : User -> State -> (Msg -> msg) -> Element msg
addFacilitatorControls loggedInUser state on =
    let
        common facilitator controls =
            column
                [ width fill ]
                [ row [ Layout.lessRowSpacing ]
                    [ el [] Icons.facilitator
                    , el Font.label <| text <| User.getName facilitator
                    ]
                , row
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
                        controls
                    ]
                ]
    in
    case state of
        Loading ->
            Input.rightIconButton
                { onPress = on SimulateLoading
                , icon = Icons.startSession
                , labelText = "Load"
                }

        ReadyToStart { facilitator } ->
            common facilitator
                [ Input.rightIconButton
                    { onPress = on ViewPreviousActions
                    , icon = Icons.startSession
                    , labelText = "Start"
                    }
                ]

        DiscussingPreviousActions { facilitator } ->
            common facilitator
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

        AddingDiscussionItems { facilitator, items } ->
            common facilitator
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

        GroupingItems { facilitator } ->
            common facilitator
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

        Voting { facilitator } ->
            common facilitator
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

        Discussing { facilitator } ->
            common facilitator
                [ Input.leftIconButton
                    { onPress = on MoveToVoting
                    , icon = Icons.back
                    , labelText = "Back"
                    }
                ]


view : Layout -> (Msg -> msg) -> Model -> Element msg
view layout on (Model user boardId startTime state) =
    column
        [ width fill
        , height fill
        , Layout.commonPadding
        , Layout.commonColumnSpacing
        ]
        [ addFacilitatorControls user state on
        , case state of
            Loading ->
                Loading.view

            ReadyToStart _ ->
                Intro.view

            DiscussingPreviousActions { actions } ->
                PreviousActions.view
                    layout
                    { markActionAsNotStarted = on << MarkActionAsNotStarted
                    , markActionAsInProgress = on << MarkActionAsStarted
                    , markActionAsComplete = on << MarkActionAsComplete
                    }
                    actions

            AddingDiscussionItems { inputs, items, timer } ->
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
                    items

            GroupingItems { items, toGroup } ->
                GroupingItems.view
                    layout
                    { addToGroupingList = on << AddToGroupingList
                    , groupItems = on GroupItems
                    , itemsInGroupingList =
                        Set.toList toGroup
                    }
                    items

            Voting { items, timer } ->
                Voting.view
                    layout
                    user
                    timer
                    { toggleVoteMsg = on << ToggleVote
                    , onTimerMsg = on << TimerMsg
                    }
                    items

            Discussing { items, actions, currentDiscussion, discussed } ->
                let
                    { assigneeValue, currentDiscussionItem, actionValue } =
                        case currentDiscussion of
                            Just { assignee, item, timer, actionField } ->
                                { assigneeValue = assignee
                                , currentDiscussionItem = Just ( item, timer )
                                , actionValue = actionField
                                }

                            Nothing ->
                                { assigneeValue = ""
                                , currentDiscussionItem = Nothing
                                , actionValue = ""
                                }
                in
                Discussing.view layout
                    { startDiscussion = on << DiscussItem
                    , updateActionField = on << UpdateActionField
                    , updateAssigneeField = on << UpdateAssigneeField
                    , finishDiscussingItem = on << FinishDiscussingItem
                    , submitAction = on SubmitAction
                    , cancelDiscussion = on CancelDiscussion
                    , actionField = actionValue
                    , discussed = discussed
                    , currentlyDiscussing = currentDiscussionItem
                    , assignee = assigneeValue
                    , onTimerMsg = on << TimerMsg
                    }
                    items
                    actions
        , Components.link Route.Dashboard [] "Back to dashboard"
        ]


init : User -> Team -> String -> Time.Posix -> Model
init user team boardId now =
    Model user boardId now Loading


subscriptions : (Msg -> msg) -> Model -> Sub msg
subscriptions on (Model _ _ _ state) =
    case state of
        AddingDiscussionItems { timer } ->
            Timer.subscriptions (on << TimerMsg) timer

        Voting { timer } ->
            Timer.subscriptions (on << TimerMsg) timer

        Discussing { currentDiscussion } ->
            case currentDiscussion of
                Just { timer } ->
                    Timer.subscriptions (on << TimerMsg) timer

                Nothing ->
                    Sub.none

        _ ->
            Sub.none
