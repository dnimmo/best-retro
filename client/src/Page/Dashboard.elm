module Page.Dashboard exposing (Model, Msg, init, update, view)

import Components.Card as Card
import Components.Font as Font
import Components.Layout as Layout
import Element exposing (..)
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


loadedView : Maybe Team -> List (Element msg)
loadedView maybeTeam =
    [ row [ width fill ]
        [ case maybeTeam of
            Just team ->
                Font.heading <| Team.getName team

            Nothing ->
                Element.text "No team selected"
        , Card.link "Switch team" Route.MyTeams
        ]
    , Card.link "Board (For Dev)" <| Route.Board "dev-board"
    ]


errorView : String -> List (Element msg)
errorView str =
    [ Element.text str ]


view : (Msg -> msg) -> Model -> Element msg
view on (Model _ state) =
    column
        [ width fill
        , height fill
        , Layout.commonPadding
        , Layout.commonColumnSpacing
        ]
    <|
        case state of
            Loading ->
                loadingView

            Loaded { focusedTeam } ->
                loadedView focusedTeam

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
