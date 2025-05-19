module Foreign.Jank
  ( OffscreenCanvas
  , ImageBitmap
  ) where

import Prelude

import Effect (Effect)
import Effect.Uncurried as E
import Control.Promise (Promise, toAffE)
import Web.File.Blob (Blob)

foreign import data OffscreenCanvas :: Type

foreign import data ImageBitmap :: Type

foreign import createOffscreenCanvasImpl
  :: E.EffectFn1
    { width :: Int, height :: Int }
    OffscreenCanvas

foreign import createImageBitmapImpl
  :: E.EffectFn2
    OffscreenCanvas
    { x :: Int, y :: Int, width :: Int, height :: Int }
    (Promise ImageBitmap)

