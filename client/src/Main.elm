module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Browser.Events
import Browser.Navigation as Nav
import Components
import Components.Layout as Layout exposing (Layout)
import Http exposing (Error(..))
import Json.Decode as Decode
import Logger
import Page.Board as Board
import Page.CreateAccount as CreateAccount
import Page.CreateTeam as CreateTeam
import Page.Dashboard as Dashboard
import Page.Error
import Page.ForgottenPassword as ForgottenPassword
import Page.Home as Home
import Page.Loading as Loading
import Page.MyTeams as MyTeams
import Page.SignIn as SignIn
import Page.Team as TeamPage
import Route
import Team
import Time
import Url exposing (Url)
import User exposing (User)



-- MODEl


type alias Model =
    { navKey : Nav.Key
    , state : State
    , layout : Layout
    , user : Maybe User
    , now : Time.Posix
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
    | ViewingTeam User TeamPage.Model
    | ViewingBoard User Board.Model
    | ViewingError String



-- UPDATE


type Msg
    = Tick Time.Posix
    | UrlRequested Browser.UrlRequest
    | UrlChanged Url
    | ViewportResized Int
    | CreateAccountMsg CreateAccount.Msg
    | ForgottenPasswordMsg ForgottenPassword.Msg
    | SignInMsg SignIn.Msg
    | DashboardMsg Dashboard.Msg
    | MyTeamsMsg MyTeams.Msg
    | CreateTeamMsg CreateTeam.Msg
    | TeamMsg TeamPage.Msg
    | BoardMsg Board.Msg
    | UserLoaded Decode.Value


urlChange : Url -> Model -> ( Model, Cmd Msg )
urlChange url model =
    ( { model
        | state =
            case model.user of
                Nothing ->
                    case Route.fromUrl url of
                        Just Route.Home ->
                            ViewingHome

                        Just Route.CreateAccount ->
                            ViewingCreateAccount CreateAccount.init

                        Just Route.SignIn ->
                            ViewingSignIn SignIn.init

                        Just Route.ForgottenPassword ->
                            ViewingForgottenPassword ForgottenPassword.init

                        _ ->
                            -- TODO: Maybe show some error in this situation
                            ViewingHome

                Just user ->
                    case Route.fromUrl url of
                        Just Route.Dashboard ->
                            ViewingDashboard user Dashboard.init

                        Just Route.MyTeams ->
                            ViewingMyTeams user <|
                                MyTeams.init user

                        Just Route.CreateTeam ->
                            ViewingCreateTeam user CreateTeam.init

                        Just (Route.Team teamId) ->
                            ViewingTeam user <|
                                TeamPage.init teamId

                        Just (Route.Board boardId) ->
                            ViewingBoard user <|
                                Board.init user Team.testTeam boardId model.now

                        _ ->
                            -- TODO: Maybe show some error in this situation
                            ViewingDashboard user Dashboard.init
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.state ) of
        ( Tick now, _ ) ->
            ( { model
                | now = now
              }
            , Cmd.none
            )

        ( ViewportResized viewportWidth, _ ) ->
            ( { model
                | layout = Layout.getLayout viewportWidth
              }
            , Cmd.none
            )

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
            case Decode.decodeValue User.decode decodedUser of
                Ok user ->
                    ( { model
                        | state =
                            ViewingDashboard user
                                Dashboard.init
                        , user = Just user
                      }
                    , Cmd.none
                    )

                Err err ->
                    let
                        errorToLog =
                            "Error decoding user: "
                                ++ Decode.errorToString err
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

        ( BoardMsg boardMsg, ViewingBoard user boardModel ) ->
            let
                ( updatedModel, cmd ) =
                    Board.update model.now BoardMsg boardMsg boardModel
            in
            ( { model
                | state = ViewingBoard user updatedModel
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
                    Layout.withHeader Route.Home <| Dashboard.view DashboardMsg dashboardModel

                ViewingMyTeams _ myTeamsModel ->
                    Layout.withHeader Route.MyTeams <| MyTeams.view MyTeamsMsg myTeamsModel

                ViewingCreateTeam _ createTeamModel ->
                    Layout.withHeader Route.CreateTeam <| CreateTeam.view CreateTeamMsg createTeamModel

                ViewingTeam _ teamModel ->
                    Layout.withHeader (Route.Team "") <| TeamPage.view TeamMsg teamModel

                ViewingBoard _ boardModel ->
                    Layout.withHeader (Route.Board "") <| Board.view model.layout BoardMsg boardModel

                ViewingError errorMsg ->
                    Layout.withHeader Route.Error <| Page.Error.view errorMsg
        ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions { state } =
    Sub.batch
        [ User.userLoaded UserLoaded
        , Browser.Events.onResize (\width _ -> ViewportResized width)
        , -- TODO: Decide whether this one is even important any more
          case state of
            ViewingBoard _ _ ->
                Time.every 1000 Tick

            _ ->
                Sub.none
        , case state of
            ViewingBoard _ boardModel ->
                Board.subscriptions BoardMsg boardModel

            _ ->
                Sub.none
        ]



-- INIT


type alias Flags =
    { user : Decode.Value
    , viewportWidth : Int
    , now : Int
    }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init { user, viewportWidth, now } url navKey =
    let
        userResult =
            Decode.decodeValue User.decode user

        ( maybeUser, logCmd ) =
            case userResult of
                Ok u ->
                    ( Just u, Cmd.none )

                Err err ->
                    ( Nothing
                    , Logger.logError <|
                        "Error decoding user: "
                            ++ Decode.errorToString err
                    )

        ( model, cmd ) =
            urlChange url
                { navKey = navKey
                , state = ViewingLoading
                , layout = Layout.getLayout viewportWidth
                , user = maybeUser
                , now = Time.millisToPosix now
                }
    in
    ( model, Cmd.batch [ cmd, logCmd ] )


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
