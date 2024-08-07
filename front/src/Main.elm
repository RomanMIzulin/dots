module Main exposing (main)

import Canvas exposing (..)
import Canvas.Settings exposing (..)
import Color -- elm install avh4/elm-color
import Html exposing (Html)
import Html.Attributes exposing (style)
import Canvas.Settings.Text exposing (font)

view : Html msg
view =
    let
        width = 500
        height = 500
    in
        Canvas.toHtml (width, height)
            [ style "border" "1px solid black" ]
            [text [font { size = 48, family = "sans-serif" }] (50,50) "hello",
             shapes [ fill Color.white ] [ rect (0, 0) width height ],
             renderSquare,
            shapes [ fill Color.white ][path (0,0) [Canvas.lineTo(100,150)] ]
            ]

renderSquare =
  shapes [ fill (Color.rgba 0 0 0 1) ]
      [ rect (0, 0) 100 100 ]

main = view
