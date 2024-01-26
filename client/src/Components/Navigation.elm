module Components.Navigation exposing (breadCrumb)

import Components.Colours as Colours
import Components.Icons as Icons
import Element exposing (..)
import Element.Font as Font
import Route exposing (Route)


breadCrumbLink : Route -> Element msg
breadCrumbLink route =
    row [ Font.color Colours.mediumBlue ]
        [ link []
            { url = Route.toUrlString route
            , label =
                el
                    []
                <|
                    Icons.fromRoute route
            }
        ]


breadCrumb : Route -> Element msg
breadCrumb route =
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
            breadCrumbLink Route.Dashboard
                :: (case route of
                        Route.Dashboard ->
                            []

                        Route.Team _ ->
                            [ breadCrumbLink Route.MyTeams
                            , breadCrumbLink route
                            ]

                        Route.AddTeamMembers teamId ->
                            [ breadCrumbLink Route.MyTeams
                            , breadCrumbLink (Route.Team teamId)
                            , breadCrumbLink route
                            ]

                        _ ->
                            [ breadCrumbLink route ]
                   )
