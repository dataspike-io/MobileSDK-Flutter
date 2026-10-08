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

typedef AvatarCropRect = ({int x, int y, int w, int h});

/// Pixel rect of the avatar mask inside an oriented camera frame — exactly
/// the area that gets uploaded. Shared by the upload crop and the live face
/// analysis so both look at the same pixels.
///
/// The mask (oval, arcs, outside blur) is painted inside the preview's own
/// AspectRatio box, which camera_view.dart then cover-scales to fill the
/// container. So in frame pixels the mask is the same fraction of the frame
/// as of that box; only the stroke margin depends on the box's size.
AvatarCropRect avatarCropRect({
  required int imageWidth,
  required int imageHeight,
  required double containerW,
  required double containerH,
  required double previewW,
  required double previewH,
  required double sideInsetPct,
  required double topApexPct,
  required double bottomApexFromBottomPct,
  required double strokeWidth,
}) {
  // Size of the AspectRatio(previewAR) box laid out inside the container,
  // before the cover scale is applied.
  final previewAR = previewH / previewW;
  final containerAR = containerW / containerH;
  final double boxW, boxH;
  if (containerAR > previewAR) {
    boxH = containerH;
    boxW = boxH * previewAR;
  } else {
    boxW = containerW;
    boxH = boxW / previewAR;
  }

  // Same geometry as FaceOvalOutsideClipper / TwoArcsPainter.
  final margin = strokeWidth / 2 + 0.5;
  final leftX = (boxW * sideInsetPct).clamp(margin, boxW - margin);
  final rightX = (boxW * (1 - sideInsetPct)).clamp(margin, boxW - margin);
  final topApexY = (boxH * topApexPct) + margin;
  final bottomApexY = (boxH * (1 - bottomApexFromBottomPct)) - margin;

  final scaleX = imageWidth / boxW;
  final scaleY = imageHeight / boxH;

  final x = (leftX * scaleX).round().clamp(0, imageWidth - 1);
  final y = (topApexY * scaleY).round().clamp(0, imageHeight - 1);
  final w = ((rightX - leftX) * scaleX).round().clamp(1, imageWidth - x);
  final h = ((bottomApexY - topApexY) * scaleY).round().clamp(
    1,
    imageHeight - y,
  );
  return (x: x, y: y, w: w, h: h);
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

  final rect = avatarCropRect(
    imageWidth: original.width,
    imageHeight: original.height,
    containerW: p.containerW,
    containerH: p.containerH,
    previewW: p.previewW,
    previewH: p.previewH,
    sideInsetPct: p.sideInsetPct,
    topApexPct: p.topApexPct,
    bottomApexFromBottomPct: p.bottomApexFromBottomPct,
    strokeWidth: p.strokeWidth,
  );

  final cropped = img.copyCrop(
    original,
    x: rect.x,
    y: rect.y,
    width: rect.w,
    height: rect.h,
  );
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