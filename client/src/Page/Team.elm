module Page.Team exposing (Model, Msg, init, update, view)

import ActionItem exposing (ActionItem)
import Components
import Components.Card as Card
import Components.Font as Font
import Components.Icons as Icons
import Components.Layout as Layout exposing (Layout)
import Components.Navigation as Navigation
import Element exposing (..)
import Element.Font as Font
import Http
import Route exposing (Route)
import Team
import UniqueID exposing (UniqueID)



-- MODEL


type Model
    = Model
        { teamId : UniqueID
        }
        State


type State
    = LoadingTeam
        { members : Maybe (List Team.MemberDetails)
        , actions : Maybe (List ActionItem)
        }
    | ViewingTeam
        { members : List Team.MemberDetails
        , actions : List ActionItem
        }
    | Error String



-- UPDATE


type Msg
    = MemberDetailsReceived (Result Http.Error (List Team.MemberDetails))
    | ActionItemsReceived (Result Http.Error (List ActionItem))


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg ((Model details state) as model) =
    case msg of
        MemberDetailsReceived (Ok memberDetails) ->
            case state of
                LoadingTeam { actions } ->
                    case actions of
                        Just fetchedActions ->
                            ( Model details <|
                                ViewingTeam
                                    { actions = fetchedActions
                                    , members = memberDetails
                                    }
                            , Cmd.none
                            )

                        Nothing ->
                            ( Model details <|
                                LoadingTeam
                                    { actions = actions
                                    , members = Just memberDetails
                                    }
                            , Cmd.none
                            )

                _ ->
                    ( model, Cmd.none )

        MemberDetailsReceived (Err error) ->
            ( Model details <|
                Error <|
                    case error of
                        Http.BadUrl url ->
                            "Bad URL: " ++ url

                        Http.Timeout ->
                            "Timeout"

                        Http.NetworkError ->
                            "Network error"

                        Http.BadStatus status ->
                            "Bad status: " ++ String.fromInt status

                        Http.BadBody body ->
                            "Bad body: " ++ body
            , Cmd.none
            )

        ActionItemsReceived (Ok actionItems) ->
            case state of
                LoadingTeam { members } ->
                    case members of
                        Just fetchedMembers ->
                            ( Model details <|
                                ViewingTeam
                                    { actions = actionItems
                                    , members = fetchedMembers
                                    }
                            , Cmd.none
                            )

                        Nothing ->
                            ( Model details <|
                                LoadingTeam
                                    { actions = Just actionItems
                                    , members = members
                                    }
                            , Cmd.none
                            )

                _ ->
                    ( model, Cmd.none )

        ActionItemsReceived (Err error) ->
            ( Model details <|
                Error <|
                    case error of
                        Http.BadUrl url ->
                            "Bad URL: " ++ url

                        Http.Timeout ->
                            "Timeout"

                        Http.NetworkError ->
                            "Network error"

                        Http.BadStatus status ->
                            "Bad status: " ++ String.fromInt status

                        Http.BadBody body ->
                            "Bad body: " ++ body
            , Cmd.none
            )



-- VIEW


titleAndButton : String -> Route -> Element msg
titleAndButton title route =
    row [ width fill ]
        [ el [ Font.bold ] <| text title
        , el [ alignRight ] <| Navigation.iconLink Icons.createNewTeam <| route
        ]


teamView : Layout -> UniqueID -> List Team.MemberDetails -> List ActionItem -> Element msg
teamView layout teamId members actions =
    column
        [ width fill
        , spacing 24
        ]
        [ Layout.containingElement layout
            [ width fill
            , spacing 40
            ]
            [ column
                [ width fill
                , spacing 24
                , alignTop
                ]
                [ titleAndButton "Members" <|
                    Route.AddTeamMembers <|
                        UniqueID.toString teamId
                , if List.isEmpty members then
                    el [] <| text "There are no members in this team!"

                  else
                    column
                        [ width fill
                        , spacing 24
                        ]
                        (members
                            |> List.map
                                (\member ->
                                    Components.card <|
                                        column
                                            [ width fill
                                            , spacing 24
                                            ]
                                            [ el [ Font.bold ] <| text member.name
                                            , el [] <| text member.email
                                            ]
                                )
                        )
                ]
            , column
                [ width fill
                , spacing 24
                , alignTop
                ]
                [ titleAndButton "Actions" <|
                    Route.AddTeamMembers <|
                        UniqueID.toString teamId
                , if List.isEmpty actions then
                    el [] <| text "There are no actions for this team"

                  else
                    column
                        [ width fill
                        , spacing 24
                        ]
                        (actions
                            |> List.map
                                (\action ->
                                    el
                                        (Card.styles
                                            { highlight =
                                                ActionItem.isComplete action
                                            }
                                        )
                                    <|
                                        Card.basicActionCard action
                                )
                        )
                ]
            ]
        ]


view : (Msg -> msg) -> Layout -> Model -> Element msg
view on layout (Model { teamId } state) =
    Layout.page
        [ Font.heading "My Team"
        , case state of
            LoadingTeam _ ->
                el
                    [ centerX
                    , centerY
                    ]
                <|
                    text "Fetching team details..."

            Error str ->
                el
                    [ centerX
                    , centerY
                    ]
                <|
                    text str

            ViewingTeam { members, actions } ->
                teamView layout teamId members actions
        ]


init : (Msg -> msg) -> UniqueID -> ( Model, Cmd msg )
init on teamId =
    ( Model { teamId = teamId } <|
        LoadingTeam
            { actions = Nothing
            , members = Nothing
            }
    , Cmd.batch
        [ Team.getMemberDetails teamId <|
            on
                << MemberDetailsReceived
        , Team.getActionItems teamId <|
            on
                << ActionItemsReceived
        ]
    )
