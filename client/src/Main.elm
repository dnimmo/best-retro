module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Browser.Events
import Browser.Navigation as Nav
import Components
import Components.Layout as Layout exposing (Layout)
import Http exposing (Error(..))
import Json.Decode as Decode
import Logger
import Page.AddTeamMembers as AddTeamMembers
import Page.Board as Board
import Page.CreateAccount as CreateAccount
import Page.CreateBoard as CreateBoard
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
import Time
import UniqueID exposing (UniqueID)
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
    | ViewingAddTeamMembers User AddTeamMembers.Model
    | ViewingTeam User UniqueID TeamPage.Model
    | ViewingCreateBoard User { teamId : UniqueID } CreateBoard.Model
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
    | AddTeamMembersMsg AddTeamMembers.Msg
    | TeamMsg TeamPage.Msg
    | CreateBoardMsg CreateBoard.Msg
    | BoardMsg Board.Msg
    | UserLoaded Decode.Value


urlChange : Url -> Model -> ( Model, Cmd Msg )
urlChange url model =
    let
        newState state =
            { model | state = state }
    in
    case model.user of
        Nothing ->
            case Route.fromUrl url of
                Just Route.Home ->
                    ( newState ViewingHome
                    , Cmd.none
                    )

                Just Route.CreateAccount ->
                    ( newState <| ViewingCreateAccount CreateAccount.init
                    , Cmd.none
                    )

                Just Route.SignIn ->
                    ( newState <| ViewingSignIn SignIn.init
                    , Cmd.none
                    )

                Just Route.ForgottenPassword ->
                    ( newState <| ViewingForgottenPassword ForgottenPassword.init
                    , Cmd.none
                    )

                _ ->
                    -- TODO: Maybe show some error in this situation
                    ( newState ViewingHome
                    , Cmd.none
                    )

        Just user ->
            case Route.fromUrl url of
                Just Route.Dashboard ->
                    let
                        ( dashboardModel, cmd ) =
                            Dashboard.init DashboardMsg user
                    in
                    ( newState <| ViewingDashboard user dashboardModel
                    , cmd
                    )

                Just Route.MyTeams ->
                    let
                        ( myTeamsModel, cmd ) =
                            MyTeams.init MyTeamsMsg user
                    in
                    ( newState <|
                        ViewingMyTeams user <|
                            myTeamsModel
                    , cmd
                    )

                Just Route.CreateTeam ->
                    ( newState <| ViewingCreateTeam user CreateTeam.init
                    , Cmd.none
                    )

                Just (Route.Team teamId) ->
                    case UniqueID.fromString teamId of
                        Nothing ->
                            ( newState <|
                                ViewingError "Invalid team ID"
                            , Cmd.none
                            )

                        Just id ->
                            let
                                ( teamModel, cmd ) =
                                    TeamPage.init TeamMsg id
                            in
                            ( newState <|
                                ViewingTeam user id <|
                                    teamModel
                            , cmd
                            )

                Just (Route.AddTeamMembers teamId) ->
                    case UniqueID.fromString teamId of
                        Nothing ->
                            ( newState <|
                                ViewingError "Invalid team ID"
                            , Cmd.none
                            )

                        Just id ->
                            let
                                ( addTeamMembersModel, cmd ) =
                                    AddTeamMembers.init AddTeamMembersMsg id
                            in
                            ( newState <|
                                ViewingAddTeamMembers user <|
                                    addTeamMembersModel
                            , cmd
                            )

                Just Route.CreateBoard ->
                    case User.getFocusedTeamId user of
                        Just teamId ->
                            ( newState <|
                                ViewingCreateBoard user
                                    { teamId =
                                        teamId
                                    }
                                    CreateBoard.init
                            , Cmd.none
                            )

                        Nothing ->
                            ( Debug.log "TODO: show error here for no focused team" model, Cmd.none )

                Just (Route.Board boardId) ->
                    case User.getFocusedTeamId user of
                        Just teamId ->
                            ( newState <|
                                ViewingBoard user <|
                                    Board.init user { teamId = teamId } boardId model.now
                            , Cmd.none
                            )

                        Nothing ->
                            ( Debug.log "TODO: show error here for no focused team" model, Cmd.none )

                _ ->
                    -- TODO: Maybe show some error in this situation
                    let
                        ( dashboardModel, cmd ) =
                            Dashboard.init DashboardMsg user
                    in
                    ( newState <| ViewingDashboard user dashboardModel
                    , cmd
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
                    let
                        ( dashboardModel, cmd ) =
                            Dashboard.init DashboardMsg user
                    in
                    ( { model
                        | state =
                            ViewingDashboard user dashboardModel
                        , user = Just user
                      }
                    , cmd
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

        ( TeamMsg teamMsg, ViewingTeam teamId user teamModel ) ->
            let
                ( updatedModel, cmd ) =
                    TeamPage.update TeamMsg teamMsg teamModel
            in
            ( { model
                | state = ViewingTeam teamId user updatedModel
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

        ( AddTeamMembersMsg addTeamMembersMsg, ViewingAddTeamMembers user addTeamMembersModel ) ->
            let
                ( updatedModel, cmd ) =
                    AddTeamMembers.update AddTeamMembersMsg addTeamMembersMsg addTeamMembersModel
            in
            ( { model
                | state = ViewingAddTeamMembers user updatedModel
              }
            , cmd
            )

        ( CreateBoardMsg createBoardMsg, ViewingCreateBoard user team createBoardModel ) ->
            let
                ( updatedModel, cmd ) =
                    CreateBoard.update CreateBoardMsg createBoardMsg createBoardModel
            in
            ( { model
                | state = ViewingCreateBoard user team updatedModel
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
                    Layout.withHeader model.layout Route.Home <| Dashboard.view DashboardMsg model.layout dashboardModel

                ViewingMyTeams _ myTeamsModel ->
                    Layout.withHeader model.layout Route.MyTeams <| MyTeams.view MyTeamsMsg myTeamsModel

                ViewingCreateTeam _ createTeamModel ->
                    Layout.withHeader model.layout Route.CreateTeam <| CreateTeam.view CreateTeamMsg createTeamModel

                ViewingAddTeamMembers _ addTeamMembersModel ->
                    Layout.withHeader model.layout (Route.AddTeamMembers "") <| AddTeamMembers.view AddTeamMembersMsg model.layout addTeamMembersModel

                ViewingTeam _ teamId teamModel ->
                    Layout.withHeader model.layout
                        (Route.Team <|
                            UniqueID.toString teamId
                        )
                    <|
                        TeamPage.view TeamMsg model.layout teamModel

                ViewingCreateBoard _ team createBoardModel ->
                    Layout.withHeader model.layout Route.CreateBoard <| CreateBoard.view CreateBoardMsg createBoardModel

                ViewingBoard _ boardModel ->
                    Layout.withHeader model.layout (Route.Board "") <| Board.view model.layout BoardMsg boardModel

                ViewingError errorMsg ->
                    Layout.withHeader model.layout Route.Error <| Page.Error.view errorMsg
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
