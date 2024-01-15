module Page.MyTeams exposing (Model, Msg, init, update, view)

import Components as C
import Components.Layout as Layout
import Element exposing (..)
import Route
import Team exposing (Team)
import User exposing (User)



-- MODEL


type Model
    = NotAMemberOfAnyTeam
    | ViewingTeamList (List Team)



-- UPDATE


type Msg
    = Msg


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg model =
    case msg of
        Msg ->
            ( model
            , Cmd.none
            )



-- VIEW


teamCard : Team -> Element msg
teamCard team =
    C.card
    --(Team.toRoute team)
    <|
        column
            [ width fill ]
            [ C.heading <| Team.getName team
            , paragraph []
                [ el [] <|
                    text <|
                        Team.getDescription team
                ]
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
        [ C.heading "My Teams"
        , case model of
            NotAMemberOfAnyTeam ->
                text "You are not a member of any team."

            ViewingTeamList teams ->
                teamView teams
        , C.link Route.Dashboard [] "Back to dashboard"
        ]


init : User -> Model
init user =
    NotAMemberOfAnyTeam
