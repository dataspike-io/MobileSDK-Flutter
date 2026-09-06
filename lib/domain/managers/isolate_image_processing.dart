import 'dart:typed_data';
import 'package:image/image.dart' as img;

// Camera Document specific
class CameraCropParams {
  final Uint8List imageBytes;
  final double containerW;
  final double containerH;
  final double previewW;
  final double previewH;
  final double screenW;
  final double screenH;
  final bool isVertical;
  final int jpegQuality;

  const CameraCropParams({
    required this.imageBytes,
    required this.containerW,
    required this.containerH,
    required this.previewW,
    required this.previewH,
    required this.screenW,
    required this.screenH,
    required this.isVertical,
    this.jpegQuality = 85,
  });
}

Future<Uint8List> processCameraShotInIsolate(CameraCropParams p) async {
  img.Image? original = img.decodeImage(p.imageBytes);
  if (original == null) {
    throw StateError('Unable to decode image');
  }

  original = img.bakeOrientation(original);

  final imgW = original.width.toDouble();
  final imgH = original.height.toDouble();

  final previewAR = p.previewH / p.previewW;
  final containerAR = p.containerW / p.containerH;
  final coverScale = previewAR / containerAR;

  double childW, childH;
  if (containerAR > previewAR) {
    childH = p.containerH;
    childW = childH * previewAR;
  } else {
    childW = p.containerW;
    childH = childW / previewAR;
  }

  final displayW = childW * coverScale;
  final displayH = childH * coverScale;

  final offsetX = (p.containerW - displayW) / 2.0;
  final offsetY = (p.containerH - displayH) / 2.0;

  final cropWidthFactor = p.isVertical ? 0.6 : 0.85;
  final cropHeightFactor = p.isVertical ? 0.5 : 0.3;

  final cropW = p.screenW * cropWidthFactor;
  final cropH = p.screenH * cropHeightFactor;
  final cropLeftInWidget = (p.containerW - cropW) / 2.0;
  final cropTopInWidget = (p.containerH - cropH) / 2.0;

  final scale = displayW / imgW;

  int x = (((cropLeftInWidget - offsetX) / scale).round()).clamp(
    0,
    imgW.toInt() - 1,
  );
  int y = (((cropTopInWidget - offsetY) / scale).round()).clamp(
    0,
    imgH.toInt() - 1,
  );
  int w = ((cropW / scale).round()).clamp(1, imgW.toInt() - x);
  int h = ((cropH / scale).round()).clamp(1, imgH.toInt() - y);

  final cropped = img.copyCrop(original, x: x, y: y, width: w, height: h);
  final out = img.encodeJpg(cropped, quality: p.jpegQuality);
  return Uint8List.fromList(out);
}

// Gallery Document specific
class GalleryProcessParams {
  final Uint8List imageBytes;

  const GalleryProcessParams({
    required this.imageBytes,
  });
}

Future<Uint8List> processGalleryImageInIsolate(GalleryProcessParams p) async {
  try {
    final decoded = img.decodeImage(p.imageBytes);
    if (decoded == null) {
      return p.imageBytes;
    }

    img.Image image = img.bakeOrientation(decoded);

    image = img.copyResize(image);

    final out = img.encodeJpg(image);
    return Uint8List.fromList(out);
  } catch (_) {
    return p.imageBytes;
  }
}

// Avatar specific
class AvatarCropParams {
  // Raw, already-oriented RGBA pixels — deliberately not a JPEG. The
  // shutter capture step hands off pixels directly instead of an encoded
  // JPEG so this function is the *only* place that encodes, instead of
  // decoding an already-encoded frame just to re-encode it after cropping.
  final Uint8List rgbaBytes;
  final int imageWidth;
  final int imageHeight;
  final double containerW;
  final double containerH;
  final double previewW;
  final double previewH;

  final double sideInsetPct;
  final double topApexPct;
  final double bottomApexFromBottomPct;
  final double strokeWidth;

  const AvatarCropParams({
    required this.rgbaBytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.containerW,
    required this.containerH,
    required this.previewW,
    required this.previewH,
    required this.sideInsetPct,
    required this.topApexPct,
    required this.bottomApexFromBottomPct,
    required this.strokeWidth,
  });
}

Future<Uint8List> processAvatarShotInIsolate(AvatarCropParams p) async {
  // No decodeImage/bakeOrientation here: these are raw pixels handed off
  // straight from the camera capture step (already correctly oriented),
  // not a JPEG with EXIF metadata to interpret.
  final img.Image original = img.Image.fromBytes(
    width: p.imageWidth,
    height: p.imageHeight,
    bytes: p.rgbaBytes.buffer,
    order: img.ChannelOrder.rgba,
  );

  final imgW = original.width.toDouble();
  final imgH = original.height.toDouble();

  final previewAR = p.previewH / p.previewW;
  final containerAR = p.containerW / p.containerH;
  final coverScale = previewAR / containerAR;

  double childW, childH;
  if (containerAR > previewAR) {
    childH = p.containerH;
    childW = childH * previewAR;
  } else {
    childW = p.containerW;
    childH = childW / previewAR;
  }

  final displayW = childW * coverScale;
  final displayH = childH * coverScale;
  final offsetX = (p.containerW - displayW) / 2.0;
  final offsetY = (p.containerH - displayH) / 2.0;

  final margin = p.strokeWidth / 2 + 0.5;
  final leftX = (p.containerW * p.sideInsetPct).clamp(margin, p.containerW - margin);
  final rightX = (p.containerW * (1 - p.sideInsetPct)).clamp(margin, p.containerW - margin);
  final topApexY = (p.containerH * p.topApexPct) + margin;
  final bottomApexY = (p.containerH * (1 - p.bottomApexFromBottomPct)) - margin;

  final cropLeft = leftX;
  final cropTop = topApexY;
  final cropW = (rightX - leftX);
  final cropH = (bottomApexY - topApexY);

  final scale = displayW / imgW;

  int x = (((cropLeft - offsetX) / scale).round()).clamp(0, imgW.toInt() - 1);
  int y = (((cropTop - offsetY) / scale).round()).clamp(0, imgH.toInt() - 1);
  int w = ((cropW / scale).round()).clamp(1, imgW.toInt() - x);
  int h = ((cropH / scale).round()).clamp(1, imgH.toInt() - y);

  final cropped = img.copyCrop(original, x: x, y: y, width: w, height: h);
  // 100 = essentially uncompressed JPEG; 90 is visually indistinguishable
  // for a liveness selfie but produces a meaningfully smaller file, which
  // is what actually goes over the wire in the upload request.
  final out = img.encodeJpg(cropped, quality: 90);
  return Uint8List.fromList(out);
}

Future<List<Uint8List>> processAvatarShotBatchInIsolate(
  List<AvatarCropParams> paramsList,
) async {
  final results = <Uint8List>[];
  for (final params in paramsList) {
    results.add(await processAvatarShotInIsolate(params));
  }
  return results;
}