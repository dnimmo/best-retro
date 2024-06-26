module Page.Board.AddingItems exposing (view)

import Components.Input as Input
import Components.Label as Label
import Components.Layout as Layout exposing (Layout)
import Components.Timer as Timer
import DiscussionItem exposing (DiscussionItem)
import Element exposing (..)
import Element.Font as Font
import Page.Board.Shared as Shared


emptyDiscussionItemView : Element msg
emptyDiscussionItemView =
    el
        [ width fill
        , height fill
        ]
    <|
        column
            [ Layout.commonColumnSpacing
            , width fill
            , centerX
            , centerY
            ]
            [ el
                [ width fill
                , centerY
                ]
              <|
                image
                    [ width (fill |> maximum 300)
                    , centerX
                    , centerY
                    ]
                    { src = "/img/absurd-vial.png"
                    , description = "No items"
                    }
            , paragraph
                [ width (fill |> maximum 300)
                , centerX
                ]
                [ el [ Font.italic ] <| text "No items have been added yet. Add some items to talk about, or this is going to be a very short session!"
                ]
            ]


type alias Params msg =
    { msgs :
        { updateStartField : String -> msg
        , updateStopField : String -> msg
        , updateContinueField : String -> msg
        , submitStartItem : msg
        , submitStopItem : msg
        , submitContinueItem : msg
        , removeItem : DiscussionItem -> msg
        , onTimerMsg : Timer.Msg -> msg
        }
    , values :
        { startField : String
        , stopField : String
        , continueField : String
        }
    , timer : Timer.Model
    }


view : Layout -> Params msg -> List DiscussionItem -> Element msg
view layout { msgs, values, timer } discussionItems =
    column
        [ width fill
        , height fill
        , Layout.commonColumnSpacing
        ]
        [ Timer.view msgs.onTimerMsg timer
        , Layout.containingElement layout
            [ Layout.extraColumnSpacing
            , width fill
            ]
            [ column
                Shared.discussionColumnStyles
                [ Label.start
                , Input.inputFieldWithInsetButton
                    { onChange = msgs.updateStartField
                    , value = values.startField
                    , labelString = "What should we start doing?"
                    , onSubmit = msgs.submitStartItem
                    }
                , Shared.discussionItemColumn Nothing <|
                    List.map (Shared.discussionItemCard msgs.removeItem) <|
                        DiscussionItem.getAllStartItems discussionItems
                ]
            , column
                Shared.discussionColumnStyles
                [ Label.stop
                , Input.inputFieldWithInsetButton
                    { onChange = msgs.updateStopField
                    , value = values.stopField
                    , labelString = "What should we stop doing?"
                    , onSubmit = msgs.submitStopItem
                    }
                , Shared.discussionItemColumn Nothing <|
                    List.map (Shared.discussionItemCard msgs.removeItem) <|
                        DiscussionItem.getAllStopItems discussionItems
                ]
            , column
                Shared.discussionColumnStyles
                [ Label.continue
                , Input.inputFieldWithInsetButton
                    { onChange = msgs.updateContinueField
                    , value = values.continueField
                    , labelString = "What should we keep doing?"
                    , onSubmit = msgs.submitContinueItem
                    }
                , Shared.discussionItemColumn Nothing <|
                    List.map
                        (Shared.discussionItemCard msgs.removeItem)
                    <|
                        DiscussionItem.getAllContinueItems discussionItems
                ]
            ]
        , if List.isEmpty discussionItems then
            emptyDiscussionItemView

          else
            none
        ]
