module Page.Board.Voting exposing (view)

import Components.Label as Label
import Components.Layout as Layout exposing (Layout)
import Components.Timer as Timer
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


continueItems :
    List
        { item : DiscussionItem
        , votes : Set String
        }
    ->
        List
            { item : DiscussionItem
            , votes : Set String
            }
continueItems =
    List.filter
        (\{ item } ->
            DiscussionItem.isContinue item
        )


view :
    Layout
    -> User
    -> Timer.Model
    ->
        { toggleVoteMsg : DiscussionItem -> msg
        , onTimerMsg : Timer.Msg -> msg
        }
    ->
        List
            { item : DiscussionItem
            , votes : Set String
            }
    -> Element msg
view layout user timer msgs discussionItems =
    let
        votingCard =
            Shared.votingItemCard (User.getId user) msgs.toggleVoteMsg
    in
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
                , Shared.discussionItemColumn Nothing <|
                    List.map votingCard <|
                        startItems discussionItems
                ]
            , column
                Shared.discussionColumnStyles
                [ Label.stop
                , Shared.discussionItemColumn Nothing <|
                    List.map votingCard <|
                        stopItems discussionItems
                ]
            , column
                Shared.discussionColumnStyles
                [ Label.continue
                , Shared.discussionItemColumn Nothing <|
                    List.map
                        votingCard
                    <|
                        continueItems discussionItems
                ]
            ]
        ]
