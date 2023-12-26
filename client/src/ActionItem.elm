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
    , notCompletedBefore
    , setComplete
    , setInProgress
    , setToDo
    , statusToString
    )

import Components.Icons as Icons
import Element exposing (Element)
import Time


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
        { id : String
        , author : String
        , assignee : String
        , date : Time.Posix
        , content : String
        , status : Status
        }


getId : ActionItem -> String
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


setComplete : String -> List ActionItem -> List ActionItem
setComplete itemId actions =
    actions
        |> List.map
            (\(ActionItem actionItem) ->
                if actionItem.id == itemId then
                    ActionItem
                        { actionItem
                            | status = Complete
                        }

                else
                    ActionItem actionItem
            )


setInProgress : String -> List ActionItem -> List ActionItem
setInProgress itemId actions =
    actions
        |> List.map
            (\(ActionItem actionItem) ->
                if actionItem.id == itemId then
                    ActionItem
                        { actionItem
                            | status = InProgress
                        }

                else
                    ActionItem actionItem
            )


setToDo : String -> List ActionItem -> List ActionItem
setToDo itemId actions =
    actions
        |> List.map
            (\(ActionItem actionItem) ->
                if actionItem.id == itemId then
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
        { id = "1"
        , author = "Dante"
        , assignee = "Dante"
        , date = Time.millisToPosix 0
        , content = "Chirp loudly"
        , status = ToDo
        }
    , ActionItem
        { id = "2"
        , author = "Dante"
        , assignee = "Dante"
        , date = Time.millisToPosix 0
        , content = "Be a handsome little man"
        , status = InProgress
        }
    , ActionItem
        { id = "3"
        , author = "Dante"
        , assignee = "Nimmo"
        , date = Time.millisToPosix 0
        , content = "Feed Dante"
        , status = Complete
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
