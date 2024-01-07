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
    , getId
    , getLabel
    , isContinue
    , isStart
    , isStop
    , merge
    )

import Components.Label as Label
import Element exposing (Element)
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


getId : DiscussionItem -> UniqueID
getId (DiscussionItem { id }) =
    id


getContent : DiscussionItem -> String
getContent (DiscussionItem { content }) =
    content


isStart : DiscussionItem -> Bool
isStart (DiscussionItem { type_ }) =
    type_ == Start


isStop : DiscussionItem -> Bool
isStop (DiscussionItem { type_ }) =
    type_ == Stop


isContinue : DiscussionItem -> Bool
isContinue (DiscussionItem { type_ }) =
    type_ == Continue


getAllStartItems : List DiscussionItem -> List DiscussionItem
getAllStartItems items =
    List.filter isStart items


getAllStopItems : List DiscussionItem -> List DiscussionItem
getAllStopItems items =
    List.filter isStop items


getAllContinueItems : List DiscussionItem -> List DiscussionItem
getAllContinueItems items =
    List.filter isContinue items


getLabel : DiscussionItem -> Element msg
getLabel (DiscussionItem { type_ }) =
    case type_ of
        Start ->
            Label.startSmall

        Stop ->
            Label.stopSmall

        Continue ->
            Label.continueSmall


type alias CreateItemParams =
    { authorID : String -- TODO - make this a UniqueID
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


mergeTwo : DiscussionItem -> DiscussionItem -> DiscussionItem
mergeTwo (DiscussionItem item1) (DiscussionItem item2) =
    DiscussionItem
        { item2
            | content =
                item1.content
                    ++ " & "
                    ++ item2.content
        }


merge : List DiscussionItem -> DiscussionItem
merge items =
    List.foldl
        (\a b ->
            mergeTwo a b
        )
        (createStartItem
            { authorID = "John Doe"
            , content = ""
            , timestamp = Time.millisToPosix 0
            }
        )
        items



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
