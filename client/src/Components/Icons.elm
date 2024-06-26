module Components.Icons exposing (..)

import Color
import Element exposing (Element, html)
import Material.Icons as Icons
import Material.Icons.Types as IconTypes
import Route exposing (Route)


iconSize : Int
iconSize =
    30


smallIconSize : Int
smallIconSize =
    20


type Colour
    = Default
    | Inherit


defaultIconColour : IconTypes.Coloring
defaultIconColour =
    IconTypes.Color <| Color.rgb255 68 150 250


rightArrowInternal : Colour -> Element msg
rightArrowInternal colour =
    html <|
        Icons.keyboard_double_arrow_right iconSize <|
            case colour of
                Default ->
                    defaultIconColour

                Inherit ->
                    IconTypes.Inherit


rightArrow : Element msg
rightArrow =
    rightArrowInternal Inherit


home : Element msg
home =
    html <|
        Icons.home iconSize IconTypes.Inherit


addUser : Element msg
addUser =
    html <|
        Icons.person_add iconSize IconTypes.Inherit


start : Element msg
start =
    html <|
        Icons.flag 20 IconTypes.Inherit


stop : Element msg
stop =
    html <|
        Icons.front_hand 20 IconTypes.Inherit


continue : Element msg
continue =
    html <|
        Icons.restart_alt 20 IconTypes.Inherit


fromRoute : Route -> Element msg
fromRoute route =
    case route of
        Route.Dashboard ->
            home

        Route.AddTeamMembers _ ->
            addUser

        Route.Team _ ->
            group

        Route.MyTeams ->
            myTeams

        Route.CreateTeam ->
            createNewTeam

        Route.CreateBoard ->
            createNewTeam

        Route.Board _ ->
            board

        _ ->
            rightArrowInternal Inherit


add : Element msg
add =
    html <|
        Icons.add iconSize IconTypes.Inherit


clear : Element msg
clear =
    html <|
        Icons.clear iconSize IconTypes.Inherit


controls : Element msg
controls =
    html <|
        Icons.settings iconSize defaultIconColour


facilitator : Element msg
facilitator =
    html <|
        Icons.supervisor_account iconSize defaultIconColour


startSession : Element msg
startSession =
    html <|
        Icons.start smallIconSize IconTypes.Inherit


back : Element msg
back =
    html <|
        Icons.arrow_back smallIconSize IconTypes.Inherit


forward : Element msg
forward =
    html <|
        Icons.arrow_forward smallIconSize IconTypes.Inherit


status : Element msg
status =
    html <|
        Icons.info smallIconSize defaultIconColour


user : Element msg
user =
    html <|
        Icons.person smallIconSize defaultIconColour


inProgress : Element msg
inProgress =
    html <|
        Icons.hourglass_top smallIconSize defaultIconColour


completed : Element msg
completed =
    html <|
        Icons.check_circle smallIconSize defaultIconColour


completedLarge : Element msg
completedLarge =
    html <|
        Icons.check_circle iconSize defaultIconColour


toDo : Element msg
toDo =
    html <|
        Icons.not_started smallIconSize defaultIconColour


actionCompleted : Element msg
actionCompleted =
    html <|
        Icons.task_alt smallIconSize defaultIconColour


remove : Element msg
remove =
    html <|
        Icons.delete_forever smallIconSize IconTypes.Inherit


edit : Element msg
edit =
    html <|
        Icons.edit smallIconSize IconTypes.Inherit


check : Element msg
check =
    html <|
        Icons.check smallIconSize IconTypes.Inherit


combine2 : Element msg
combine2 =
    html <|
        Icons.filter_2 smallIconSize IconTypes.Inherit


combine3 : Element msg
combine3 =
    html <|
        Icons.filter_3 smallIconSize IconTypes.Inherit


combine4 : Element msg
combine4 =
    html <|
        Icons.filter_4 smallIconSize IconTypes.Inherit


combine5 : Element msg
combine5 =
    html <|
        Icons.filter_5 smallIconSize IconTypes.Inherit


combine6 : Element msg
combine6 =
    html <|
        Icons.filter_6 smallIconSize IconTypes.Inherit


combine7 : Element msg
combine7 =
    html <|
        Icons.filter_7 smallIconSize IconTypes.Inherit


combine8 : Element msg
combine8 =
    html <|
        Icons.filter_8 smallIconSize IconTypes.Inherit


combine9plus : Element msg
combine9plus =
    html <|
        Icons.filter_9_plus smallIconSize IconTypes.Inherit


upvote : Element msg
upvote =
    html <|
        Icons.thumb_up smallIconSize IconTypes.Inherit


downvote : Element msg
downvote =
    html <|
        Icons.thumb_down smallIconSize IconTypes.Inherit


discuss : Element msg
discuss =
    html <|
        Icons.forum iconSize IconTypes.Inherit


action : Element msg
action =
    html <|
        Icons.task smallIconSize IconTypes.Inherit


timer : Element msg
timer =
    html <|
        Icons.schedule smallIconSize IconTypes.Inherit


moreTime : Element msg
moreTime =
    html <|
        Icons.more_time smallIconSize IconTypes.Inherit


startTimer : Element msg
startTimer =
    html <|
        Icons.play_arrow smallIconSize IconTypes.Inherit


pauseTimer : Element msg
pauseTimer =
    html <|
        Icons.pause smallIconSize IconTypes.Inherit


addTime : Element msg
addTime =
    html <|
        Icons.add_alarm smallIconSize IconTypes.Inherit


group : Element msg
group =
    html <|
        Icons.groups iconSize IconTypes.Inherit


myTeams : Element msg
myTeams =
    html <|
        Icons.group_work iconSize IconTypes.Inherit


createNewTeam : Element msg
createNewTeam =
    html <|
        Icons.add_circle_outline iconSize IconTypes.Inherit


board : Element msg
board =
    html <|
        Icons.dashboard iconSize IconTypes.Inherit


breadCrumbArrow : Element msg
breadCrumbArrow =
    html <|
        Icons.arrow_forward smallIconSize IconTypes.Inherit


hourglass : Element msg
hourglass =
    html <|
        Icons.hourglass_top iconSize IconTypes.Inherit


succeeded : Element msg
succeeded =
    html <|
        Icons.check_circle iconSize IconTypes.Inherit


failed : Element msg
failed =
    html <|
        Icons.cancel iconSize IconTypes.Inherit


radioChecked : Element msg
radioChecked =
    html <|
        Icons.radio_button_checked iconSize IconTypes.Inherit


radioUnchecked : Element msg
radioUnchecked =
    html <|
        Icons.radio_button_unchecked iconSize IconTypes.Inherit


task : Element msg
task =
    html <|
        Icons.task iconSize IconTypes.Inherit


swap : Element msg
swap =
    html <|
        Icons.swap_horiz iconSize IconTypes.Inherit


view : Element msg
view =
    html <|
        Icons.visibility iconSize IconTypes.Inherit
