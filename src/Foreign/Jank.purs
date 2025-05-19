module Foreign.Jank
  ( OffscreenCanvas
  , createOffscreenCanvas
  , drawImage
  , ImageBitmap
  , crop
  ) where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Uncurried as E
import Control.Promise (Promise, toAffE)
import Web.HTML (HTMLImageElement)

foreign import data OffscreenCanvas :: Type

foreign import data ImageBitmap :: Type

foreign import createOffscreenCanvasImpl
  :: E.EffectFn1
    { width :: Int, height :: Int }
    OffscreenCanvas

createOffscreenCanvas :: { width :: Int, height :: Int } -> Effect OffscreenCanvas
createOffscreenCanvas = E.runEffectFn1 createOffscreenCanvasImpl

foreign import drawImageImpl
  :: E.EffectFn2
    OffscreenCanvas
    HTMLImageElement
    Unit

drawImage :: OffscreenCanvas -> HTMLImageElement -> Effect Unit
drawImage = E.runEffectFn2 drawImageImpl

foreign import createImageBitmapImpl
  :: E.EffectFn2
    OffscreenCanvas
    { x :: Int, y :: Int, width :: Int, height :: Int }
    (Promise ImageBitmap)

crop
  :: OffscreenCanvas
  -> { x :: Int, y :: Int, width :: Int, height :: Int }
  -> Aff ImageBitmap
crop = (<<<) toAffE <<< E.runEffectFn2 createImageBitmapImpl
