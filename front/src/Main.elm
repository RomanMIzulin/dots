module Main exposing (Model, main)

import Color -- elm install avh4/elm-color
import Html exposing (Html,div)
import Html.Attributes exposing (style)
import Browser
import Html exposing (button)
import Html.Events exposing (onClick)
import Html exposing (text)
import List exposing (length)
import Html exposing (span)
import List exposing (foldl)
import List exposing (map)

type  Dot = Empty|Red|Blue

type alias Model = 
    {
     grid: List (List Dot),
     width: Int,
     lengnth: Int
    }

type Msg = 
    PlaceDot 


get_color dot =
    case dot of 
        Empty -> "white"
        Blue -> "blue"
        Red -> "red"

makeCircle : String -> Dot -> String -> Html Msg
makeCircle size dot margin =
    span
        [ style "width" size
        , style "height" size
        , style "background-color" (get_color dot)
        , style "border-radius" "50%"
        , style "border-block-style" "solid"
        , style "margin" margin
        , style "display" "inline-table"
        ]
        [span [onClick PlaceDot] [ text "."]]

-- INIT
init : Model
init = 
    {
        grid = List.repeat 10 (List.repeat 10 Empty),
        width = 10,
        lengnth = 10
    }

-- UPDATE
update: Msg -> Model -> Model
update msg model =
    case msg of
        PlaceDot -> model

-- VIEW

spanify: List Dot -> Html Msg
spanify row =
    div [] 
        (List.map (\r -> makeCircle "50px" Red "10px") row)
    
get_dots : List (List Dot) -> List (Html Msg)
get_dots grid =
    List.map spanify grid
view : Model -> Html Msg
view state =
    div [] (get_dots state.grid)

main : Program () Model Msg
main = 
    Browser.sandbox { init = init, update = update, view = view }
