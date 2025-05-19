module Yoyocomponent.OffscreenImage (offscreenImage) where

import Prelude

import CSS as CSS
import Data.Traversable (for_)
import Effect.Class (class MonadEffect)
import Halogen as H
import Halogen.HTML as HTML
import Halogen.HTML.CSS (style)
import Halogen.HTML.Events as Events
import Halogen.HTML.Properties as Prop
import Unsafe.Coerce (unsafeCoerce)
import Web.HTML (HTMLElement, HTMLImageElement)
import Web.HTML.HTMLImageElement as ImageElement

import Foreign.Jank (OffscreenCanvas, createOffscreenCanvas, drawImage)

type State =
  { url :: String
  }

data Action = HasDimensions

type Output = OffscreenCanvas

offscreenImage
  :: forall query m
  . MonadEffect m
  => H.Component query State Output m
offscreenImage = H.mkComponent
  { initialState: identity
  , render
  , eval: H.mkEval H.defaultEval
    { handleAction = handleAction
    }
  }
  where

  refLabel :: H.RefLabel
  refLabel = H.RefLabel "oiRefLabel"

  render
    :: State
    -> H.ComponentHTML Action () m
  render { url } = HTML.img
    [ style $ CSS.display CSS.displayNone
    , Prop.src url
    , Events.onLoad (const HasDimensions)
    , Prop.ref refLabel
    ]

  handleAction
    :: Action
    -> H.HalogenM State Action () Output m Unit
  handleAction HasDimensions = do
    maybeElem <- H.getHTMLElementRef refLabel
    for_ maybeElem \elem -> H.raise =<< H.liftEffect do
      let img = toImageElement elem
      width <- ImageElement.width img
      height <- ImageElement.height img
      offscreen <- createOffscreenCanvas { width, height }
      drawImage offscreen img
      pure offscreen

toImageElement :: HTMLElement -> HTMLImageElement
toImageElement = unsafeCoerce
