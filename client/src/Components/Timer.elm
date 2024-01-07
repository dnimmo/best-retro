module Components.Timer exposing (Model, Msg, init, isFinished, subscriptions, update, view)

import Components.Colours as Colours
import Components.Icons as Icons
import Components.Input as Input
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Time



-- MODEL


type Model
    = Model { initialTimeLimit : Int } State


type State
    = NotStarted
    | Running Int
    | Paused Int
    | Finished


isFinished : Model -> Bool
isFinished (Model _ state) =
    case state of
        Finished ->
            True

        _ ->
            False



-- UPDATE


type Msg
    = Start
    | Tick Time.Posix
    | Pause
    | AddTime


update : Msg -> Model -> Model
update msg ((Model ({ initialTimeLimit } as common) state) as model) =
    case msg of
        Start ->
            case state of
                NotStarted ->
                    Model common (Running <| initialTimeLimit)

                Paused timeRemaining ->
                    Model common (Running timeRemaining)

                _ ->
                    model

        Tick _ ->
            case state of
                Running timeRemaining ->
                    if timeRemaining > 0 then
                        Model common (Running (timeRemaining - 1000))

                    else
                        Model common Finished

                _ ->
                    model

        Pause ->
            case state of
                Running timeRemaining ->
                    Model common (Paused timeRemaining)

                _ ->
                    model

        AddTime ->
            Model common <| Paused (1000 * 60)



-- VIEW


timeDisplay : Int -> Element msg
timeDisplay time =
    let
        minutes =
            time // 60000

        seconds =
            Basics.remainderBy 60 (time // 1000)

        addLeadingZero =
            String.padLeft 2 '0' << String.fromInt

        remainingTime =
            addLeadingZero minutes
                ++ ":"
                ++ addLeadingZero seconds
    in
    el [ width fill ] <|
        row
            [ Font.color Colours.white
            , centerX
            , Background.color Colours.mediumBlue
            , paddingXY 10 5
            , Border.rounded 50
            , Border.color Colours.darkBlue
            , Border.width 1
            , spacing 5
            , Font.size 20
            ]
            [ el [] <| Icons.timer
            , el
                []
              <|
                text remainingTime
            ]


notRunningView : (Msg -> msg) -> Int -> Bool -> Element msg
notRunningView on timeToDisplay hasFinished =
    row
        [ width fill
        ]
        [ el
            [ centerX
            , onRight <|
                el
                    [ height fill
                    , moveRight 10
                    ]
                <|
                    if hasFinished then
                        Input.addTimeButton <|
                            on AddTime

                    else
                        Input.startButton <|
                            on Start
            ]
          <|
            timeDisplay timeToDisplay
        ]


runningView : (Msg -> msg) -> Int -> Element msg
runningView on timeToDisplay =
    row
        [ width fill
        ]
        [ el
            [ centerX
            , onRight <|
                el
                    [ height fill
                    , moveRight 10
                    ]
                <|
                    Input.pauseButton <|
                        on Pause
            ]
          <|
            timeDisplay timeToDisplay
        ]


view : (Msg -> msg) -> Model -> Element msg
view on (Model { initialTimeLimit } state) =
    case state of
        NotStarted ->
            notRunningView on initialTimeLimit False

        Running timeRemaining ->
            runningView on timeRemaining

        Paused timeRemaining ->
            notRunningView on timeRemaining False

        Finished ->
            notRunningView on 0 True



-- INIT


init : Int -> Model
init initialNumberOfMinutes =
    Model
        { initialTimeLimit = 1000 * 60 * initialNumberOfMinutes }
        NotStarted


subscriptions : (Msg -> msg) -> Model -> Sub msg
subscriptions on (Model _ state) =
    case state of
        NotStarted ->
            Sub.none

        Running _ ->
            Time.every 1000 <| on << Tick

        Paused _ ->
            Sub.none

        Finished ->
            Sub.none
