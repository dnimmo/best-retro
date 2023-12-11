module Page.Board exposing (Model, Msg, init, update, view)

import Components
import Components.Icons as Icons
import Components.Input as Input
import Components.Layout as Layout
import DiscussionItem exposing (DiscussionItem)
import Element exposing (..)
import Route



-- MODEL


type alias BoardID =
    String


type Model
    = Model BoardID State


type State
    = AddingDiscussionItems (List DiscussionItem)



-- UPDATE


type Msg
    = UpdateField String


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg model =
    case msg of
        UpdateField str ->
            ( model
            , Cmd.none
            )



-- VIEW


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


addingDiscussionItemsView : (Msg -> msg) -> List DiscussionItem -> Element msg
addingDiscussionItemsView on discussionItems =
    column
        [ width fill
        , height fill
        , Layout.commonColumnSpacing
        ]
        [ column
            [ Layout.commonColumnSpacing
            , width fill
            ]
            [ column
                [ width fill
                , Layout.commonColumnSpacing
                ]
                [ row
                    [ Layout.commonRowSpacing
                    , width fill
                    ]
                    [ el [] Icons.start
                    , el [] <| text "Start"
                    ]
                , Input.inputFieldWithInsetButton
                    { onChange = on << UpdateField
                    , value = ""
                    , labelString = "What should we start doing?"
                    , onSubmit = on <| UpdateField "TODO: Submit"
                    }
                ]
            , column
                [ width fill
                , Layout.commonColumnSpacing
                ]
                [ row [ Layout.commonRowSpacing ]
                    [ el [] Icons.stop
                    , el [] <| text "Stop"
                    ]
                , Input.inputFieldWithInsetButton
                    { onChange = on << UpdateField
                    , value = ""
                    , labelString = "What should we stop doing?"
                    , onSubmit = on <| UpdateField "TODO: Submit"
                    }
                ]
            , column
                [ width fill
                , Layout.commonColumnSpacing
                ]
                [ row [ Layout.commonRowSpacing ]
                    [ el [] Icons.continue
                    , el [] <| text "Continue"
                    ]
                , Input.inputFieldWithInsetButton
                    { onChange = on << UpdateField
                    , value = ""
                    , labelString = "What should we keep doing?"
                    , onSubmit = on <| UpdateField "TODO: Submit"
                    }
                ]
            ]
        , if List.isEmpty discussionItems then
            emptyDiscussionItemView

          else
            none
        ]


view : (Msg -> msg) -> Model -> Element msg
view on (Model boardId state) =
    column
        [ width fill
        , height fill
        , Layout.commonPadding
        , Layout.commonColumnSpacing
        ]
        [ case state of
            AddingDiscussionItems discussionItems ->
                addingDiscussionItemsView on discussionItems
        , Components.link Route.Dashboard [] "Back to dashboard"
        ]


init : String -> Model
init boardId =
    -- TODO: Add Loading state and fetch board here
    Model boardId <| AddingDiscussionItems []
