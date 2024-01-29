module Page.AddTeamMembers exposing (Model, Msg, init, update, view)

import Components exposing (edges)
import Components.Colours as Colours
import Components.Font as Font
import Components.Icons as Icons
import Components.Input as Input
import Components.Layout as Layout exposing (Layout)
import Element exposing (..)
import Element.Font as EFont
import Email exposing (Email)
import UniqueID exposing (UniqueID)



-- MODEL


type Model
    = Model
        { teamId : UniqueID
        , invited : List ( Email, Status )
        , input : Email
        , error : Maybe String
        }


type Status
    = Pending
    | Invited
    | Failed



-- UPDATE


type Msg
    = UpdateEmailAddress String
    | SendInvitation
    | InvitationSent (Result String Email)


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg (Model details) =
    case msg of
        UpdateEmailAddress str ->
            ( Model
                { details
                    | input = Email.create <| String.toLower str
                }
            , Cmd.none
            )

        SendInvitation ->
            if
                List.member details.input
                    (List.map Tuple.first details.invited)
            then
                ( Model
                    { details
                        | error =
                            Just "You've already invited this person to your team."
                    }
                , Cmd.none
                )

            else if Email.isValid details.input then
                ( Model
                    { details
                        | input = Email.create ""
                        , invited =
                            ( details.input
                            , Pending
                            )
                                :: details.invited
                    }
                , Cmd.none
                )

            else
                ( Model
                    { details
                        | error =
                            Just "The email address you've entered isn't valid. Can you check it again please?"
                    }
                , Cmd.none
                )

        InvitationSent (Ok email) ->
            ( Model
                { details
                    | invited =
                        details.invited
                            |> List.map
                                (\( e, status ) ->
                                    if e == email then
                                        ( e
                                        , Invited
                                        )

                                    else
                                        ( e
                                        , status
                                        )
                                )
                }
            , Cmd.none
            )

        InvitationSent (Err str) ->
            ( Model
                { details
                  -- TODO: Update the "invited list" to show the failed invitation
                    | error = Just str
                }
            , Cmd.none
            )



-- VIEW


icon : Status -> Element msg
icon status =
    case status of
        Pending ->
            el
                [ EFont.color Colours.mediumBlue
                , centerY
                ]
                Icons.hourglass

        Invited ->
            el
                [ EFont.color Colours.green
                , centerY
                ]
                Icons.succeeded

        Failed ->
            el
                [ EFont.color Colours.orangeRed
                , centerY
                ]
                Icons.failed


view : (Msg -> msg) -> Layout -> Model -> Element msg
view on layout (Model { invited, error, input }) =
    Layout.page
        [ Font.heading "Add Team Members"
        , paragraph [ paddingEach { edges | bottom = 24 } ]
            [ text "Add team members by entering their email addresses below. "
            , text "Your new team members will receive an email with a link to join your team."
            ]
        , column
            [ width fill
            , spaceEvenly
            , spacing 36
            ]
            [ column
                [ width fill
                , alignTop
                , spacing 24
                ]
                [ el
                    [ width (fill |> maximum 360)
                    , paddingEach { edges | top = 20 }
                    ]
                  <|
                    Input.inputFieldWithInsetButton
                        { value = Email.value input
                        , onChange = on << UpdateEmailAddress
                        , labelString = "E-mail address"
                        , onSubmit = on SendInvitation
                        }
                , case error of
                    Just str ->
                        paragraph [ EFont.color Colours.orangeRed ]
                            [ el [] <|
                                text str
                            ]

                    Nothing ->
                        el [] none
                ]
            , column
                [ width fill
                , spacing 12
                , alignTop
                ]
              <|
                if List.isEmpty invited then
                    [ column
                        [ width fill
                        ]
                        [ image
                            [ width (fill |> maximum 360)
                            , centerX
                            ]
                            { src = "/img/absurd-fishbowl.png", description = "" }
                        ]
                    ]

                else
                    Font.headingTwo "Invited"
                        :: List.map
                            (\( email, status ) ->
                                row
                                    [ spacing 12
                                    , width fill
                                    ]
                                    [ icon status
                                    , el [] <| text (Email.value email)
                                    ]
                            )
                            invited
            ]
        ]



-- INIT


init : (Msg -> msg) -> UniqueID -> ( Model, Cmd msg )
init on id =
    ( Model
        { teamId = id
        , invited =
            []
        , input = Email.create ""
        , error = Nothing
        }
    , Cmd.none
    )
