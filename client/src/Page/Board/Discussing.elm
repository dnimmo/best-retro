module Page.Board.Discussing exposing (view)

import ActionItem exposing (ActionItem)
import Components exposing (edges)
import Components.Card as Card
import Components.Colours as Colours
import Components.Input as Input
import Components.Layout as Layout exposing (Layout)
import DiscussionItem exposing (DiscussionItem)
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Page.Board.Shared as Shared
import Set exposing (Set)


modifyItemsAndVotes :
    List
        { item : DiscussionItem
        , votes : Set String
        }
    ->
        List
            { item : DiscussionItem
            , votes : Int
            }
modifyItemsAndVotes itemsAndVotes =
    itemsAndVotes
        |> List.map
            (\{ item, votes } ->
                { item = item
                , votes = Set.size votes
                }
            )
        |> List.sortBy .votes
        |> List.reverse


discussingItemCard :
    { startDiscussion : DiscussionItem -> msg
    , hasBeenDiscussed : Bool
    }
    -> { item : DiscussionItem, votes : Int }
    -> Element msg
discussingItemCard { startDiscussion } { item, votes } =
    Shared.itemCard item <|
        Just <|
            row
                [ paddingEach
                    { edges
                        | right = 10
                        , top = 20
                        , bottom = 10
                    }
                , width fill
                , Layout.commonRowSpacing
                ]
                [ DiscussionItem.getLabel item
                , el
                    [ Font.color Colours.white
                    , Background.color Colours.mediumBlue
                    , Border.color Colours.darkBlue
                    , Border.width 1
                    , Border.rounded 50
                    , paddingXY 9 6
                    , Font.size 16
                    ]
                  <|
                    text <|
                        String.fromInt votes
                , el [ alignRight ] <| Input.startDiscussion (startDiscussion item)
                ]


currentlyDiscussingElement :
    { updateActionField : String -> msg
    , updateAssigneeField : String -> msg
    , submitAction : msg
    , actionField : String
    , assignee : String
    }
    -> DiscussionItem
    -> Element msg
currentlyDiscussingElement { updateActionField, updateAssigneeField, submitAction, actionField, assignee } item =
    el
        [ height fill
        , width fill
        , Background.color Colours.skyBlue
        , Border.shadow
            { offset = ( 0, 0 )
            , blur = 10
            , color = Colours.skyBlue
            , size = 15
            }
        ]
    <|
        column
            [ width fill
            , Layout.extraColumnSpacing
            ]
            [ el [ moveDown 20 ] <| text "Currently discussing"
            , Shared.itemCard item Nothing
            , row
                [ width fill
                , Layout.commonRowSpacing
                ]
                [ el
                    [ width fill
                    , paddingXY 0 10
                    ]
                  <|
                    Input.textField
                        { onChange = updateActionField
                        , labelString = "Add an action"
                        , value = actionField
                        }
                , el
                    [ width fill
                    ]
                  <|
                    Input.inputFieldWithInsetButton
                        { onChange = updateAssigneeField
                        , labelString = "Assign"
                        , onSubmit = submitAction
                        , value = assignee
                        }
                ]
            ]


actionItemCard : ActionItem -> Element msg
actionItemCard action =
    Card.basicAction action


view :
    Layout
    ->
        { startDiscussion : DiscussionItem -> msg
        , updateActionField : String -> msg
        , updateAssigneeField : String -> msg
        , submitAction : msg
        , actionField : String
        , assignee : String
        , discussed : List DiscussionItem
        , currentlyDiscussing : Maybe DiscussionItem
        }
    ->
        List
            { item : DiscussionItem
            , votes : Set String
            }
    -> List ActionItem
    ->
        Element
            msg
view layout { startDiscussion, updateActionField, updateAssigneeField, discussed, assignee, currentlyDiscussing, actionField, submitAction } itemsAndVotes actions =
    Layout.containingElement layout
        [ width fill
        , height fill
        , Layout.commonRowSpacing
        ]
        [ Shared.discussionItemColumn
            (Maybe.andThen
                (Just
                    << currentlyDiscussingElement
                        { updateActionField =
                            updateActionField
                        , updateAssigneeField =
                            updateAssigneeField
                        , submitAction =
                            submitAction
                        , actionField = actionField
                        , assignee = assignee
                        }
                )
                currentlyDiscussing
            )
            [ el [] <| text "To discuss"
            , column
                [ Layout.commonColumnSpacing
                , width fill
                ]
                (modifyItemsAndVotes itemsAndVotes
                    |> List.map
                        (\({ item } as itemAndVotes) ->
                            discussingItemCard
                                { startDiscussion = startDiscussion
                                , hasBeenDiscussed = List.member item discussed
                                }
                                itemAndVotes
                        )
                )
            ]
        , el [ width <| px 50 ] <| none
        , Shared.discussionItemColumn
            Nothing
            [ el [] <| text "Actions"
            , if List.isEmpty actions then
                column
                    [ width fill
                    , centerY
                    ]
                    [ el [ width fill, height fill ] <|
                        image
                            [ width (fill |> maximum 300)
                            , height fill
                            , centerX
                            ]
                            { src = "/img/absurd-hourglass.png"
                            , description = ""
                            }
                    ]

              else
                column
                    [ width fill
                    , Layout.commonColumnSpacing
                    ]
                    (List.map
                        (\action ->
                            actionItemCard action
                        )
                        actions
                    )
            ]
        ]
