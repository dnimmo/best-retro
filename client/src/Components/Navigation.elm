module Components.Navigation exposing
    ( breadCrumb
    , iconLink
    , iconLinkWithText
    , textLink
    )

import Components.Colours as Colours
import Components.Icons as Icons
import Components.Transition as Transition
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
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
                        Route.AddTeamMembers teamId ->
                            [ enabledLink <|
                                Route.Team teamId
                            ]

                        _ ->
                            []
                   )
                ++ lastElement


textLink : String -> Route -> Element msg
textLink label route =
    link
        [ Font.color Colours.mediumBlue
        , mouseOver
            [ Font.color Colours.darkBlue
            ]
        , Transition.common [ "color" ]
        , Transition.duration 0.3
        ]
        { url = Route.toUrlString route
        , label = text label
        }


iconLinkElement : Maybe String -> Element msg -> Route -> Element msg
iconLinkElement maybeString icon route =
    link
        [ width fill
        , Font.color Colours.white
        , Border.color Colours.mediumBlue
        , mouseOver
            [ Font.color Colours.mediumBlue
            , Background.color Colours.white
            ]
        , Border.width 2
        , Border.rounded 5
        , padding 3
        , Transition.common [ "all" ]
        , Transition.duration 0.3
        , Background.color Colours.mediumBlue
        ]
        { url = Route.toUrlString route
        , label =
            row
                [ paddingXY 3 0
                , width fill
                ]
                [ icon, el [ centerX ] <| text (Maybe.withDefault "" maybeString) ]
        }


iconLink : Element msg -> Route -> Element msg
iconLink =
    iconLinkElement Nothing


iconLinkWithText : String -> Element msg -> Route -> Element msg
iconLinkWithText label =
    iconLinkElement (Just label)
