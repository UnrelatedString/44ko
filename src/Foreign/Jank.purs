module Foreign.Jank
  ( OffscreenBitmap
  , createOffscreenBitmap
  , ImageBitmap
  , crop
  ) where

import Prelude

import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Uncurried as E
import Control.Promise (Promise, toAffE)

foreign import data OffscreenBitmap :: Type

foreign import data ImageBitmap :: Type

-- I don't think I have to worry about ownership transfer stuff
-- since I'm not using workers? I hope not :|

foreign import createOffscreenBitmapImpl :: E.EffectFn1 ImageBitmap OffscreenBitmap

createOffscreenBitmap :: ImageBitmap -> Effect OffscreenBitmap
createOffscreenBitmap = E.runEffectFn1 createOffscreenBitmapImpl

foreign import cropImpl
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
crop = (<<<) toAffE <<< E.runEffectFn2 cropImpl
