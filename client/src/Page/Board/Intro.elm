module Page.Board.Intro exposing (view)

import Element exposing (..)


view : Element msg
view =
    column
        [ width fill
        , height fill
        ]
        [ paragraph []
            [ text "Some text here plz Nimmo. Explain what is going to happen in the Retro, with some text that only appears if there are actions " ]
        ]
