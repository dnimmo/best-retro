module Page.Board.Intro exposing (view)

import Element exposing (..)


view : Element msg
view =
    column
        [ width fill
        , height fill
        ]
        [ text "Some text here plz Nimmo" ]
