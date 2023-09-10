module Page.CreateAccount exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation as Nav
import Components exposing (landingComponent, linkAsSecondaryButton, passwordInput, primaryButton, textInput)
import Components.Input as Input
import Components.Layout exposing (Layout)
import Element exposing (..)
import Element.Input exposing (username)
import Json.Decode as Decode
import Route
import User exposing (CreateUserParams, User)



-- MODEL


type Model
    = EnteringDetails CreateUserParams (Maybe ErrorMessage)
    | CreatingUser CreateUserParams
    | UserCreated String
    | FatalError ErrorMessage


type alias ErrorMessage =
    String



-- UPDATE


type Msg
    = UpdateUsername String
    | UpdatePassword String
    | UpdateEmailAddress String
    | AttemptToCreateUser
    | ErrorCreatingUser ErrorMessage
    | UserAttemptResultReceived (Result Decode.Error User)
    | StoredUserUpdated (Result Decode.Error User)


handleUsernameUpdate : Model -> String -> Model
handleUsernameUpdate state str =
    case state of
        EnteringDetails params _ ->
            EnteringDetails { params | username = str } Nothing

        _ ->
            FatalError "Attempted to update username outside of the EnteringDetails state"


handlePasswordUpdate : Model -> String -> Model
handlePasswordUpdate state str =
    case state of
        EnteringDetails params _ ->
            EnteringDetails { params | password = str } Nothing

        _ ->
            FatalError "Attempted to update password outside of the EnteringDetails state"


handleEmailAddressUpdate : Model -> String -> Model
handleEmailAddressUpdate state str =
    case state of
        EnteringDetails params _ ->
            EnteringDetails { params | emailAddress = str } Nothing

        _ ->
            FatalError "Attempted to update email address outside of the EnteringDetails state"


handleAttemptToCreateUser : Model -> ( Model, Cmd msg )
handleAttemptToCreateUser state =
    case state of
        EnteringDetails params _ ->
            ( CreatingUser params
            , User.createUser params
            )

        _ ->
            ( FatalError "Attempted to create account outside of the EnteringDetails state"
            , Cmd.none
            )


handleUserCreationError : Model -> String -> Model
handleUserCreationError state str =
    case state of
        CreatingUser params ->
            EnteringDetails params <| Just str

        _ ->
            FatalError "Attempted to handle account creation error outside of CreatingUser"


handleUserAttemptResult : Model -> Result Decode.Error User -> ( Model, Cmd msg )
handleUserAttemptResult state result =
    case state of
        CreatingUser params ->
            case result of
                Ok account ->
                    ( state
                    , User.storeUser <| User.encode account
                    )

                Err err ->
                    ( EnteringDetails params <| Just <| Decode.errorToString err
                    , Cmd.none
                    )

        _ ->
            ( FatalError "Attempted to handle result of account creation outside of the CreatingUser state"
            , Cmd.none
            )


handleStoredUserUpdate : Model -> Result Decode.Error User -> Nav.Key -> ( Model, Cmd msg )
handleStoredUserUpdate state result navKey =
    case ( state, result ) of
        ( CreatingUser _, Ok _ ) ->
            ( state
            , Route.pushUrl navKey Route.Dashboard
            )

        ( CreatingUser _, Err err ) ->
            ( FatalError <| Decode.errorToString err
            , Cmd.none
            )

        ( _, _ ) ->
            ( FatalError "Attempted stored account update outside of CreatingUser state"
            , Cmd.none
            )


update : (Msg -> msg) -> Msg -> Model -> Nav.Key -> ( Model, Cmd msg )
update on msg state navKey =
    case msg of
        UpdateUsername str ->
            ( handleUsernameUpdate state str
            , Cmd.none
            )

        UpdatePassword str ->
            ( handlePasswordUpdate state str
            , Cmd.none
            )

        UpdateEmailAddress str ->
            ( handleEmailAddressUpdate state str
            , Cmd.none
            )

        AttemptToCreateUser ->
            handleAttemptToCreateUser state

        ErrorCreatingUser str ->
            ( handleUserCreationError state str
            , Cmd.none
            )

        UserAttemptResultReceived result ->
            handleUserAttemptResult state result

        StoredUserUpdated result ->
            handleStoredUserUpdate state result navKey



-- VIEW


view : (Msg -> msg) -> Layout -> Model -> Element msg
view on layout state =
    landingComponent layout 0 <|
        el
            [ width fill
            , centerX
            , height fill
            , centerY
            ]
        <|
            case state of
                EnteringDetails { emailAddress, username, password } maybeErrorMessage ->
                    Input.form (on AttemptToCreateUser) <|
                        column
                            [ spacing 20
                            , width fill
                            , Element.below <|
                                case maybeErrorMessage of
                                    Just str ->
                                        el [ centerX ] <| Components.errorMessage str

                                    Nothing ->
                                        Element.none
                            ]
                            [ textInput
                                { labelText = "What shall we call you?"
                                , value = username
                                , onChange = on << UpdateUsername
                                , fullBorder = True
                                }
                            , textInput
                                { labelText = "Enter your email address"
                                , value = emailAddress
                                , onChange = on << UpdateEmailAddress
                                , fullBorder = True
                                }
                            , passwordInput
                                { labelText = "Create a password"
                                , value = password
                                , onChange = on << UpdatePassword
                                , fullBorder = True
                                }
                            , column
                                [ width fill
                                , height fill
                                , spacing 20
                                , alignBottom
                                ]
                                [ primaryButton "Create account" <| on AttemptToCreateUser
                                , linkAsSecondaryButton Route.Home "Cancel"
                                ]
                            ]

                CreatingUser _ ->
                    el [ centerX ] <| text "Loading..."

                UserCreated username ->
                    el [ centerX ] <| text <| "Welcome aboard, " ++ username ++ "!"

                FatalError str ->
                    el [ centerX ] <| text str



-- INIT


init : Model
init =
    EnteringDetails
        (CreateUserParams "" "" "")
        Nothing


subscriptions : Sub Msg
subscriptions =
    Sub.none
