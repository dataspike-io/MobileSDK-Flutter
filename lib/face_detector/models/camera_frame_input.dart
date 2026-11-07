import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// A camera frame handed off to the face-analysis pipeline.
///
/// Three shapes are supported, all converted/decoded inside the pipeline
/// isolate so per-pixel work never blocks the UI isolate:
/// - [decoded]: an already-decoded RGB image (used by callers that already
///   did the decode themselves).
/// - raw YUV420 planes (Android) — converted to RGB and rotated -90°.
/// - raw BGRA bytes (iOS) — downsampled and converted to RGB, no rotation.
class CameraFrameInput {
  final img.Image? decoded;

  final Uint8List? yPlane;
  final Uint8List? uPlane;
  final Uint8List? vPlane;
  final Uint8List? bgraBytes;
  final int sensorWidth;
  final int sensorHeight;
  final int yRowStride;
  final int uvRowStride;
  final int uvPixelStride;
  final int bgraRowStride;
  final int step;

  /// Final width/height of the image that will reach the pipeline, i.e.
  /// after downsampling and (for Android) the -90° rotation.
  final int width;
  final int height;

  CameraFrameInput.decoded(img.Image image)
    : decoded = image,
      yPlane = null,
      uPlane = null,
      vPlane = null,
      bgraBytes = null,
      sensorWidth = 0,
      sensorHeight = 0,
      yRowStride = 0,
      uvRowStride = 0,
      uvPixelStride = 0,
      bgraRowStride = 0,
      step = 1,
      width = image.width,
      height = image.height;

  /// Raw YUV420 planes that will be converted to RGB and rotated -90°
  /// (portrait) inside the pipeline isolate.
  CameraFrameInput.yuv420Rotated90({
    required Uint8List yPlane,
    required Uint8List uPlane,
    required Uint8List vPlane,
    required this.sensorWidth,
    required this.sensorHeight,
    required this.yRowStride,
    required this.uvRowStride,
    required this.uvPixelStride,
    required this.step,
  }) : decoded = null,
       yPlane = yPlane,
       uPlane = uPlane,
       vPlane = vPlane,
       bgraBytes = null,
       bgraRowStride = 0,
       width = sensorHeight ~/ step,
       height = sensorWidth ~/ step;

  /// Raw BGRA bytes (single plane) that will be downsampled and converted
  /// to RGB inside the pipeline isolate. No rotation: iOS delivers already
  /// portrait-oriented frames.
  CameraFrameInput.bgraRaw({
    required Uint8List bgraBytes,
    required this.sensorWidth,
    required this.sensorHeight,
    required this.bgraRowStride,
    required this.step,
  }) : decoded = null,
       yPlane = null,
       uPlane = null,
       vPlane = null,
       yRowStride = 0,
       uvRowStride = 0,
       uvPixelStride = 0,
       bgraBytes = bgraBytes,
       width = sensorWidth ~/ step,
       height = sensorHeight ~/ step;
}
