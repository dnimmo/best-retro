module Page.MyTeams exposing (Model, Msg, init, update, view)

import Components as C
import Components.Layout as Layout
import Element exposing (..)
import Http
import Route
import Team exposing (Team)
import User exposing (User)



-- MODEL


type Model
    = LoadingTeams
    | NotAMemberOfAnyTeam
    | ViewingTeamList (List Team)
    | Error String



-- UPDATE


type Msg
    = ReceivedTeamsResult (Result Http.Error (List Team))


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg model =
    case msg of
        ReceivedTeamsResult (Ok teams) ->
            ( if List.isEmpty teams then
                NotAMemberOfAnyTeam

              else
                ViewingTeamList teams
            , Cmd.none
            )

        ReceivedTeamsResult (Err err) ->
            ( Error <|
                case err of
                    Http.BadUrl url ->
                        "Bad URL: " ++ url

                    Http.Timeout ->
                        "Request timed out."

                    Http.NetworkError ->
                        "Network error."

                    Http.BadStatus status ->
                        "Bad status: " ++ String.fromInt status

                    Http.BadBody body ->
                        "Bad body: " ++ body
            , Cmd.none
            )



-- VIEW


teamCard : Team -> Element msg
teamCard team =
    C.card <|
        column
            [ width fill ]
            [ C.heading <| Team.getName team
            , C.link (Team.toRoute team) [] "View team"
            ]


teamView : List Team -> Element msg
teamView teams =
    column [ width fill ] <|
        List.map teamCard
            teams


view : (Msg -> msg) -> Model -> Element msg
view on model =
    column
        [ width fill
        , height fill
        , Layout.commonPadding
        , Layout.commonColumnSpacing
        ]
        [ C.link Route.Dashboard [] "< Back to dashboard"
        , C.heading "My Teams"
        , case model of
            LoadingTeams ->
                text "Loading team info..."

            NotAMemberOfAnyTeam ->
                text "You are not a member of any team."

            ViewingTeamList teams ->
                teamView teams

            Error err ->
                el
                    [ centerX
                    , centerY
                    ]
                <|
                    text err
        ]


init : (Msg -> msg) -> User -> ( Model, Cmd msg )
init on user =
    ( LoadingTeams
    , Team.getTeamsForUser (User.getId user) <|
        on
            << ReceivedTeamsResult
    )
