module Page.Board.Intro exposing (view)

import Components.Layout as Layout
import Element exposing (..)
import Element.Font as Font
import Team exposing (Team)
import UniqueID exposing (UniqueID)
import User


view : List UniqueID -> Element msg
view presentUserIds =
    let
        onlineUsers =
            []

        -- team
        --     |> Team.getMembers
        --     |> List.filter
        --         (\user ->
        --             List.member
        --                 (User.getId user)
        --                 presentUserIds
        --         )
        offlineUsers =
            []

        -- team
        --     |> Team.getMembers
        --     |> List.filter
        --         (\user ->
        --             not <|
        --                 List.member user onlineUsers
        --         )
    in
    column
        [ width fill
        , height fill
        , centerX
        , Layout.commonColumnSpacing
        ]
        [ paragraph
            [ width fill
            ]
            [ el [] <| text "Welcome to today's Retrospective!"
            ]
        , row
            [ width fill
            , spacing 60
            ]
            [ column
                [ alignTop
                , spacing 16
                ]
                ((el [ Font.bold ] <| text "Online:")
                    :: List.map
                        (\user ->
                            el [] <| text <| User.getName user
                        )
                        onlineUsers
                )
            , column
                [ alignTop
                , spacing 16
                ]
                ((el [ Font.bold ] <| text "Waiting for:")
                    :: List.map
                        (\user ->
                            el [] <| text <| User.getName user
                        )
                        offlineUsers
                )
            ]
        , column
            [ centerX
            , centerY
            , Layout.commonColumnSpacing
            ]
            [ el [ centerX ] <|
                image [ width <| px 340 ]
                    { src = "/img/absurd-hands.png"
                    , description = ""
                    }
            , paragraph
                [ Font.italic
                , width <| px 340
                ]
                [ el [] <| text "Remember: Everyone was doing their best with the information they had at the time."
                ]
            ]
        ]
