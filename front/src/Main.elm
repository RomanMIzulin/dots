module Main exposing (Model, main)

import Color -- elm install avh4/elm-color
import Html exposing (Html,div)
import Html.Attributes exposing (style)
import Browser
import Html exposing (button)
import Html.Events exposing (onClick)
import Html exposing (text)

type  Dot = Empty|Red|Blue

type alias Model = 
    {
     grid: List (List Dot),
     width: Int,
     lengnth: Int
    }

type Msg = 
    PlaceDot 

init : Model
init = 
    {
        grid = List.repeat 10 (List.repeat 10 Empty),
        width = 10,
        lengnth = 10
    }
makeCircle : String -> String -> String -> Html Msg
makeCircle size color margin =
    div
        [ style "width" size
        , style "height" size
        , style "background-color" color
        , style "border-radius" "50%"
        , style "margin" margin
        ]
        [button [onClick PlaceDot] [ text "PlaceDot"]]


update: Msg -> Model -> Model
update msg model =
    case msg of
        PlaceDot -> model
view : Model -> Html Msg
view state =
    div []
        [ makeCircle "100px" "red" "10px"
        , makeCircle "100px" "blue" "10px"
        , makeCircle "100px" "green" "10px"
        ]

main : Program () Model Msg
main = 
    Browser.sandbox { init = init, update = update, view = view }
