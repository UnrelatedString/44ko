module Yoyocomponent.Root (root) where

import DOM.HTML.Indexed.InputType as InputType
import Halogen as H
import Halogen.HTML as HTML
import Halogen.HTML.Events as Events
import Halogen.HTML.Properties as Prop

data Action = UrlInput String

type State =
  { inputUrl :: String
  }

root
  :: forall query input output m.
  H.Component query input output m
root = H.mkComponent
  { initialState
  , render
  , eval: H.mkEval H.defaultEval
  }

initialState :: forall a. a -> State
initialState _ =
  { inputUrl: ""
  }

render :: forall m. State -> H.ComponentHTML Action () m
render _ = HTML.div_
  [ HTML.h1_ [HTML.text "mentos cola!"]
  , HTML.input [Prop.type_ InputType.InputUrl, Events.onValueInput UrlInput]
  , HTML.p_
    [ HTML.text "this website, the 44ko manga reader, is free and open source software under the "
    , HTML.b_ [HTML.text "gnu affero general public license version 3.0 or later"]
    , HTML.text ". source code is available at "
    , HTML.a [Prop.href "https://github.com/UnrelatedString/44ko"]
      [ HTML.text "github.com/UnrelatedString/44ko"
      ]
    , HTML.text ", where bug reports and suggestions are also always welcome."
    ]
  ]
