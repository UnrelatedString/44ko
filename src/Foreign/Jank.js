export function createOffscreenBitmapImpl(rec) {
  let ret = OffscreenCanvas(rec.width, rec.height);
  let ctx = ret.getContext("bitmaprenderer");
  
}

export function createImageBitmapImpl(source, rec) {
  return createImageBitmap(source, rec.x, rec.y, rec.width, rec.height);
}

export function drawImageImpl(canvas, source) {
  canvas.drawImage(source, 0, 0)
}
