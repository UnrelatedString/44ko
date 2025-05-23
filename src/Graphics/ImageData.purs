module Graphics.ImageData
  ( probeRow
  , probeCol
  , probeAll
  ) where

import Prelude

import Effect (Effect)
import Graphics.Canvas (ImageData)
import Foreign.Jank
  ( OffscreenBitmap
  , probe
  , getDimensions
  )

probeRow :: OffscreenBitmap -> Int -> Effect ImageData
probeRow bmp y = do
  { width } <- getDimensions bmp
  probe bmp { x: 0, y, width, height: 1 }

probeCol :: OffscreenBitmap -> Int -> Effect ImageData
probeCol bmp x = do
  { height } <- getDimensions bmp
  probe bmp { x, y: 0, width: 1, height }

probeAll :: OffscreenBitmap -> Effect ImageData
probeAll bmp = do
  { width, height } <- getDimensions bmp
  probe bmp { x: 0, y: 0, width, height }
