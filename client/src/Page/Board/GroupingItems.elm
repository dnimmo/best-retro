module Page.Board.GroupingItems exposing (view)

import Components.Label as Label
import Components.Layout as Layout exposing (Layout)
import DiscussionItem exposing (DiscussionItem)
import Element exposing (..)
import Page.Board.Shared as Shared
import UniqueID exposing (UniqueID)


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
                    { src = "/img/absurd-graduate.png"
                    , description = "No items"
                    }
            , paragraph
                [ width (fill |> maximum 300)
                , centerX
                ]
                [ text "No items have been added. I guess everything is perfect!"
                ]
            ]


type alias Params msg =
    { addToGroupingList : UniqueID -> msg
    , groupItems : msg
    , itemsInGroupingList : List String
    }


view : Layout -> Params msg -> List DiscussionItem -> Element msg
view layout { addToGroupingList, groupItems, itemsInGroupingList } discussionItems =
    let
        groupItemsCard category =
            Shared.groupingItemCard category addToGroupingList itemsInGroupingList groupItems
    in
    if List.isEmpty discussionItems then
        emptyDiscussionItemView

    else
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
                    Shared.discussionColumnStyles
                    [ Label.start
                    , Shared.discussionItemColumn <|
                        List.map (groupItemsCard Shared.Start) <|
                            DiscussionItem.getAllStartItems discussionItems
                    ]
                , column
                    Shared.discussionColumnStyles
                    [ Label.stop
                    , Shared.discussionItemColumn <|
                        List.map (groupItemsCard Shared.Stop) <|
                            DiscussionItem.getAllStopItems discussionItems
                    ]
                , column
                    Shared.discussionColumnStyles
                    [ Label.continue
                    , Shared.discussionItemColumn <|
                        List.map
                            (groupItemsCard Shared.Continue)
                        <|
                            DiscussionItem.getAllContinueItems discussionItems
                    ]
                ]
            ]
