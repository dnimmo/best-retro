module Page.Dashboard exposing (Model, Msg, init, update, view)

import Components exposing (edges)
import Components.Colours as Colours
import Components.Font as Font
import Components.Icons as Icons
import Components.Layout as Layout exposing (Layout)
import Components.Navigation as Navigation
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as EFont
import Http
import Route
import Team exposing (Team)
import UniqueID
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


teamView : { displayControls : Bool } -> User -> Maybe Team -> Element msg
teamView { displayControls } user maybeTeam =
    column
        [ spacing 12
        , width fill
        ]
        [ row [ width fill ]
            [ row
                [ spacing 12
                , width fill
                , alignTop
                ]
                [ el [ EFont.color Colours.mediumBlue ] <| Icons.group
                , Font.headingTwo "Your team"
                ]
            , if displayControls then
                el [ alignRight ] <|
                    case maybeTeam of
                        Just team ->
                            row [ spacing 12 ]
                                [ Navigation.iconLink Icons.view <| Route.Team <| UniqueID.toString <| Team.getId team
                                , Navigation.iconLink Icons.swap Route.MyTeams
                                , Navigation.iconLink Icons.createNewTeam Route.CreateTeam
                                ]

                        Nothing ->
                            if List.isEmpty <| User.getTeams user then
                                Navigation.iconLink Icons.createNewTeam Route.CreateTeam

                            else
                                row [ spacing 12 ]
                                    [ Navigation.iconLink Icons.swap Route.MyTeams
                                    , Navigation.iconLink Icons.createNewTeam Route.CreateTeam
                                    ]

              else
                none
            ]
        , case maybeTeam of
            Just team ->
                column [ spacing 24 ]
                    [ paragraph []
                        [ el [] <|
                            text <|
                                Team.getName team
                        ]
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


actionsView : { displayControls : Bool } -> User -> Element msg
actionsView { displayControls } user =
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
            , if displayControls then
                el [ alignRight ] <|
                    Navigation.iconLink Icons.createNewTeam Route.CreateTeam

              else
                none
            ]
        , text "TODO: Actions here"
        ]


boardsView : { displayControls : Bool } -> User -> Maybe Team -> Element msg
boardsView { displayControls } user maybeTeam =
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
                , Font.headingTwo "Your boards"
                ]
            , if displayControls then
                el [ alignRight ] <| Navigation.iconLink Icons.createNewTeam <| Route.Board "dev-board"

              else
                none
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


errorView : String -> List (Element msg)
errorView str =
    [ Element.text str ]


controlSection : { divider : Bool } -> String -> List (Element msg) -> Element msg
controlSection { divider } title content =
    column
        [ width fill
        , spacing 12
        , Border.widthEach
            { edges
                | bottom =
                    if divider then
                        2

                    else
                        0
            }
        , paddingEach { edges | bottom = 12 }
        , Border.color Colours.mediumBlueTransparent
        ]
    <|
        (el [] <| text title)
            :: content


controls : State -> Element msg
controls state =
    case state of
        Loading ->
            none

        Loaded { focusedTeam } ->
            column
                [ alignTop
                , Layout.commonPadding
                , moveDown 36
                , spacing 24
                , EFont.size 16
                , Background.color Colours.mediumBlueTransparent
                , Border.rounded 5
                , width (px 200)
                ]
                [ controlSection { divider = focusedTeam /= Nothing }
                    "Teams"
                    [ case focusedTeam of
                        Just team ->
                            Navigation.iconLinkWithText "View" Icons.view <| Route.Team <| UniqueID.toString <| Team.getId team

                        Nothing ->
                            none
                    , case focusedTeam of
                        Just _ ->
                            Navigation.iconLinkWithText "Switch" Icons.swap Route.MyTeams

                        Nothing ->
                            none
                    , Navigation.iconLinkWithText "New" Icons.createNewTeam Route.CreateTeam
                    ]
                , case focusedTeam of
                    Just _ ->
                        controlSection { divider = True }
                            "Actions"
                            [ Navigation.iconLinkWithText "New" Icons.createNewTeam Route.CreateTeam
                            ]

                    Nothing ->
                        none
                , case focusedTeam of
                    Just _ ->
                        controlSection { divider = False }
                            "Boards"
                            [ Navigation.iconLinkWithText "New" Icons.createNewTeam Route.CreateTeam
                            ]

                    Nothing ->
                        none
                ]

        Error _ ->
            none


loadedView : Layout -> User -> Maybe Team -> List (Element msg)
loadedView layout user maybeTeam =
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

        displayControls =
            { displayControls = not <| displayControlPanel layout }
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
        [ section <| teamView displayControls user maybeTeam
        , section <| actionsView displayControls user
        , section <| boardsView displayControls user maybeTeam
        ]
    ]


displayControlPanel : Layout -> Bool
displayControlPanel layout =
    Layout.getWidth layout > 1424


view : (Msg -> msg) -> Layout -> Model -> Element msg
view on layout (Model user state) =
    row
        [ width fill
        , height fill
        ]
        [ row
            [ height fill
            , width fill
            , centerX
            , spacing 36
            ]
            [ column
                [ height fill
                , width fill
                , Layout.commonPadding
                , spacing 36
                , onRight <|
                    if displayControlPanel layout then
                        el [ paddingXY 24 0 ] <|
                            controls state

                    else
                        none
                ]
              <|
                case state of
                    Loading ->
                        loadingView

                    Loaded { focusedTeam } ->
                        loadedView layout user focusedTeam

                    Error str ->
                        errorView str
            ]
        ]


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
