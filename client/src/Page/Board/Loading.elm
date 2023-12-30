module Page.Board.Loading exposing (view)

import Element exposing (..)


view : Element msg
view =
    el
        [ width fill
        , height fill
        ]
    <|
        image
            [ centerX
            , centerY
            ]
            { src = "/img/loading.svg"
            , description = "Loading"
            }
