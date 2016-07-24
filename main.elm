import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import Task

main =
  App.program
    { init = init "cats"
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

-- MODEL

type alias Model =
  { topic : String
  , gifUrl : String
  , error : String
  }


init : String -> (Model, Cmd Msg)
init topic =
  ( Model topic "waiting.gif" ""
  , getRandomGif topic
  )

-- UPDATE

type Msg
  = MorePlease
  | FetchSucceed String
  | FetchFail Http.Error
  | ChangeTopic String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      (model, getRandomGif model.topic)

    FetchSucceed newUrl ->
      (Model model.topic newUrl "", Cmd.none)

    FetchFail oldUrl ->
      (Model model.topic "" "Sorry, failed, try again later. :(", Cmd.none)

    ChangeTopic newTopic ->
      (Model newTopic model.gifUrl model.error, Cmd.none)

-- VIEW


view : Model -> Html Msg
view model =
  div [pageStyle]
    [
    div [(backgroundStyleGenerator model.gifUrl)] [],
    div [controlsStyle] [
      span [] [
        input [ placeholder model.topic, onInput ChangeTopic, inputFieldStyle ] []
      , button [ onClick MorePlease, moreButtonStyle ] [ text "More Please!" ]
      ]
    ]
    , br [] []
    , img [gifStyle, src model.gifUrl] []
    , br [] []
    , h2 [] [text model.error]
    ]

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- HTTP


getRandomGif : String -> Cmd Msg
getRandomGif topic =
  let
    url =
      "http://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeGifUrl url)


decodeGifUrl : Json.Decoder String
decodeGifUrl =
  Json.at ["data", "image_url"] Json.string


-- CSS

pageStyle : Attribute msg
pageStyle =
  style
    [ ("width", "900px"),
      ("margin", "0 auto"),
      ("margin-top", "100px")
    ]

moreButtonStyle : Attribute msg
moreButtonStyle =
  style
      [ ("font-size", "20px")
      , ("font-family", "monospace")
      , ("display", "inline-block")
      , ("width", "200px")
      , ("text-align", "center")
      ]

inputFieldStyle : Attribute msg
inputFieldStyle =
  style
    [ ("font-size", "20px")
    , ("font-family", "monospace")
    , ("display", "inline-block")
    , ("width", "300px")
    , ("text-align", "center")
    ]

gifStyle : Attribute msg
gifStyle =
  style
    [ ("display", "block"),
      ("margin", "0 auto"),
      ("padding-top", "20px")
    ]

controlsStyle : Attribute  msg
controlsStyle =
  style
  [ ("margin", "auto"),
    ("display", "block"),
    ("text-align", "center")
  ]

backgroundStyleGenerator: String -> Attribute msg
backgroundStyleGenerator url =
  style
  [ ("position", "absolute"),
    ("top", "0"),
    ("bottom", "0"),
    ("left", "0"),
    ("right", "0"),
    ("background-image", "url('" ++ url ++  "')"),
    ("background-size", "cover"),
    ("opacity", "0.5"),
    ("z-index", "-1")
  ]
