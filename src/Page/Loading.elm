module Page.Loading exposing (view)

import Element exposing (..)


view : Element msg
view =
    el
        [ centerX
        , centerY
        ]
    <|
        text "..."
