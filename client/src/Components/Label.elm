module Components.Label exposing (continue, continueSmall, start, startSmall, stop, stopSmall)

import Components.Colours as Colours
import Components.Icons as Icons
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font


type Label
    = Start
    | Stop
    | Continue


type Size
    = Small
    | Full


details : Label -> ( String, Element msg )
details l =
    case l of
        Start ->
            ( "START", Icons.start )

        Stop ->
            ( "STOP", Icons.stop )

        Continue ->
            ( "CONTINUE", Icons.continue )


label : Label -> Size -> Element msg
label l s =
    let
        ( labelText, icon ) =
            details l

        baseStyles =
            case s of
                Small ->
                    [ padding 4 ]

                Full ->
                    [ width <| px 110
                    , paddingXY 10 5
                    ]
    in
    row
        (baseStyles
            ++ [ Border.rounded 20
               , Font.size 12
               , Background.color Colours.mediumBlue
               , Border.color Colours.darkBlue
               , Border.width 1
               , Font.color Colours.white
               , spacing 5
               ]
        )
        [ el [] icon
        , case s of
            Full ->
                el [ centerX ] (text labelText)

            Small ->
                none
        ]


start : Element msg
start =
    label Start Full


stop : Element msg
stop =
    label Stop Full


continue : Element msg
continue =
    label Continue Full


startSmall : Element msg
startSmall =
    label Start Small


stopSmall : Element msg
stopSmall =
    label Stop Small


continueSmall : Element msg
continueSmall =
    label Continue Small
