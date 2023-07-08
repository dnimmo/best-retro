module Page.Dashboard exposing (Model, Msg, init, update, view)

import Components
import Element exposing (..)
import Route



-- MODEL


type Model
    = Model



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
        [ Components.heading1 "Dashboard"
        , Components.internalLink Route.MyTeams "My Teams"
        , Components.internalLink Route.CreateTeam "Create New Team"
        ]


init : Model
init =
    Model
