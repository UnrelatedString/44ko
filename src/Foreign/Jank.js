export function createOffscreenCanvasImpl(rec) {
  return OffscreenCanvas(rec.width, rec.height);
}

export function createImageBitmapImpl(source, rec) {
  return createImageBitmap(source, rec.x, rec.y, rec.width, rec.height);
}

export function drawImageImpl(canvas, source) {
  canvas.drawImage(source, 0, 0)
}
