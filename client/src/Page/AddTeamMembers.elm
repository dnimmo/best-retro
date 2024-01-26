module Page.AddTeamMembers exposing (Model, Msg, init, update, view)

import Components.Layout as Layout
import Components.Navigation as Navigation
import Element exposing (..)
import Route
import UniqueID exposing (UniqueID)



-- MODEL


type Model
    = Model { teamId : UniqueID }



-- UPDATE


type Msg
    = Msg


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg model =
    ( model
    , Cmd.none
    )



-- VIEW


view : (Msg -> msg) -> Model -> Element msg
view _ (Model { teamId }) =
    Layout.page
        [ Navigation.breadCrumb <| Route.AddTeamMembers <| UniqueID.toString teamId
        , text "Add Team Members"
        , text "TODO"
        ]



-- INIT


init : (Msg -> msg) -> UniqueID -> ( Model, Cmd msg )
init on id =
    ( Model { teamId = id }
    , Cmd.none
    )
