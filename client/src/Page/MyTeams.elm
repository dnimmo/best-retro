module Page.MyTeams exposing (Model, Msg, init, update, view)

import Components as C
import Components.Card as Card
import Components.Colours as Colours
import Components.Font as Font
import Components.Icons as Icons
import Components.Layout as Layout
import Element exposing (..)
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
    = LoadingTeams
    | NotAMemberOfAnyTeam
    | ViewingTeamList (List Team)
    | Error String



-- UPDATE


type Msg
    = ReceivedTeamsResult (Result Http.Error (List Team))


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg (Model user state) =
    case msg of
        ReceivedTeamsResult (Ok teams) ->
            ( Model user <|
                if List.isEmpty teams then
                    NotAMemberOfAnyTeam

                else
                    ViewingTeamList teams
            , Cmd.none
            )

        ReceivedTeamsResult (Err err) ->
            ( Model user <|
                Error <|
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


teamCard : User -> Team -> Element msg
teamCard user team =
    C.card <|
        row
            [ width fill ]
            [ column [ width fill ]
                [ Font.heading <| Team.getName team
                , C.link (Team.toRoute team) [] "View team"
                ]
            , el
                [ alignRight
                , EFont.color Colours.mediumBlue
                ]
              <|
                case User.getFocusedTeamId user of
                    Just id ->
                        if UniqueID.compare id <| Team.getId team then
                            el
                                [ alignRight
                                , EFont.color Colours.mediumBlue
                                ]
                            <|
                                Icons.radioChecked

                        else
                            Icons.radioUnchecked

                    Nothing ->
                        none
            ]


teamView : User -> List Team -> Element msg
teamView user teams =
    column
        [ width fill
        , spacing 24
        ]
    <|
        List.map (teamCard user)
            teams
            ++ [ el [ alignRight ] <| Card.link "Create New Team" Route.CreateTeam ]


view : (Msg -> msg) -> Model -> Element msg
view on (Model user state) =
    column
        [ width fill
        , height fill
        , Layout.commonPadding
        , Layout.commonColumnSpacing
        ]
        [ Font.heading "My Teams"
        , case state of
            LoadingTeams ->
                text "Loading team info..."

            NotAMemberOfAnyTeam ->
                column []
                    [ el [] <| text "You are not a member of any team."
                    , Card.link "Create New Team" Route.CreateTeam
                    ]

            ViewingTeamList teams ->
                teamView user teams

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
    ( Model user LoadingTeams
    , Team.getTeamsForUser (User.getId user) <|
        on
            << ReceivedTeamsResult
    )
