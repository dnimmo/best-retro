module ActionItem exposing
    ( ActionItem
    , Status
    , devActionItems
    , getAssignee
    , getContent
    , getIcon
    , getId
    , getIncomplete
    , getStatus
    , isComplete
    , isInProgress
    , new
    , notCompletedBefore
    , setComplete
    , setInProgress
    , setToDo
    , statusToString
    )

import Components.Icons as Icons
import DiscussionItem exposing (DiscussionItem)
import Element exposing (Element)
import Time
import UniqueID exposing (UniqueID)


type Status
    = ToDo
    | InProgress
    | Complete


getIcon : ActionItem -> Element msg
getIcon (ActionItem { status }) =
    case status of
        ToDo ->
            Icons.toDo

        InProgress ->
            Icons.inProgress

        Complete ->
            Icons.actionCompleted


type ActionItem
    = ActionItem
        { id : UniqueID
        , author : UniqueID
        , assignee : String
        , date : Time.Posix
        , content : String
        , status : Status
        , originalDiscussionItem : Maybe DiscussionItem
        }


getId : ActionItem -> UniqueID
getId (ActionItem { id }) =
    id


getIncomplete : List ActionItem -> List ActionItem
getIncomplete =
    List.filter
        (\(ActionItem { status }) ->
            status /= Complete
        )


isInProgress : ActionItem -> Bool
isInProgress (ActionItem { status }) =
    status == InProgress


isComplete : ActionItem -> Bool
isComplete (ActionItem { status }) =
    status == Complete


getContent : ActionItem -> String
getContent (ActionItem { content }) =
    content


getStatus : ActionItem -> Status
getStatus (ActionItem { status }) =
    status


getAssignee : ActionItem -> String
getAssignee (ActionItem { assignee }) =
    assignee


statusToString : Status -> String
statusToString status =
    case status of
        ToDo ->
            "To Do"

        InProgress ->
            "In Progress"

        Complete ->
            "Complete"


setComplete : UniqueID -> List ActionItem -> List ActionItem
setComplete itemId actions =
    actions
        |> List.map
            (\(ActionItem actionItem) ->
                if UniqueID.compare actionItem.id itemId then
                    ActionItem
                        { actionItem
                            | status = Complete
                        }

                else
                    ActionItem actionItem
            )


setInProgress : UniqueID -> List ActionItem -> List ActionItem
setInProgress itemId actions =
    actions
        |> List.map
            (\(ActionItem actionItem) ->
                if UniqueID.compare actionItem.id itemId then
                    ActionItem
                        { actionItem
                            | status = InProgress
                        }

                else
                    ActionItem actionItem
            )


setToDo : UniqueID -> List ActionItem -> List ActionItem
setToDo itemId actions =
    actions
        |> List.map
            (\(ActionItem actionItem) ->
                if UniqueID.compare actionItem.id itemId then
                    ActionItem
                        { actionItem
                            | status = ToDo
                        }

                else
                    ActionItem actionItem
            )


devActionItems : List ActionItem
devActionItems =
    [ ActionItem
        { id = UniqueID.generateID (Time.millisToPosix 1000)
        , author = UniqueID.generateDefaultID
        , assignee = "Dante"
        , date = Time.millisToPosix 0
        , content = "Chirp loudly"
        , status = ToDo
        , originalDiscussionItem = Nothing
        }
    , ActionItem
        { id = UniqueID.generateID (Time.millisToPosix 100)
        , author = UniqueID.generateDefaultID
        , assignee = "Dante"
        , date = Time.millisToPosix 0
        , content = "Be a handsome little man"
        , status = InProgress
        , originalDiscussionItem = Nothing
        }
    , ActionItem
        { id = UniqueID.generateID (Time.millisToPosix 10)
        , author = UniqueID.generateDefaultID
        , assignee = "Nimmo"
        , date = Time.millisToPosix 0
        , content = "Feed Dante"
        , status = Complete
        , originalDiscussionItem = Nothing
        }
    ]


notCompletedBefore : Time.Posix -> List ActionItem -> List ActionItem
notCompletedBefore posix =
    List.filter
        (\(ActionItem { date, status }) ->
            (Time.posixToMillis date
                >= Time.posixToMillis posix
            )
                || status
                /= Complete
        )


new :
    { description : String
    , now : Time.Posix
    , author : UniqueID
    , maybeDiscussionItem : Maybe DiscussionItem
    , assignee : String
    }
    -> ActionItem
new { description, now, author, maybeDiscussionItem, assignee } =
    ActionItem
        { id = UniqueID.generateID now
        , author = author
        , assignee = assignee
        , date = now
        , content = description
        , status = ToDo
        , originalDiscussionItem = maybeDiscussionItem
        }
