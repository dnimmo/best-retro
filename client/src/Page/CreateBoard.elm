module Page.CreateBoard exposing (Model, Msg, init, update, view)

import Board exposing (Board)
import Components.Font as Font
import Components.Icons as Icons
import Components.Input as Input
import Components.Layout as Layout
import Components.Navigation as Navigation
import Element exposing (..)
import Http
import Route
import UniqueID



-- MODEL


type Model
    = ViewingCreateBoardFields
        { name : String
        , error : Maybe String
        }
    | CreatingBoard
    | ViewingBoardCreated Board
    | Error String



-- UPDATE


type Msg
    = UpdateBoardName String
    | SubmitNewBoard
    | BoardCreated (Result Http.Error Board)


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg model =
    case model of
        ViewingCreateBoardFields fields ->
            case msg of
                UpdateBoardName name ->
                    ( ViewingCreateBoardFields
                        { fields
                            | name = name
                        }
                    , Cmd.none
                    )

                SubmitNewBoard ->
                    ( CreatingBoard
                    , Board.createNew () <|
                        on
                            << BoardCreated
                    )

                _ ->
                    ( model, Cmd.none )

        CreatingBoard ->
            case msg of
                BoardCreated (Ok board) ->
                    ( ViewingBoardCreated board
                    , Cmd.none
                    )

                BoardCreated (Err error) ->
                    ( Error <|
                        case error of
                            Http.BadStatus status ->
                                "Error creating board: Status was " ++ String.fromInt status

                            Http.Timeout ->
                                "Request timed out"

                            Http.NetworkError ->
                                "Network error"

                            Http.BadBody body ->
                                "Error decoding response: " ++ body

                            Http.BadUrl url ->
                                "Bad URL: " ++ url
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        ViewingBoardCreated board ->
            ( model, Cmd.none )

        Error errorMessage ->
            ( model, Cmd.none )



-- VIEW


view : (Msg -> msg) -> Model -> Element msg
view on model =
    column
        [ width fill
        , Layout.commonPadding
        , Layout.commonColumnSpacing
        , spacing 24
        ]
        [ Font.heading "Create a new board"
        , case model of
            ViewingCreateBoardFields { name } ->
                column [ spacing 24 ]
                    [ Input.inputFieldWithInsetButton
                        { labelString = "Board name"
                        , value = name
                        , onChange = on << UpdateBoardName
                        , onSubmit = on SubmitNewBoard
                        }
                    ]

            CreatingBoard ->
                text "Loading..."

            ViewingBoardCreated board ->
                column [ spacing 24 ]
                    [ el [] <| text "Board created!"
                    , Navigation.iconLinkWithText (Board.getName board)
                        Icons.board
                        (Route.Board <|
                            UniqueID.toString <|
                                Board.getId board
                        )
                    ]

            Error errorMessage ->
                text errorMessage
        ]


init : Model
init =
    ViewingCreateBoardFields
        { name = ""
        , error = Nothing
        }
