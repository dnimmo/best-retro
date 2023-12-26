module Page.Board.AddingItems exposing (view)

import Components.Card as Card
import Components.Input as Input
import Components.Label as Label
import Components.Layout as Layout exposing (Layout)
import DiscussionItem exposing (DiscussionItem)
import Element exposing (..)


type Category
    = Start
    | Stop
    | Continue


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
                [ text "No items have been added yet. Add some items to talk about, or this is going to be a very short session!"
                ]
            ]


discussionItemCard : Category -> DiscussionItem -> Element msg
discussionItemCard category discussionItem =
    column (paddingXY 15 25 :: Card.styles { highlight = False })
        [ row [ width fill ]
            [ paragraph []
                [ text <|
                    DiscussionItem.getContent discussionItem
                ]
            ]
        ]


discussionColumnStyles : List (Attribute msg)
discussionColumnStyles =
    [ width fill
    , Layout.commonColumnSpacing
    , alignTop
    ]


discussionItemColumn : List (Element msg) -> Element msg
discussionItemColumn =
    column
        [ Layout.commonColumnSpacing
        , paddingXY 0 20
        , width fill
        ]


type alias Params msg =
    { msgs :
        { updateStartField : String -> msg
        , updateStopField : String -> msg
        , updateContinueField : String -> msg
        , submitStartItem : msg
        , submitStopItem : msg
        , submitContinueItem : msg
        }
    , values :
        { startField : String
        , stopField : String
        , continueField : String
        }
    }


view : Layout -> Params msg -> List DiscussionItem -> Element msg
view layout { msgs, values } discussionItems =
    column
        [ width fill
        , height fill
        , Layout.commonColumnSpacing
        ]
        [ Layout.containingElement layout
            [ Layout.extraColumnSpacing
            , width fill
            ]
            [ column
                discussionColumnStyles
                [ Label.start
                , Input.inputFieldWithInsetButton
                    { onChange = msgs.updateStartField
                    , value = values.startField
                    , labelString = "What should we start doing?"
                    , onSubmit = msgs.submitStartItem
                    }
                , discussionItemColumn <|
                    List.map (discussionItemCard Start) <|
                        DiscussionItem.getAllStartItems discussionItems
                ]
            , column
                discussionColumnStyles
                [ Label.stop
                , Input.inputFieldWithInsetButton
                    { onChange = msgs.updateStopField
                    , value = values.stopField
                    , labelString = "What should we stop doing?"
                    , onSubmit = msgs.submitStopItem
                    }
                , discussionItemColumn <|
                    List.map (discussionItemCard Stop) <|
                        DiscussionItem.getAllStopItems discussionItems
                ]
            , column
                discussionColumnStyles
                [ Label.continue
                , Input.inputFieldWithInsetButton
                    { onChange = msgs.updateContinueField
                    , value = values.continueField
                    , labelString = "What should we keep doing?"
                    , onSubmit = msgs.submitContinueItem
                    }
                , discussionItemColumn <|
                    List.map (discussionItemCard Continue) <|
                        DiscussionItem.getAllContinueItems discussionItems
                ]
            ]
        , if List.isEmpty discussionItems then
            emptyDiscussionItemView

          else
            none
        ]
