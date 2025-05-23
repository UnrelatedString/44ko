export function createOffscreenBitmapImpl(bmp) {
  let ret = new OffscreenCanvas(bmp.width, bmp.height);
  let ctx = ret.getContext("2d", {willReadFrequently: true}); // apparently you can't even getImageData the bitmap one
  ctx.drawImage(bmp, 0, 0);
  return ret;
}

export function tryCreateImageBitmap(blob) {
  return createImageBitmap(blob);
}

export function cropImpl(source, rec) {
  return createImageBitmap(source, rec.x, rec.y, rec.width, rec.height);
}

export function probeImpl(source, rec) {
  return source.getContext("2d").getImageData(
    rec.x,
    rec.y,
    rec.width,
    rec.height,
    { colorSpace: "srgb" }, // since colors package assumes srgb
  );
}
