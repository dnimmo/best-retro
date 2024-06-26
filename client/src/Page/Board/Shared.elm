module Page.Board.Shared exposing
    ( discussionColumnStyles
    , discussionItemCard
    , discussionItemColumn
    , groupingItemCard
    , itemCard
    , votingItemCard
    )

import Components exposing (edges)
import Components.Card as Card
import Components.Colours as Colours
import Components.Input as Input
import Components.Layout as Layout
import DiscussionItem exposing (DiscussionItem)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Set exposing (Set)
import UniqueID exposing (UniqueID)


itemCard : DiscussionItem -> Maybe (Element msg) -> Element msg
itemCard discussionItem maybeExtraContent =
    column
        (paddingEach
            { top = 25
            , left = 15
            , right = 5
            , bottom = 5
            }
            :: Card.styles { highlight = False }
        )
        [ row
            [ width fill
            , paddingEach
                { edges
                    | right = 15
                    , bottom = 20
                }
            ]
            [ paragraph []
                [ text <|
                    DiscussionItem.getContent discussionItem
                ]
            ]
        , case maybeExtraContent of
            Just extraContent ->
                extraContent

            Nothing ->
                none
        ]


discussionItemCard : (DiscussionItem -> msg) -> DiscussionItem -> Element msg
discussionItemCard removeMsg discussionItem =
    itemCard discussionItem <|
        Just <|
            row
                [ width fill
                , paddingEach { edges | top = 20 }
                ]
                [ -- TODO: Enable edit button
                  --     el
                  --     [ alignRight
                  --     , mouseOver [ scale 1.2 ]
                  --     ]
                  --   <|
                  --     Input.editButton (removeMsg discussionItem)
                  -- ,
                  el
                    [ alignRight
                    , mouseOver [ scale 1.2 ]
                    ]
                  <|
                    Input.removeButton (removeMsg discussionItem)
                ]


groupingItemCard : (UniqueID -> msg) -> List String -> msg -> DiscussionItem -> Element msg
groupingItemCard addToGroupingList itemsInGroupingList groupItems discussionItem =
    itemCard discussionItem <|
        Just <|
            row
                [ width fill
                , paddingEach { edges | top = 40 }
                , Layout.lessRowSpacing
                ]
                [ if
                    List.length itemsInGroupingList
                        > 1
                        && List.member
                            (UniqueID.toComparable <|
                                DiscussionItem.getId discussionItem
                            )
                            itemsInGroupingList
                  then
                    el [ alignRight ] <|
                        Input.combineButton
                            (List.length itemsInGroupingList)
                            groupItems

                  else
                    none
                , el [ alignRight ] <|
                    Input.checkbox
                        (List.member
                            (UniqueID.toComparable <|
                                DiscussionItem.getId discussionItem
                            )
                            itemsInGroupingList
                        )
                        (\_ ->
                            addToGroupingList
                                (DiscussionItem.getId discussionItem)
                        )
                ]


votingItemCard : UniqueID -> (DiscussionItem -> msg) -> { item : DiscussionItem, votes : Set String } -> Element msg
votingItemCard currentUserId toggleVoteMsg { item, votes } =
    itemCard item <|
        Just <|
            el
                [ width fill
                , paddingEach { edges | top = 40 }
                , Layout.lessRowSpacing
                ]
            <|
                el
                    [ alignRight
                    , inFront <|
                        if Set.isEmpty votes then
                            none

                        else
                            el
                                [ alignRight
                                , Border.rounded 50
                                , Border.color Colours.mediumBlue
                                , Background.color Colours.white
                                , Border.width 1
                                , paddingXY 8 5
                                , Font.bold
                                , Font.size 16
                                , Font.color Colours.mediumBlue
                                , moveUp 15
                                , moveRight 15
                                ]
                            <|
                                text <|
                                    String.fromInt <|
                                        Set.size votes
                    ]
                <|
                    (if Set.member (UniqueID.toComparable currentUserId) votes then
                        Input.downvoteButton

                     else
                        Input.upvoteButton
                    )
                    <|
                        toggleVoteMsg
                            item


discussionColumnStyles : List (Attribute msg)
discussionColumnStyles =
    [ width fill
    , Layout.commonColumnSpacing
    , alignTop
    ]


discussionItemColumn : Maybe (Element msg) -> List (Element msg) -> Element msg
discussionItemColumn elementInFront contents =
    column
        [ Layout.commonColumnSpacing
        , paddingXY 0 20
        , width fill
        , height fill
        , alignTop
        , inFront <|
            case elementInFront of
                Just element ->
                    element

                Nothing ->
                    none
        ]
        contents
