module Graphics.Slice 
  ( basicSlice
  ) where

import Prelude

import Data.ArrayBuffer.Typed as AB
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Graphics.Canvas (ImageData, imageDataBuffer)
import Graphics.ImageData (probeCol)
import Foreign.Jank (OffscreenBitmap, crop, getDimensions)

basicSlice :: OffscreenBitmap -> Aff (Array ImageData)
basicSlice bmp = _ =<< liftEffect do
  { width } <- getDimensions bmp
  let half = width / 2
  -- don't overthink itttttt for this it literally does work to read the rgba channels individually
  median <- probeCol bmp half
  black <- AB.foldl min 1 $ imageDataBuffer $ median
