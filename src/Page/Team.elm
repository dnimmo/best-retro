module Page.Team exposing (Model, Msg, init, update, view)

import Components
import Element exposing (..)
import Route



-- MODEL


type Model
    = ViewingTeam { teamId : String }



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


view : (Msg -> msg) -> Model -> Element msg
view on model =
    column []
        [ Components.heading1 "My Team"
        , Components.internalLink Route.Dashboard <| text "Back to dashboard"
        ]


init : String -> Model
init teamId =
    ViewingTeam { teamId = teamId }
