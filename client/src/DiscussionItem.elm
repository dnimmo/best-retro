module DiscussionItem exposing
    ( DiscussionItem
    , createContinueItem
    , createStartItem
    , createStopItem
    , devDiscussionItems
    , getAllContinueItems
    , getAllStartItems
    , getAllStopItems
    , getContent
    )

import Time
import UniqueID exposing (UniqueID)


type ItemType
    = Start
    | Stop
    | Continue


type DiscussionItem
    = DiscussionItem
        { id : UniqueID
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


type alias CreateItemParams =
    { authorID : String
    , content : String
    , timestamp : Time.Posix
    }


createItem : ItemType -> CreateItemParams -> DiscussionItem
createItem type_ { authorID, content, timestamp } =
    DiscussionItem
        { id = UniqueID.generateID timestamp
        , author = authorID
        , date = Time.millisToPosix 0
        , content = content
        , type_ = type_
        }


createStartItem : CreateItemParams -> DiscussionItem
createStartItem =
    createItem Start


createStopItem : CreateItemParams -> DiscussionItem
createStopItem =
    createItem Stop


createContinueItem : CreateItemParams -> DiscussionItem
createContinueItem =
    createItem Continue



-- FOR DEVELOPMENT ONLY


devDiscussionItems : List DiscussionItem
devDiscussionItems =
    [ DiscussionItem
        { id = UniqueID.generateID (Time.millisToPosix 0)
        , author = "John Doe"
        , date = Time.millisToPosix 0
        , content = "We should start using Elm"
        , type_ = Start
        }
    , DiscussionItem
        { id = UniqueID.generateID (Time.millisToPosix 10)
        , author = "John Doe"
        , date = Time.millisToPosix 0
        , content = "We should high-five each other"
        , type_ = Start
        }
    , DiscussionItem
        { id = UniqueID.generateID (Time.millisToPosix 20)
        , author = "John Doe"
        , date = Time.millisToPosix 0
        , content = "We should stop using TypeScript"
        , type_ = Stop
        }
    , DiscussionItem
        { id = UniqueID.generateID (Time.millisToPosix 30)
        , author = "John Doe"
        , date = Time.millisToPosix 0
        , content = "We should stop not high-fiving each other"
        , type_ = Stop
        }
    , DiscussionItem
        { id = UniqueID.generateID (Time.millisToPosix 40)
        , author = "John Doe"
        , date = Time.millisToPosix 0
        , content = "We should continue being awesome"
        , type_ = Continue
        }
    ]
