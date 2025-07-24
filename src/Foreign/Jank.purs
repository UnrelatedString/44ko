module Foreign.Jank
  ( OffscreenBitmap
  , Rect
  , midpoint
  , blobToOffscreen
  , getDimensions
  , ImageBitmap
  , crop
  , probe
  , highlightRects
  ) where

import Prelude

import Control.Monad.Error.Class (try)
import Control.Promise (Promise, toAffE)
import Data.Either (Either)
import Data.Traversable (class Traversable, traverse, for_)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Exception (Error)
import Effect.Uncurried as E
import Graphics.Canvas (getCanvasDimensions, ImageData)
import Graphics.Canvas as Cans
import Unsafe.Coerce (unsafeCoerce)
import Web.File.Blob (Blob)

foreign import data OffscreenBitmap :: Type

foreign import data ImageBitmap :: Type

type Rect = { x :: Int, y :: Int, width :: Int, height :: Int }

midpoint :: Rect -> { x :: Int, y :: Int }
midpoint { x, y, width, height } =
  { x: x + (width / 2)
  , y: y + (height / 2)
  }

-- I don't think I have to worry about ownership transfer stuff
-- since I'm not using workers? I hope not :|

-- ... also I hope Aff fibers can handle the background computation type stuff
-- well enough without workers LMAO

foreign import createOffscreenBitmapImpl :: E.EffectFn1 ImageBitmap OffscreenBitmap

createOffscreenBitmap :: ImageBitmap -> Effect OffscreenBitmap
createOffscreenBitmap = E.runEffectFn1 createOffscreenBitmapImpl

getDimensions :: OffscreenBitmap -> Effect { width :: Int, height :: Int }
getDimensions = unsafeCoerce getCanvasDimensions -- lmao.

foreign import tryCreateImageBitmap :: E.EffectFn1 Blob (Promise ImageBitmap)

blobToOffscreen :: Blob -> Aff (Either Error OffscreenBitmap)
blobToOffscreen blob = do
  result <- try $ toAffE $ E.runEffectFn1 tryCreateImageBitmap blob
  traverse (liftEffect <<< createOffscreenBitmap) result

foreign import cropImpl
  :: E.EffectFn2
    OffscreenBitmap
    Rect
    (Promise ImageBitmap)

-- COULD do this with CSS
-- https://stackoverflow.com/a/26219379
-- but seems cleaner not to juggle URLs when it's
-- Bitmap stuff anyways

crop
  :: OffscreenBitmap
  -> Rect
  -> Aff ImageBitmap
crop = (<<<) toAffE <<< E.runEffectFn2 cropImpl

-- because the binding in Graphics.Canvas is just kinda icky lol
-- (and like kinda would need to be unsafeCoerced to OffscreenCanvas anyways)
foreign import probeImpl :: E.EffectFn2 OffscreenBitmap Rect ImageData

probe :: OffscreenBitmap -> Rect -> Effect ImageData
probe = E.runEffectFn2 probeImpl

-- i really do not want to expose bullshit this stateful to the rest of my code lol
outsideRects
  :: forall f a.
  . Traversable f
  => Cans.Context2D
  -> f Rect
  -> (Cans.Context2D -> Effect a)
  -> Effect a
outsideRects ctx rects op = Cans.withContext ctx do
  -- Draw a rectangle around the whole canvas... ccw
  -- or do I actually need to do this if I use evenodd? eh whatever it can't *hurt*
  { width, height } <- Cans.getCanvasDimensions
  Cans.beginPath ctx
  Cans.moveTo ctx 0.0 0.0
  Cans.lineTo ctx 0.0 height
  Cans.lineTo ctx width height
  Cans.lineTo ctx width 0.0
  Cans.closePath ctx

  -- Draw the other rectangles clockwise like normal
  for_ rects $ Cans.rect ctx <<< unsafeCoerce -- i hate this library so much

  -- Set the clipping path?
  Cans.clip ctx

  -- Do the other thing and return its result
  op

highlightRects
  :: forall f.
  . Traversable f
  => OffscreenBitmap
  -> f Rect
  -> Effect OffscreenBitmap
highlightRects bmp rects =  >>= \ctx-> outsideRectangles ctx rects do
  { width, height } <- Cans.getCanvasDimensions
  -- ...okay there are some very cursed global compositing styles but I'm just going to
  --
  -- not
  -- do that
  Cans.setFillStyle ctx "#44222266" -- does it support alpha?????????
  Cans.fillRect ctx { x: 0.0, y: 0.0, width, height }
