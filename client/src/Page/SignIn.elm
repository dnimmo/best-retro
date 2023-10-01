module Page.SignIn exposing (Model, Msg, init, subscriptions, update, view)

import Browser.Navigation as Nav
import Components exposing (currentPasswordInput, errorMessage, form, landingComponent, linkAsSecondaryButton, primaryButton, textInput)
import Components.Layout exposing (Layout)
import Element exposing (..)
import Http
import Json.Decode as Decode
import Route
import User exposing (User)



-- STATE


type Model
    = ViewingLogInForm User.LogInParams (Maybe ErrorMessage)
    | ProcessingLogInAttempt User.LogInParams
    | UpdatingStoredUser
    | FatalError ErrorMessage


type alias ErrorMessage =
    String



-- UPDATE


type alias On msg =
    Msg -> msg


type Msg
    = UpdateEmailAddress String
    | UpdatePassword String
    | AttemptToLogIn
    | ReceivedLogInResult (Result Http.Error User)
    | StoredUserUpdated (Result Decode.Error User)
    | ErrorFromDatabase String


handleEmailUpdate : Model -> String -> Model
handleEmailUpdate model str =
    case model of
        ViewingLogInForm logInParams _ ->
            ViewingLogInForm { logInParams | emailAddress = str } Nothing

        _ ->
            FatalError "Attempted to handle email update outside of ViewingLogInForm"


handlePasswordUpdate : Model -> String -> Model
handlePasswordUpdate model str =
    case model of
        ViewingLogInForm logInParams _ ->
            ViewingLogInForm { logInParams | password = str } Nothing

        _ ->
            FatalError "Attempted to handle password update outside of ViewingLogInForm"


handleLogInAttempt : On msg -> Model -> ( Model, Cmd msg )
handleLogInAttempt on model =
    case model of
        ViewingLogInForm logInParams _ ->
            ( ProcessingLogInAttempt logInParams
            , User.attemptToLogIn logInParams <| on << ReceivedLogInResult
            )

        _ ->
            ( FatalError "Attempted to log in outside of ViewingLogInForm"
            , Cmd.none
            )


handleLogInResult : Model -> Result Http.Error User -> ( Model, Cmd msg )
handleLogInResult model result =
    case model of
        ProcessingLogInAttempt logInParams ->
            case result of
                Ok user ->
                    ( model
                    , User.storeUser <| User.encode user
                    )

                Err _ ->
                    ( ViewingLogInForm logInParams <| Just "Error locating user"
                    , Cmd.none
                    )

        _ ->
            ( FatalError "Received log in result outside of ProcessingLogInAttempt"
            , Cmd.none
            )


handleDatabaseError : Model -> String -> Model
handleDatabaseError model str =
    case model of
        ProcessingLogInAttempt logInParams ->
            ViewingLogInForm logInParams <| Just str

        _ ->
            FatalError "Received error from database outside of ProcessingLogInAttempt"


handleStoredUserUpdate : Model -> Result Decode.Error User -> Nav.Key -> ( Model, Cmd msg )
handleStoredUserUpdate model result navKey =
    case ( model, result ) of
        ( ProcessingLogInAttempt _, Ok _ ) ->
            ( model
            , Route.pushUrl navKey Route.Dashboard
            )

        ( ProcessingLogInAttempt _, Err err ) ->
            ( FatalError <| Decode.errorToString err
            , Cmd.none
            )

        ( _, _ ) ->
            ( FatalError "Received stored user update outside of ProcessingLogInAttempt"
            , Cmd.none
            )


update : On msg -> Msg -> Model -> Nav.Key -> ( Model, Cmd msg )
update on msg model navKey =
    case msg of
        UpdateEmailAddress str ->
            ( handleEmailUpdate model str
            , Cmd.none
            )

        UpdatePassword str ->
            ( handlePasswordUpdate model str
            , Cmd.none
            )

        AttemptToLogIn ->
            handleLogInAttempt on model

        ReceivedLogInResult result ->
            handleLogInResult model result

        ErrorFromDatabase str ->
            ( handleDatabaseError model str
            , Cmd.none
            )

        StoredUserUpdated result ->
            handleStoredUserUpdate model result navKey



-- VIEW


view : On msg -> Layout -> Model -> Element msg
view on layout model =
    landingComponent layout 0 <|
        column
            [ width fill
            , centerX
            , centerY
            , spacing 20
            ]
            [ case model of
                ViewingLogInForm { emailAddress, password } maybeError ->
                    form (on AttemptToLogIn) <|
                        column
                            [ spacing 20
                            , width fill
                            , height fill
                            , Element.below <|
                                case maybeError of
                                    Just str ->
                                        Components.errorMessage str

                                    Nothing ->
                                        Element.none
                            ]
                            [ textInput
                                { labelText = "Email address"
                                , value = emailAddress
                                , onChange = on << UpdateEmailAddress
                                , fullBorder = True
                                }
                            , currentPasswordInput
                                { labelText = "Password"
                                , value = password
                                , onChange = on << UpdatePassword
                                , fullBorder = True
                                }
                            , Components.linkAsText Route.ForgottenPassword "Forgotten your password?"
                            , column
                                [ width fill
                                , height fill
                                , spacing 20
                                , alignBottom
                                ]
                                [ primaryButton "Log in" <| on AttemptToLogIn
                                , linkAsSecondaryButton Route.Home "Cancel"
                                ]
                            ]

                ProcessingLogInAttempt _ ->
                    el [ centerX ] <| text "Loading..."

                FatalError errorMessage ->
                    el [ centerX ] <| text errorMessage

                UpdatingStoredUser ->
                    el [ centerX ] <| text "Success! We're redirecting you now"
            ]



-- INIT


init : Model
init =
    ViewingLogInForm
        { emailAddress = ""
        , password = ""
        }
        Nothing


subscriptions : Sub Msg
subscriptions =
    Sub.none
