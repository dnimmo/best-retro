module Components.Navigation exposing (breadCrumb)

import Components.Colours as Colours
import Components.Icons as Icons
import Components.Transition as Transition
import Element exposing (..)
import Element.Font as Font
import Route exposing (Route)


breadCrumbLink : { enabled : Bool } -> Route -> Element msg
breadCrumbLink { enabled } route =
    let
        icon colour =
            el
                [ Font.color colour
                ]
            <|
                Icons.fromRoute route
    in
    if enabled then
        link
            [ mouseOver
                [ Font.color Colours.darkBlue
                ]
            , Transition.common [ "color" ]
            , Transition.duration 0.3
            ]
            { url = Route.toUrlString route
            , label = icon Colours.mediumBlue
            }

    else
        icon Colours.darkBlue


breadCrumb : Route -> Element msg
breadCrumb route =
    let
        enabledLink =
            breadCrumbLink { enabled = True }

        disabledLink =
            breadCrumbLink { enabled = False }

        isTopLevel =
            route
                == Route.Dashboard
                || route
                == Route.Home

        lastElement =
            if isTopLevel then
                []

            else
                [ disabledLink
                    route
                ]
    in
    row
        [ Font.color Colours.mediumBlue
        , spacing 5
        ]
    <|
        List.intersperse
            (el
                [ Font.color Colours.darkBlue ]
                Icons.breadCrumbArrow
            )
        <|
            (if isTopLevel then
                disabledLink

             else
                enabledLink
            )
                Route.Dashboard
                :: (case route of
                        Route.Team _ ->
                            [ enabledLink Route.MyTeams
                            ]

                        Route.AddTeamMembers teamId ->
                            [ enabledLink Route.MyTeams
                            , enabledLink <|
                                Route.Team teamId
                            ]

                        _ ->
                            []
                   )
                ++ lastElement
