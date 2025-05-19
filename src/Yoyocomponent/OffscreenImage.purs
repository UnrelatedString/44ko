module Yoyocomponent.OffscreenImage (offscreenImage) where

import Prelude

import CSS as CSS
import Halogen as H
import Halogen.Component (EvalSpec)
import Halogen.HTML as HTML
import Halogen.HTML.CSS (style)
import Halogen.HTML.Events as Events
import Halogen.HTML.Properties as Prop
import Unsafe.Coerce (unsafeCoerce)
import Web.HTML (HTMLElement, HTMLImageElement)

type State =
  { url :: String
  , props :: Array _
  }

type Action = Unit

refLabel :: H.RefLabel
refLabel = H.RefLabel "oiRefLabel"

render
  :: forall m action
  . State
  -> H.ComponentHTML action () m
render { url, props } = HTML.img $ props <>
  [ style CSS.displayNone
  , Prop.src url
  , Events.onLoad (const unit)
  , 
  ]


toImageElement :: HTMLElement -> HTMLImageElement
toImageElement = unsafeCoerce
