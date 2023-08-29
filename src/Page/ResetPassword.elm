module Page.ResetPassword exposing (Model, Msg, init, subscriptions, update, view)

import Components exposing (edges, form, landingComponent, primaryButton, textInput)
import Components.Layout exposing (Layout)
import Element exposing (..)
import Route



-- MODEL


type Model
    = EnteringDetails String
    | SendingEmail String
    | EmailSent String



-- UPDATE


type Msg
    = AttemptToSendResetEmail String
    | UpdateEmailAddress String
    | PasswordResetAttempted String
    | ErrorResettingPassword String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateEmailAddress str ->
            ( EnteringDetails str, Cmd.none )

        AttemptToSendResetEmail str ->
            ( SendingEmail str, Debug.log "TODO" Cmd.none )

        PasswordResetAttempted str ->
            ( EmailSent str, Cmd.none )

        ErrorResettingPassword errorStr ->
            ( case model of
                SendingEmail emailAddress ->
                    EnteringDetails emailAddress

                _ ->
                    EnteringDetails ""
            , Cmd.none
            )



-- VIEW


enteringEmailView : String -> Element Msg
enteringEmailView str =
    column
        [ spacing 20
        , height fill
        ]
        [ paragraph
            [ width fill
            , paddingEach { edges | bottom = 40 }
            ]
            [ text "Forgotten your password? No problem; we can send you a link to reset it." ]
        , form (AttemptToSendResetEmail str) <|
            column
                [ width fill
                , spacing 20
                ]
                [ textInput
                    { labelText = "Email address"
                    , value = str
                    , onChange = UpdateEmailAddress
                    , fullBorder = True
                    }
                , primaryButton "Submit" <| AttemptToSendResetEmail str
                ]
        ]


sendingEmailView : String -> Element Msg
sendingEmailView str =
    paragraph [] [ text <| "Sending a password reset email to " ++ str ]


emailSentView : String -> Element Msg
emailSentView str =
    column
        [ spacing 20 ]
        [ paragraph []
            [ text <|
                "Done! If there is an user associated with "
                    ++ str
                    ++ ", then we will send an email to it with details on how to reset your password."
            ]
        , Components.linkAsText Route.SignIn "Log in"
        ]


view : Layout -> Model -> Element Msg
view layout model =
    landingComponent layout 0 <|
        column
            [ spacing 20
            , width fill
            , height fill
            ]
            [ el
                [ alignBottom
                ]
              <|
                Components.linkAsText Route.SignIn "< Go back"
            , case model of
                EnteringDetails str ->
                    enteringEmailView str

                SendingEmail str ->
                    sendingEmailView str

                EmailSent str ->
                    emailSentView str
            ]



-- INIT


init : Model
init =
    EnteringDetails ""


subscriptions : Sub Msg
subscriptions =
    Sub.none
