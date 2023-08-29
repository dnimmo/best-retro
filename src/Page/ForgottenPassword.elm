module Page.ForgottenPassword exposing (Model, Msg, init, subscriptions, update, view)

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


type alias On msg =
    Msg -> msg


type Msg
    = AttemptToSendResetEmail String
    | UpdateEmailAddress String
    | PasswordResetAttempted String
    | ErrorResettingPassword String


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg model =
    case msg of
        UpdateEmailAddress str ->
            ( EnteringDetails str, Cmd.none )

        AttemptToSendResetEmail str ->
            ( SendingEmail str, Debug.todo "send email request" Cmd.none )

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


enteringEmailView : On msg -> String -> Element msg
enteringEmailView on str =
    column
        [ spacing 20
        , height fill
        ]
        [ paragraph
            [ width fill
            , paddingEach { edges | bottom = 40 }
            ]
            [ text "Forgotten your password? No problem; we can send you a link to reset it." ]
        , form (on <| AttemptToSendResetEmail str) <|
            column
                [ width fill
                , spacing 20
                ]
                [ textInput
                    { labelText = "Email address"
                    , value = str
                    , onChange = on << UpdateEmailAddress
                    , fullBorder = True
                    }
                , primaryButton "Submit" <| on <| AttemptToSendResetEmail str
                ]
        ]


sendingEmailView : String -> Element msg
sendingEmailView str =
    paragraph [] [ text <| "Sending a password reset email to " ++ str ]


emailSentView : String -> Element msg
emailSentView str =
    column
        [ spacing 20 ]
        [ paragraph []
            [ text <|
                "Done! If there is an account associated with "
                    ++ str
                    ++ ", then we will send an email to it with details on how to reset your password."
            ]
        , Components.linkAsText Route.SignIn "Log in"
        ]


view : On msg -> Layout -> Model -> Element msg
view on layout model =
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
                    enteringEmailView on str

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
