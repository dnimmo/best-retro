module Page.Dashboard exposing (Model, Msg, init, update, view)

import Components.Card as Card
import Components.Layout as Layout
import Components.Navigation as Navigation
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
    column
        [ width fill
        , height fill
        , Layout.commonPadding
        , Layout.commonColumnSpacing
        ]
        [ Navigation.breadCrumb Route.Dashboard
        , Card.link "My Teams" Route.MyTeams
        , Card.link "Create New Team" Route.CreateTeam
        , Card.link "Board (For Dev)" <| Route.Board "dev-board"
        ]


init : Model
init =
    Model
