export function createOffscreenBitmapImpl(bmp) {
  let ret = new OffscreenCanvas(bmp.width, bmp.height);
  let ctx = ret.getContext("bitmaprenderer");
  ctx.transferFromImageBitmap(bmp);
  return ret;
}

export function cropImpl(source, rec) {
  return createImageBitmap(source, rec.x, rec.y, rec.width, rec.height);
}
