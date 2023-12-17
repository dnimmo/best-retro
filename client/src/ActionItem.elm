module ActionItem exposing
    ( ActionItem
    , Status
    , devActionItems
    , getAssignee
    , getContent
    , getIncomplete
    , getStatus
    , statusToString
    )

import Time


type Status
    = ToDo
    | InProgress
    | Complete


type ActionItem
    = ActionItem
        { id : String
        , author : String
        , assignee : String
        , date : Time.Posix
        , content : String
        , status : Status
        }


getIncomplete : List ActionItem -> List ActionItem
getIncomplete =
    List.filter
        (\(ActionItem { status }) ->
            status /= Complete
        )


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
    ]
