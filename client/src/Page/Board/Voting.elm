module Page.Board.Voting exposing (view)

import Components.Label as Label
import Components.Layout as Layout exposing (Layout)
import DiscussionItem exposing (DiscussionItem)
import Element exposing (..)
import Page.Board.Shared as Shared
import Set exposing (Set)
import User exposing (User)


startItems :
    List
        { item : DiscussionItem
        , votes : Set String
        }
    ->
        List
            { item : DiscussionItem
            , votes : Set String
            }
startItems =
    List.filter
        (\{ item } ->
            DiscussionItem.isStart item
        )


stopItems :
    List
        { item : DiscussionItem
        , votes : Set String
        }
    ->
        List
            { item : DiscussionItem
            , votes : Set String
            }
stopItems =
    List.filter
        (\{ item } ->
            DiscussionItem.isStop item
        )


continueItems =
    List.filter
        (\{ item } ->
            DiscussionItem.isContinue item
        )


view :
    Layout
    -> User
    -> (DiscussionItem -> msg)
    ->
        List
            { item : DiscussionItem
            , votes : Set String
            }
    -> Element msg
view layout user toggleVoteMsg discussionItems =
    let
        votingCard category =
            Shared.votingItemCard category (User.getId user) toggleVoteMsg
    in
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
                    List.map (votingCard Shared.Start) <|
                        startItems discussionItems
                ]
            , column
                Shared.discussionColumnStyles
                [ Label.stop
                , Shared.discussionItemColumn <|
                    List.map (votingCard Shared.Stop) <|
                        stopItems discussionItems
                ]
            , column
                Shared.discussionColumnStyles
                [ Label.continue
                , Shared.discussionItemColumn <|
                    List.map
                        (votingCard Shared.Continue)
                    <|
                        continueItems discussionItems
                ]
            ]
        ]
