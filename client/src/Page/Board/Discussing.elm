module Page.Board.Discussing exposing (view)

import ActionItem exposing (ActionItem)
import Components exposing (edges)
import Components.Card as Card
import Components.Colours as Colours
import Components.Input as Input
import Components.Layout as Layout exposing (Layout)
import Components.Timer as Timer
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
discussingItemCard { startDiscussion, hasBeenDiscussed } { item, votes } =
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
                , el [ alignRight ] <|
                    if hasBeenDiscussed then
                        Input.completeButton <| startDiscussion item

                    else
                        Input.primaryActionButton
                            { onPress = startDiscussion item
                            , labelString = "Start discussion"
                            }
                ]


currentlyDiscussingElement :
    { updateActionField : String -> msg
    , updateAssigneeField : String -> msg
    , onTimerMsg : Timer.Msg -> msg
    , cancelDiscussion : msg
    , finishDiscussingItem : DiscussionItem -> msg
    , submitAction : msg
    , actionField : String
    , assignee : String
    }
    -> ( DiscussionItem, Timer.Model )
    -> Element msg
currentlyDiscussingElement { updateActionField, updateAssigneeField, submitAction, actionField, assignee, cancelDiscussion, onTimerMsg, finishDiscussingItem } ( item, timer ) =
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
            [ row
                [ width fill
                , moveDown 5
                ]
                [ el [] <|
                    text "Currently discussing"
                , el [ alignRight ] <|
                    Input.cancelButton cancelDiscussion
                ]
            , el
                [ moveUp 33
                , width fill
                ]
              <|
                Shared.itemCard item Nothing
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
            , row
                [ spacing 90
                , alignRight
                ]
                [ el [] <|
                    Timer.view onTimerMsg timer
                , el [] <|
                    Input.primaryActionButton
                        { onPress = finishDiscussingItem item
                        , labelString = "Finish discussing this item"
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
        , cancelDiscussion : msg
        , finishDiscussingItem : DiscussionItem -> msg
        , onTimerMsg : Timer.Msg -> msg
        , submitAction : msg
        , actionField : String
        , assignee : String
        , discussed : List DiscussionItem
        , currentlyDiscussing : Maybe ( DiscussionItem, Timer.Model )
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
view layout { startDiscussion, updateActionField, updateAssigneeField, discussed, cancelDiscussion, assignee, currentlyDiscussing, onTimerMsg, actionField, finishDiscussingItem, submitAction } itemsAndVotes actions =
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
                        , actionField =
                            actionField
                        , assignee =
                            assignee
                        , cancelDiscussion =
                            cancelDiscussion
                        , finishDiscussingItem =
                            finishDiscussingItem
                        , onTimerMsg = onTimerMsg
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
                    , Layout.commonColumnSpacing
                    ]
                    [ el [ width fill, height fill ] <|
                        image
                            [ width <| px 340
                            , height fill
                            , centerX
                            ]
                            { src = "/img/absurd-hourglass.png"
                            , description = ""
                            }
                    , el
                        [ width <| px 260
                        , Font.italic
                        , centerX
                        ]
                      <|
                        text "New actions will appear here"
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
