module Yoyocomponent.Root (root) where

import Prelude

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
  where

  render
    :: forall state
    . state
    -> H.ComponentHTML Action () m
  render _ = HTML.div_
    [ HTML.input [Prop.type_ InputType.InputUrl, Events.onValueInput UrlInput]
    ]

initialState :: forall a. a -> Unit
initialState = const unit
