module Foreign.Jank
  ( OffscreenBitmap
  , createOffscreenBitmap
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

foreign import data OffscreenBitmap :: Type

foreign import data ImageBitmap :: Type

foreign import createOffscreenBitmapImpl
  :: E.EffectFn1
    { width :: Int, height :: Int }
    OffscreenBitmap

createOffscreenBitmap
  :: { width :: Int, height :: Int }
  -> Effect OffscreenBitmap
createOffscreenBitmap = E.runEffectFn1 createOffscreenBitmapImpl

foreign import drawImageImpl
  :: E.EffectFn2
    OffscreenBitmap
    HTMLImageElement
    Unit

drawImage :: OffscreenBitmap -> HTMLImageElement -> Effect Unit
drawImage = E.runEffectFn2 drawImageImpl

foreign import createImageBitmapImpl
  :: E.EffectFn2
    OffscreenBitmap
    { x :: Int, y :: Int, width :: Int, height :: Int }
    (Promise ImageBitmap)

-- COULD do this with CSS
-- https://stackoverflow.com/a/26219379
-- but seems cleaner not to juggle URLs when it's
-- Bitmap stuff anyways

crop
  :: OffscreenBitmap
  -> { x :: Int, y :: Int, width :: Int, height :: Int }
  -> Aff ImageBitmap
crop = (<<<) toAffE <<< E.runEffectFn2 createImageBitmapImpl
