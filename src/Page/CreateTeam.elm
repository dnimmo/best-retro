module Page.CreateTeam exposing (Model, Msg, init, update, view)

import Components as C
import Components.Input as Input
import Element exposing (..)
import Logger
import Route



-- MODEL


type Model
    = ViewingCreateTeamFields { teamName : String }
    | Loading
    | TeamCreated
    | Error String


modelToString : Model -> String
modelToString model =
    case model of
        ViewingCreateTeamFields { teamName } ->
            "ViewingCreateTeamFields " ++ teamName

        Loading ->
            "Loading"

        TeamCreated ->
            "TeamCreated"

        Error errorMessage ->
            "Error " ++ errorMessage



-- UPDATE


type Msg
    = UpdateTeamName String
    | SubmitNewTeam


msgToString : Msg -> String
msgToString msg =
    case msg of
        UpdateTeamName str ->
            "UpdateTeamName " ++ str

        SubmitNewTeam ->
            "SubmitNewTeam"


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg model =
    case ( msg, model ) of
        ( UpdateTeamName str, ViewingCreateTeamFields fields ) ->
            ( ViewingCreateTeamFields
                { fields
                    | teamName = str
                }
            , Cmd.none
            )

        ( SubmitNewTeam, ViewingCreateTeamFields _ ) ->
            ( TeamCreated
            , Cmd.none
            )

        _ ->
            ( Error "Something has gone wrong"
            , Logger.logError <|
                "Impossible state combination. State: "
                    ++ modelToString model
                    ++ ". Msg: "
                    ++ msgToString msg
            )



-- VIEW


view : (Msg -> msg) -> Model -> Element msg
view on model =
    column []
        [ C.heading "Create new team"
        , case model of
            ViewingCreateTeamFields { teamName } ->
                column []
                    [ Input.plainText
                        { labelString = "Team name"
                        , text = teamName
                        , onChange = on << UpdateTeamName
                        , placeholder = Nothing
                        }
                    , Input.actionButton
                        { labelString = "Create team"
                        , onPress = on SubmitNewTeam
                        }
                    ]

            Loading ->
                text "Loading..."

            TeamCreated ->
                text "Team created!"

            Error errorMessage ->
                text errorMessage
        , C.link Route.Dashboard [] "Back to dashboard"
        ]


init : Model
init =
    ViewingCreateTeamFields { teamName = "" }
