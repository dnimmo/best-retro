module Page.SignIn exposing (Model, Msg, init, update, view)

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
        [ Components.heading1 "Sign in"
        , link []
            { url = Route.toUrlString Route.Home
            , label = text "Go to home"
            }
        ]


init : Model
init =
    Model
