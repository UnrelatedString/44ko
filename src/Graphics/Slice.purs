module Graphics.Slice 
  ( realizeSlices
  , basicHeadSlicer
  , hardcodedSlicer
  , hardcodedSlicer'
  ) where

import Prelude

import Control.Monad.Error.Class (class MonadThrow, liftMaybe)
import Control.Monad.Reader.Trans (ReaderT, ask, runReaderT)
import Data.Array as Array
import Data.Array.NonEmpty as NonEmptyArray
import Data.ArrayBuffer.Typed as ArrayBuffer
import Data.Foldable (class Foldable)
import Data.Ord (abs)
import Data.Traversable (class Traversable, traverse)
import Data.Tuple (Tuple(Tuple))
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
  , highlightRects
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

debugSlices
  :: forall m f
  . MonadAff m
  => Foldable f
  => ReaderT SlicerCtx m (f Rect)
  -> OffscreenBitmap
  -> m ImageBitmap
debugSlices slices offscreen = do
  { width, height } <- liftEffect $ getDimensions offscreen
  let ctx = { bmp: offscreen, parentSlice: { x: 0, y: 0, width, height } }
  rects <- runReaderT slices ctx
  liftAff $ highlightRects offscreen rects

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

type HardcodedLayout = Array Rect

utterBareMinimum = boundsToRect <$> neighbors [1350, 675, 0] <*> neighbors [0, 550, 979, 1410, 1938]
  where neighbors = Array.zip <*> Array.drop 1
        boundsToRect (Tuple x1 x2) (Tuple y1 y2) =
          { x: min x1 x2
          , y: min y1 y2
          , width: abs $ x1 - x2
          , height: abs $ y1 - y2
          }

-- just ignores parentSlice entirely since 1. it's not recursive and 2. improvements also probably won't be recursive
-- ...it. still should be recursive. but hardcode . just naively all eight for proof of concept please
hardcodedSlicer
  :: forall m
  . MonadAff m
  => MonadThrow Oopsie m
  => HardcodedLayout
  -> ReaderT SlicerCtx m (Array Rect)
hardcodedSlicer rects = do
  pure rects

hardcodedSlicer' = hardcodedSlicer utterBareMinimum