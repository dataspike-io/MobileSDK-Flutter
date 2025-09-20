import 'dart:typed_data';
import 'package:image/image.dart' as img;

class CameraCropParams {
  final Uint8List imageBytes;
  final double containerW;
  final double containerH;
  final double previewW;
  final double previewH;
  final double screenW;
  final double screenH;
  final double cropWidthFactor;
  final double cropHeightFactor;
  final int jpegQuality;

  const CameraCropParams({
    required this.imageBytes,
    required this.containerW,
    required this.containerH,
    required this.previewW,
    required this.previewH,
    required this.screenW,
    required this.screenH,
    this.cropWidthFactor = 0.85,
    this.cropHeightFactor = 0.3,
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

  final cropW = p.screenW * p.cropWidthFactor;
  final cropH = p.screenH * p.cropHeightFactor;
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
