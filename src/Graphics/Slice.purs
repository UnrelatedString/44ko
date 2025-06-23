module Graphics.Slice 
  ( realizeSlices
  , basicHeadSlicer
  ) where

import Prelude

import Control.Monad.Error.Class (class MonadThrow, liftMaybe)
import Control.Monad.Reader.Trans (ReaderT, ask, runReaderT)
import Data.Array.NonEmpty as NonEmptyArray
import Data.ArrayBuffer.Typed as ArrayBuffer
import Data.Traversable (class Traversable, traverse)
import Data.Semigroup.Foldable (minimum)
import Data.UInt as UInt
import Effect.Aff.Class (class MonadAff, liftAff)
import Effect.Class (liftEffect)
import Graphics.Canvas (imageDataBuffer)

import Control.Oopsie (Oopsie(EmptyImage))
import Graphics.ImageData (probeCol)
import Foreign.Jank
  ( OffscreenBitmap
  , ImageBitmap
  , Rect
  , midpoint
  , crop
  , getDimensions
  )

type SlicerCtx =
  { bmp :: OffscreenBitmap
  , parentSlice :: Rect
  }

realizeSlices
  :: forall m f
  . MonadAff m
  => Traversable f
  => ReaderT SlicerCtx m (f Rect)
  -> OffscreenBitmap
  -> m (f ImageBitmap)
realizeSlices slices offscreen = do
  { width, height } <- liftEffect $ getDimensions offscreen
  let ctx = { bmp: offscreen, parentSlice: { x: 0, y: 0, width, height } }
  flip runReaderT ctx $ slices >>= traverse \slice -> do
    { bmp } <- ask
    liftAff $ crop bmp slice

basicHeadSlicer
  :: forall m
  . MonadAff m
  => MonadThrow Oopsie m
  => ReaderT SlicerCtx m (Array Rect)
basicHeadSlicer = do
  { bmp, parentSlice } <- ask
  channels <- liftEffect do
    let { x: half } = midpoint parentSlice
    -- don't overthink itttttt for this it literally does work to read the rgba channels individually
    median <- probeCol bmp half
    uints <- ArrayBuffer.toArray (imageDataBuffer median)
    pure $ UInt.toInt <$> uints
  channels' <- liftMaybe EmptyImage $ NonEmptyArray.fromArray channels
  let dark = minimum channels'
  if dark < 100 then do
    -- just ignore it for nowwwwwww
    pure []
  else do
    pure []
