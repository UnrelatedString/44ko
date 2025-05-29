module Graphics.Slice 
  ( basicSlice
  ) where

import Prelude

import Control.Monad.Error.Class (class MonadThrow, liftMaybe)
import Data.Array.NonEmpty as NonEmptyArray
import Data.ArrayBuffer.Typed as ArrayBuffer
import Effect (Effect)
import Effect.Aff (class MonadAff)
import Effect.Class (liftEffect)
import Graphics.Canvas (ImageData, imageDataBuffer)

import Control.Oopsie (Oopsie(EmptyImage))
import Graphics.ImageData (probeCol)
import Foreign.Jank (OffscreenBitmap, crop, getDimensions)

basicSlice
  :: forall m
  . MonadAff m
  => MonadThrow Oopsie m
  => OffscreenBitmap -> m (Array ImageData)
basicSlice bmp = do
  channels <- liftEffect do
    { width } <- getDimensions bmp
    let half = width / 2
    -- don't overthink itttttt for this it literally does work to read the rgba channels individually
    median <- probeCol bmp half
    ArrayBuffer.toArray $ imageDataBuffer median
  channels' <- liftMaybe EmptyImage $ NonEmptyArray.fromArray channels
