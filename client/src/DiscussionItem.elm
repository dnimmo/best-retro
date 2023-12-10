module DiscussionItem exposing
    ( DiscussionItem
    , getAllContinueItems
    , getAllStartItems
    , getAllStopItems
    )

import Time


type ItemType
    = Start
    | Stop
    | Continue


type DiscussionItem
    = DiscussionItem
        { id : String
        , title : String
        , author : String
        , date : Time.Posix
        , content : String
        , type_ : ItemType
        }


getAllStartItems : List DiscussionItem -> List DiscussionItem
getAllStartItems items =
    List.filter (\(DiscussionItem { type_ }) -> type_ == Start) items


getAllStopItems : List DiscussionItem -> List DiscussionItem
getAllStopItems items =
    List.filter (\(DiscussionItem { type_ }) -> type_ == Stop) items


getAllContinueItems : List DiscussionItem -> List DiscussionItem
getAllContinueItems items =
    List.filter (\(DiscussionItem { type_ }) -> type_ == Continue) items
