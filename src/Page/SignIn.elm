module Page.SignIn exposing (Model, Msg, init, update, view)

import Components exposing (actionButton, currentPasswordDisplayed, currentPasswordHidden, internalLink, plainText)
import Element exposing (..)
import Route



-- MODEL


type Model
    = SigningIn Inputs { displayPassword : Bool }


type alias Inputs =
    { emailInput : String
    , passwordInput : String
    }



-- UPDATE


type Msg
    = UpdateEmail String
    | UpdatePassword String
    | TogglePassword
    | AttemptSignIn


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg model =
    case ( msg, model ) of
        ( UpdateEmail str, SigningIn inputs displayPassword ) ->
            ( SigningIn { inputs | emailInput = str } displayPassword
            , Cmd.none
            )

        ( UpdatePassword str, SigningIn inputs displayPassword ) ->
            ( SigningIn { inputs | passwordInput = str } displayPassword
            , Cmd.none
            )

        ( TogglePassword, SigningIn inputs { displayPassword } ) ->
            ( SigningIn inputs { displayPassword = not displayPassword }
            , Cmd.none
            )

        ( AttemptSignIn, SigningIn _ _ ) ->
            ( model, Cmd.none )



-- VIEW


signingInView : (Msg -> msg) -> Inputs -> { displayPassword : Bool } -> Element msg
signingInView on inputs { displayPassword } =
    column []
        [ plainText
            { labelString = "Email address"
            , placeholder = Nothing
            , text = inputs.emailInput
            , onChange = on << UpdateEmail
            }
        , row []
            [ (if displayPassword then
                currentPasswordDisplayed

               else
                currentPasswordHidden
              )
                { labelString = "Password"
                , placeholder = Nothing
                , text = inputs.passwordInput
                , onChange = on << UpdatePassword
                }
            , actionButton
                { labelString =
                    if displayPassword then
                        "Hide"

                    else
                        "Show"
                , onPress = on <| TogglePassword
                }
            ]

        -- , actionButton
        --     { labelString = "Sign in"
        --     , onPress = on AttemptSignIn
        --     }
        , internalLink
            Route.Dashboard
            "Sign in (Nimmo you need to replace this with a button)"
        ]


view : (Msg -> msg) -> Model -> Element msg
view on model =
    column []
        [ Components.heading1 "Sign in"
        , internalLink Route.Home "Go to home"
        , internalLink Route.CreateAccount "Go to create account"
        , case model of
            SigningIn inputs displayPassword ->
                signingInView on inputs displayPassword
        ]


init : Model
init =
    SigningIn
        { emailInput = ""
        , passwordInput = ""
        }
        { displayPassword = False }
