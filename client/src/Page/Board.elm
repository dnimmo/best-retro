module Page.Board exposing (Model, Msg, init, update, view)

import Components
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
    = Msg


update : (Msg -> msg) -> Msg -> Model -> ( Model, Cmd msg )
update on msg model =
    case msg of
        Msg ->
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
        [ el [] <| text "TO DO: Controls here"
        , if List.isEmpty discussionItems then
            emptyDiscussionItemView

          else
            el [] <| text "TO DO: Discussion items here"
        ]


view : (Msg -> msg) -> Model -> Element msg
view on (Model boardId state) =
    column
        [ width fill
        , height fill
        , Layout.commonPadding
        , Layout.commonColumnSpacing
        ]
        [ Components.heading "Board"
        , case state of
            AddingDiscussionItems discussionItems ->
                addingDiscussionItemsView on discussionItems
        , Components.link Route.Dashboard [] "Back to dashboard"
        ]


init : String -> Model
init boardId =
    -- TODO: Add Loading state and fetch board here
    Model boardId <| AddingDiscussionItems []
