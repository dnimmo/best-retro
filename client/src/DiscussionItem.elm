module DiscussionItem exposing
    ( DiscussionItem
    , devDiscussionItems
    , getAllContinueItems
    , getAllStartItems
    , getAllStopItems
    , getContent
    )

import Time


type ItemType
    = Start
    | Stop
    | Continue


type DiscussionItem
    = DiscussionItem
        { id : String
        , author : String
        , date : Time.Posix
        , content : String
        , type_ : ItemType
        }


getContent : DiscussionItem -> String
getContent (DiscussionItem { content }) =
    content


getAllStartItems : List DiscussionItem -> List DiscussionItem
getAllStartItems items =
    List.filter (\(DiscussionItem { type_ }) -> type_ == Start) items


getAllStopItems : List DiscussionItem -> List DiscussionItem
getAllStopItems items =
    List.filter (\(DiscussionItem { type_ }) -> type_ == Stop) items


getAllContinueItems : List DiscussionItem -> List DiscussionItem
getAllContinueItems items =
    List.filter (\(DiscussionItem { type_ }) -> type_ == Continue) items


devDiscussionItems : List DiscussionItem
devDiscussionItems =
    [ DiscussionItem
        { id = "1"
        , author = "John Doe"
        , date = Time.millisToPosix 0
        , content = "We should start using Elm"
        , type_ = Start
        }
    , DiscussionItem
        { id = "2"
        , author = "John Doe"
        , date = Time.millisToPosix 0
        , content = "We should high-five each other"
        , type_ = Start
        }
    , DiscussionItem
        { id = "3"
        , author = "John Doe"
        , date = Time.millisToPosix 0
        , content = "We should stop using TypeScript"
        , type_ = Stop
        }
    , DiscussionItem
        { id = "4"
        , author = "John Doe"
        , date = Time.millisToPosix 0
        , content = "We should stop not high-fiving each other"
        , type_ = Stop
        }
    , DiscussionItem
        { id = "5"
        , author = "John Doe"
        , date = Time.millisToPosix 0
        , content = "We should continue being awesome"
        , type_ = Continue
        }
    ]
