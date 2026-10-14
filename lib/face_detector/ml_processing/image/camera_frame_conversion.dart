import 'dart:typed_data';
import 'package:dataspikemobilesdk/face_detector/ml_processing/image/rgb_frame.dart';

// Single-pass camera frame -> RgbFrame conversions used by the pipeline
// isolate. They write straight into the final RGB buffer instead of going
// through img.Image (fromBytes channel remap, copyRotate, getBytes convert),
// which cost ~150 ms per frame on mid-range Android in debug builds.

/// Raw YUV420 planes (Android) -> RGB, downsampled by [step] and rotated
/// -90° to portrait. Pixel-identical to the former
/// `copyRotate(Image.fromBytes(yuv -> rgba), angle: -90)` chain.
RgbFrame yuv420ToRgbFrame({
  required Uint8List yPlane,
  required Uint8List uPlane,
  required Uint8List vPlane,
  required int sensorWidth,
  required int sensorHeight,
  required int yRowStride,
  required int uvRowStride,
  required int uvPixelStride,
  required int step,
}) {
  // Downsampled landscape size; the portrait output swaps the axes.
  final srcW = sensorWidth ~/ step;
  final srcH = sensorHeight ~/ step;
  final outW = srcH;
  final outH = srcW;

  final rgb = Uint8List(outW * outH * 3);
  int o = 0;
  for (int y = 0; y < outH; y++) {
    // Rotating by -90°: output (x, y) comes from landscape (srcW-1-y, x).
    final sx = (srcW - 1 - y) * step;
    for (int x = 0; x < outW; x++) {
      final sy = x * step;
      final yValue = yPlane[sy * yRowStride + sx] & 0xFF;
      final uvIndex = (sy ~/ 2) * uvRowStride + (sx ~/ 2) * uvPixelStride;
      final u = (uPlane[uvIndex] & 0xFF) - 128;
      final v = (vPlane[uvIndex] & 0xFF) - 128;
      rgb[o++] = (yValue + 1.402 * v).clamp(0, 255).toInt();
      rgb[o++] = (yValue - 0.344136 * u - 0.714136 * v).clamp(0, 255).toInt();
      rgb[o++] = (yValue + 1.772 * u).clamp(0, 255).toInt();
    }
  }
  return RgbFrame(rgb, outW, outH);
}

/// Raw BGRA bytes (iOS, already portrait) -> RGB, downsampled by [step].
RgbFrame bgraToRgbFrame({
  required Uint8List bgraBytes,
  required int sensorWidth,
  required int sensorHeight,
  required int bgraRowStride,
  required int step,
}) {
  final outW = sensorWidth ~/ step;
  final outH = sensorHeight ~/ step;

  final rgb = Uint8List(outW * outH * 3);
  int o = 0;
  for (int dy = 0; dy < outH; dy++) {
    final srcRowOffset = (dy * step) * bgraRowStride;
    for (int dx = 0; dx < outW; dx++) {
      final i = srcRowOffset + (dx * step) * 4;
      rgb[o++] = bgraBytes[i + 2];
      rgb[o++] = bgraBytes[i + 1];
      rgb[o++] = bgraBytes[i];
    }
  }
  return RgbFrame(rgb, outW, outH);
}
