module Page.CreateTeam exposing (Model, Msg, init, update, view)

import Components as C
import Components.Font as Font
import Components.Input as Input
import Components.Layout as Layout
import Element exposing (..)
import Logger



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
    | UpdateEmailField String
    | AddNewEmailField
    | SubmitAllEmails
    | SubmitNewTeam


msgToString : Msg -> String
msgToString msg =
    case msg of
        UpdateTeamName str ->
            "UpdateTeamName " ++ str

        UpdateEmailField str ->
            "UpdateEmailField " ++ str

        AddNewEmailField ->
            "AddNewEmailField"

        SubmitAllEmails ->
            "SubmitAllEmails"

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

        ( SubmitNewTeam, ViewingCreateTeamFields { teamName } ) ->
            ( if String.isEmpty teamName then
                model

              else
                TeamCreated
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
    column
        [ width fill
        , Layout.commonPadding
        , Layout.commonColumnSpacing
        , spacing 24
        ]
        [ Font.heading "Create new team"
        , case model of
            ViewingCreateTeamFields { teamName } ->
                column [ spacing 24 ]
                    [ Input.plainText
                        { labelString = "Team name"
                        , text = teamName
                        , onChange = on << UpdateTeamName
                        , placeholder = Nothing
                        }
                    , Input.primaryActionButton
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
        ]


init : Model
init =
    ViewingCreateTeamFields { teamName = "" }
