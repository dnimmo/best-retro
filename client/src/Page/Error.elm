module Page.Error exposing (view)

import Element exposing (Element)


view : String -> Element msg
view message =
    Element.text message
