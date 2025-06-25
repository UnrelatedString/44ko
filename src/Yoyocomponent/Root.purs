module Yoyocomponent.Root (root) where

import Prelude

import Halogen as H
import Halogen.HTML as HTML
import Halogen.HTML.Properties as Prop

root
  :: forall query input output m.
  H.Component query input output m

root = H.mkComponent
  { initialState
  , render
  , eval: H.mkEval H.defaultEval
  }

type State = Unit

initialState :: forall a. a -> Unit
initialState = const unit

render :: forall m action. State -> H.ComponentHTML action () m
render _ = HTML.div_
  [ HTML.h1_ [HTML.text "mentos cola!"]
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
