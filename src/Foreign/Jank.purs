module Foreign.Jank
  ( OffscreenCanvas
  , OffscreenCanvasContextType
  , offscreen2d
  , offscreenBitmap
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

newtype OffscreenCanvasContextType = OffscreenCanvasContextType String

offscreen2d :: OffscreenCanvasContextType
offscreen2d = OffscreenCanvasContextType "2d"

offscreenBitmap :: OffscreenCanvasContextType
offscreenBitmap = OffscreenCanvasContextType "bitmaprenderer"

foreign import data ImageBitmap :: Type

foreign import createOffscreenCanvasImpl
  :: E.EffectFn2
    { width :: Int, height :: Int }
    OffscreenCanvasContextType
    OffscreenCanvas

createOffscreenCanvas
  :: { width :: Int, height :: Int }
  -> OffscreenCanvasContextType
  -> Effect OffscreenCanvas
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

-- COULD do this with CSS
-- https://stackoverflow.com/a/26219379
-- but seems cleaner not to juggle URLs when it's
-- canvas stuff anyways

crop
  :: OffscreenCanvas
  -> { x :: Int, y :: Int, width :: Int, height :: Int }
  -> Aff ImageBitmap
crop = (<<<) toAffE <<< E.runEffectFn2 createImageBitmapImpl
