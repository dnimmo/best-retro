module Page.Board.DiscussingPreviousActions exposing (view)

import ActionItem exposing (ActionItem)
import Components.Card as Card
import Components.Layout as Layout exposing (Layout)
import Element exposing (..)


type alias RequiredMessages msg =
    { markActionAsNotStarted : ActionItem -> msg
    , markActionAsInProgress : ActionItem -> msg
    , markActionAsComplete : ActionItem -> msg
    }


view : Layout -> RequiredMessages msg -> List ActionItem -> Element msg
view layout { markActionAsComplete, markActionAsNotStarted, markActionAsInProgress } actions =
    column
        [ width fill
        , height fill
        , Layout.commonColumnSpacing
        ]
        [ paragraph []
            [ el [] <|
                text <|
                    "Discussing previous actions for "
                        ++ "TODO: Get team name"
            ]
        , wrappedRow
            [ Layout.commonColumnSpacing
            , Layout.commonRowSpacing
            , width fill
            ]
            (actions
                |> List.map
                    (\item ->
                        Card.action item
                            { setComplete = markActionAsComplete item
                            , setInProgress = markActionAsInProgress item
                            , setNotStarted = markActionAsNotStarted item
                            }
                    )
            )
        ]
