module Page.Dashboard exposing (Model, Msg, init, update, view)

import Components exposing (edges)
import Components.Card as Card
import Components.Colours as Colours
import Components.Font as Font
import Components.Icons as Icons
import Components.Layout as Layout
import Element exposing (..)
import Element.Border as Border
import Element.Font as EFont
import Http
import Route
import Team exposing (Team)
import User exposing (User)



-- MODEL


type Model
    = Model User State


type State
    = Loading
    | Loaded { focusedTeam : Maybe Team }
    | Error String



-- UPDATE


type Msg
    = TeamReceived (Result Http.Error Team)


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg (Model user state) =
    case msg of
        TeamReceived (Ok team) ->
            ( Model user <| Loaded { focusedTeam = Just team }
            , Cmd.none
            )

        TeamReceived (Err err) ->
            ( Model user <|
                Error <|
                    "Error fetching team details: "
                        ++ (case err of
                                Http.BadUrl url ->
                                    "Bad URL: " ++ url

                                Http.Timeout ->
                                    "Timeout"

                                Http.NetworkError ->
                                    "Network Error"

                                Http.BadStatus status ->
                                    "Bad Status: " ++ String.fromInt status

                                Http.BadBody body ->
                                    "Bad Body: " ++ body
                           )
            , Cmd.none
            )



-- VIEW


loadingView : List (Element msg)
loadingView =
    [ Element.text "Loading..." ]


teamView : User -> Maybe Team -> Element msg
teamView user maybeTeam =
    column
        [ spacing 12
        , width fill
        ]
        [ row [ width fill ]
            [ row
                [ spacing 12
                , width fill
                ]
                [ el [ EFont.color Colours.mediumBlue ] <| Icons.group
                , Font.headingTwo "Your team"
                ]
            , el [ alignRight ] <|
                if List.isEmpty <| User.getTeams user then
                    Card.link "Create team" Route.CreateTeam

                else
                    Card.link "Switch team" Route.MyTeams
            ]
        , case maybeTeam of
            Just team ->
                paragraph []
                    [ el [] <|
                        text <|
                            Team.getName team
                    ]

            Nothing ->
                paragraph []
                    [ el [] <|
                        text <|
                            if List.isEmpty <| User.getTeams user then
                                "You are not currently part of any teams"

                            else
                                "No team selected"
                    ]
        ]


actionsView : User -> Element msg
actionsView user =
    column
        [ width fill
        , spacing 12
        ]
        [ row
            [ spacing 12
            , width fill
            ]
            [ el [ EFont.color Colours.mediumBlue ] <| Icons.task
            , Font.headingTwo "Your actions"
            ]
        , text "TODO: Actions here"
        ]


boardsView : User -> Maybe Team -> Element msg
boardsView user maybeTeam =
    column
        [ width fill
        , spacing 12
        ]
        [ row [ width fill ]
            [ row
                [ width fill
                , spacing 12
                ]
                [ el [ EFont.color Colours.mediumBlue ] <| Icons.board
                , Font.headingTwo "Your retro boards"
                ]
            , el [] <|
                Card.link "Create a new board" <|
                    Route.Board "dev-board"
            ]
        , case maybeTeam of
            Just _ ->
                text "TODO: Board info here"

            Nothing ->
                if List.isEmpty <| User.getTeams user then
                    column
                        [ spacing 24
                        , width fill
                        ]
                        [ paragraph [] [ el [] <| text "You will need to create or join a team before you can create a new board" ]
                        ]

                else
                    column [ spacing 24 ]
                        [ paragraph [] [ el [] <| text "You will need to select a team before you can create a new board" ]
                        ]
        ]


loadedView : User -> Maybe Team -> List (Element msg)
loadedView user maybeTeam =
    let
        section =
            el
                [ width fill
                , paddingEach
                    { edges
                        | top = 12
                        , bottom = 48
                    }
                , Border.color Colours.mediumBlueTransparent
                , Border.widthEach
                    { edges
                        | top =
                            2
                    }
                ]
    in
    [ row [ width fill ]
        [ Font.heading <|
            "Hi, "
                ++ User.getName user
                ++ "!"
        ]
    , column
        [ width fill
        , spacing 12
        ]
        [ section <| teamView user maybeTeam
        , section <| actionsView user
        , section <| boardsView user maybeTeam
        ]
    ]


errorView : String -> List (Element msg)
errorView str =
    [ Element.text str ]


view : (Msg -> msg) -> Model -> Element msg
view on (Model user state) =
    column
        [ width fill
        , height fill
        , Layout.commonPadding
        , spacing 36
        ]
    <|
        case state of
            Loading ->
                loadingView

            Loaded { focusedTeam } ->
                loadedView user focusedTeam

            Error str ->
                errorView str


init : (Msg -> msg) -> User -> ( Model, Cmd msg )
init on user =
    case User.getFocusedTeamId user of
        Just id ->
            ( Model user <| Loaded { focusedTeam = Nothing }
            , Team.getTeam id <| on << TeamReceived
            )

        Nothing ->
            ( Model user <| Loaded { focusedTeam = Nothing }
            , Cmd.none
            )
