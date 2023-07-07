module Main exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Components
import Page.CreateAccount as CreateAccount
import Page.Dashboard as Dashboard
import Page.Home as Home
import Page.Loading as Loading
import Page.SignIn as SignIn
import Route
import Url exposing (Url)



-- MODEl


type alias Model =
    { navKey : Nav.Key
    , state : State
    }


type State
    = ViewingLoading
    | ViewingHome
    | ViewingCreateAccount CreateAccount.Model
    | ViewingSignIn SignIn.Model
    | ViewingDashboard Dashboard.Model



-- UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url
    | CreateAccountMsg CreateAccount.Msg
    | SignInMsg SignIn.Msg
    | DashboardMsg Dashboard.Msg


urlChange : Url -> Model -> ( Model, Cmd Msg )
urlChange url model =
    ( { model
        | state =
            case Route.fromUrl url of
                Just Route.Home ->
                    ViewingHome

                Just Route.CreateAccount ->
                    ViewingCreateAccount CreateAccount.init

                Just Route.SignIn ->
                    ViewingSignIn SignIn.init

                Nothing ->
                    Debug.todo "Error state here"
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( UrlRequested urlRequest, _ ) ->
            ( model
            , case urlRequest of
                Internal url ->
                    Nav.pushUrl model.navKey <|
                        Url.toString url

                External externalUrlStr ->
                    Nav.replaceUrl model.navKey externalUrlStr
            )

        ( UrlChanged url, _ ) ->
            urlChange url model

        ( CreateAccountMsg createAccountMsg, ViewingCreateAccount createAccountModel ) ->
            let
                ( updatedModel, cmd ) =
                    CreateAccount.update CreateAccountMsg createAccountMsg createAccountModel
            in
            ( { model
                | state = ViewingCreateAccount updatedModel
              }
            , cmd
            )

        ( SignInMsg signInMsg, ViewingSignIn signInModel ) ->
            let
                ( updatedModel, cmd ) =
                    SignIn.update SignInMsg signInMsg signInModel
            in
            ( { model
                | state = ViewingSignIn updatedModel
              }
            , cmd
            )

        _ ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "BestRetro"
    , body =
        [ Components.globalLayout <|
            case model.state of
                ViewingLoading ->
                    Loading.view

                ViewingHome ->
                    Home.view

                ViewingCreateAccount createAccountModel ->
                    CreateAccount.view CreateAccountMsg createAccountModel

                ViewingSignIn signInModel ->
                    SignIn.view SignInMsg signInModel

                ViewingDashboard dashboardModel ->
                    Dashboard.view DashboardMsg dashboardModel
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- INIT


type alias Flags =
    {}


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    urlChange
        url
        { navKey = navKey
        , state = ViewingLoading
        }


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }
