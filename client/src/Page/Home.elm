module Page.Home exposing (view)

import Components exposing (edges, landingComponent, linkAsPrimaryButton, linkAsSecondaryButton, titleFontHeading)
import Components.Layout exposing (Layout)
import Element exposing (..)
import Route


view : Layout -> Element msg
view layout =
    landingComponent layout 0 <|
        column
            [ spacing 20
            , width fill
            , height fill
            ]
            [ titleFontHeading "BestRetro.app"
            , paragraph
                [ paddingEach { edges | top = 40 }
                ]
                [ el [] <| text "No matter how well your team is working, you can do better."
                ]
            , paragraph
                []
                [ el [] <| text "Use this app to run sessions for your team so that you can work out what and how to improve, together."
                ]
            , el
                [ width fill
                , height fill
                ]
              <|
                column
                    [ alignBottom
                    , width fill
                    , spacing 20
                    ]
                    [ row
                        [ width fill
                        , spacing 20
                        ]
                        [ linkAsPrimaryButton Route.CreateAccount "Sign up"
                        , linkAsSecondaryButton Route.SignIn "Log in"
                        ]

                    -- , linkAsSecondaryButton Route.Demo "How do sessions work?"
                    ]
            ]
