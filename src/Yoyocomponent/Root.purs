module Yoyocomponent.Root (root) where

import Prelude

import Halogen as H
import Halogen.HTML as HTML

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
    :: forall state action
    . state
    -> H.ComponentHTML action () m
  render _ = HTML.div_ []

initialState :: forall a. a -> Unit
initialState = const unit
