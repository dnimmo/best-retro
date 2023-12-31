module Page.Board.Intro exposing (view)

import Components.Layout as Layout
import Element exposing (..)
import Element.Font as Font


view : Element msg
view =
    column
        [ width fill
        , height fill
        , centerX
        , Layout.commonColumnSpacing
        ]
        [ paragraph
            [ width fill
            ]
            [ el [] <| text "Welcome to today's Retrospective!"
            ]
        , column
            [ centerX
            , centerY
            , Layout.commonColumnSpacing
            ]
            [ el [ centerX ] <|
                image [ width <| px 340 ]
                    { src = "/img/absurd-hands.png"
                    , description = ""
                    }
            , paragraph
                [ Font.italic
                , width <| px 340
                ]
                [ el [] <| text "Remember: Everyone was doing their best with the information they had at the time."
                ]
            ]
        ]
