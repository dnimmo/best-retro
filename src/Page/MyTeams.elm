module Page.MyTeams exposing (Model, Msg, init, update, view)

import Components
import Element exposing (..)
import Route
import Team exposing (Team)



-- MODEL


type Model
    = NotAMemberOfAnyTeam
    | ViewingTeamList ( Team, List Team )



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
    Components.internalLinkCard (Team.toRoute team)
        [ Components.heading2 <| Team.getName team
        , Components.paragraph [ Team.getDescription team ]
        ]


teamView : List Team -> Element msg
teamView teams =
    column [ width fill ] <|
        Components.paragraph [ "You are a member of the following teams:" ]
            :: List.map teamCard
                teams


view : (Msg -> msg) -> Model -> Element msg
view on model =
    column []
        [ Components.heading1 "My Teams"
        , case model of
            NotAMemberOfAnyTeam ->
                Components.paragraph [ "You are not a member of any team." ]

            ViewingTeamList ( team, otherTeams ) ->
                teamView <| team :: otherTeams
        , Components.internalLink Route.Dashboard <| text "Back to dashboard"
        ]


init : Maybe (List Team) -> Model
init maybeTeams =
    case maybeTeams of
        Nothing ->
            NotAMemberOfAnyTeam

        Just teams ->
            case teams of
                [] ->
                    NotAMemberOfAnyTeam

                team :: otherTeams ->
                    ViewingTeamList ( team, otherTeams )
