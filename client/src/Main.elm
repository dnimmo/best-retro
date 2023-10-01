module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Components
import Components.Layout as Layout exposing (Layout)
import Json.Decode
import Logger
import Page.CreateAccount as CreateAccount
import Page.CreateTeam as CreateTeam
import Page.Dashboard as Dashboard
import Page.Error
import Page.ForgottenPassword as ForgottenPassword
import Page.Home as Home
import Page.Loading as Loading
import Page.MyTeams as MyTeams
import Page.SignIn as SignIn
import Page.Team
import Route
import Url exposing (Url)
import User exposing (User, getUser)



-- MODEl


type alias Model =
    { navKey : Nav.Key
    , state : State
    , layout : Layout
    }


type State
    = ViewingLoading
    | ViewingHome
    | ViewingCreateAccount CreateAccount.Model
    | ViewingForgottenPassword ForgottenPassword.Model
    | ViewingSignIn SignIn.Model
    | ViewingDashboard User Dashboard.Model
    | ViewingMyTeams User MyTeams.Model
    | ViewingCreateTeam User CreateTeam.Model
    | ViewingTeam User Page.Team.Model
    | ViewingError String



-- UPDATE


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url
    | CreateAccountMsg CreateAccount.Msg
    | ForgottenPasswordMsg ForgottenPassword.Msg
    | SignInMsg SignIn.Msg
    | DashboardMsg Dashboard.Msg
    | MyTeamsMsg MyTeams.Msg
    | CreateTeamMsg CreateTeam.Msg
    | TeamMsg Page.Team.Msg
    | UserLoaded Json.Decode.Value


getUserFromState : State -> Maybe User
getUserFromState state =
    case state of
        ViewingDashboard user _ ->
            Just user

        ViewingMyTeams user _ ->
            Just user

        ViewingCreateTeam user _ ->
            Just user

        ViewingTeam user _ ->
            Just user

        _ ->
            Nothing


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

                Just Route.ForgottenPassword ->
                    ViewingForgottenPassword ForgottenPassword.init

                Just Route.Dashboard ->
                    ViewingDashboard getUser Dashboard.init

                Just Route.MyTeams ->
                    ViewingMyTeams getUser <|
                        MyTeams.init getUser

                Just Route.CreateTeam ->
                    ViewingCreateTeam getUser CreateTeam.init

                Just (Route.Team teamId) ->
                    ViewingTeam getUser <|
                        Page.Team.init teamId

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

        ( UserLoaded decodedUser, _ ) ->
            case Json.Decode.decodeValue User.decode decodedUser of
                Ok user ->
                    ( { model
                        | state =
                            ViewingDashboard user
                                Dashboard.init
                      }
                    , Cmd.none
                    )

                Err err ->
                    let
                        errorToLog =
                            "Error decoding user: "
                                ++ Json.Decode.errorToString err
                    in
                    ( { model
                        | state = ViewingError errorToLog
                      }
                    , Logger.logError errorToLog
                    )

        ( CreateAccountMsg createAccountMsg, ViewingCreateAccount createAccountModel ) ->
            let
                ( updatedModel, cmd ) =
                    CreateAccount.update CreateAccountMsg createAccountMsg createAccountModel model.navKey
            in
            ( { model
                | state = ViewingCreateAccount updatedModel
              }
            , cmd
            )

        ( ForgottenPasswordMsg forgottenPasswordMsg, ViewingForgottenPassword forgottenPasswordModel ) ->
            let
                ( updatedModel, cmd ) =
                    ForgottenPassword.update ForgottenPasswordMsg forgottenPasswordMsg forgottenPasswordModel
            in
            ( { model
                | state = ViewingForgottenPassword updatedModel
              }
            , cmd
            )

        ( SignInMsg signInMsg, ViewingSignIn signInModel ) ->
            let
                ( updatedModel, cmd ) =
                    SignIn.update SignInMsg signInMsg signInModel model.navKey
            in
            ( { model
                | state = ViewingSignIn updatedModel
              }
            , cmd
            )

        ( DashboardMsg dashboardMsg, ViewingDashboard user dashboardModel ) ->
            let
                ( updatedModel, cmd ) =
                    Dashboard.update DashboardMsg dashboardMsg dashboardModel
            in
            ( { model
                | state = ViewingDashboard user updatedModel
              }
            , cmd
            )

        ( MyTeamsMsg myTeamsMsg, ViewingMyTeams user myTeamsModel ) ->
            let
                ( updatedModel, cmd ) =
                    MyTeams.update MyTeamsMsg myTeamsMsg myTeamsModel
            in
            ( { model
                | state = ViewingMyTeams user updatedModel
              }
            , cmd
            )

        ( CreateTeamMsg createTeamMsg, ViewingCreateTeam user createTeamModel ) ->
            let
                ( updatedModel, cmd ) =
                    CreateTeam.update CreateTeamMsg createTeamMsg createTeamModel
            in
            ( { model
                | state = ViewingCreateTeam user updatedModel
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
                    Home.view model.layout

                ViewingCreateAccount createAccountModel ->
                    CreateAccount.view CreateAccountMsg model.layout createAccountModel

                ViewingSignIn signInModel ->
                    SignIn.view SignInMsg model.layout signInModel

                ViewingForgottenPassword forgottenPasswordModel ->
                    ForgottenPassword.view ForgottenPasswordMsg model.layout forgottenPasswordModel

                ViewingDashboard _ dashboardModel ->
                    Dashboard.view DashboardMsg dashboardModel

                ViewingMyTeams _ myTeamsModel ->
                    MyTeams.view MyTeamsMsg myTeamsModel

                ViewingCreateTeam _ createTeamModel ->
                    CreateTeam.view CreateTeamMsg createTeamModel

                ViewingTeam _ teamModel ->
                    Page.Team.view TeamMsg teamModel

                ViewingError errorMsg ->
                    Page.Error.view errorMsg
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ User.userLoaded UserLoaded
        ]



-- INIT


type alias Flags =
    {}


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url navKey =
    urlChange
        url
        { navKey = navKey
        , state = ViewingLoading
        , layout = Layout.getLayout 1001
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
