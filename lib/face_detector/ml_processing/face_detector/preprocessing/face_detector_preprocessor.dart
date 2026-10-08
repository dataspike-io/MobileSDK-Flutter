import 'dart:typed_data';
import 'dart:math' as math;
import 'package:dataspikemobilesdk/face_detector/ml_processing/image/rgb_frame.dart';

/// Letterbox + normalization for BlazeFace short-range (128x128, v4).
/// Port of detect_faces (analyze_selfies.py): cv2.warpAffine with an
/// exact float center offset, zero border, then x / 127.5 - 1.
class FaceDetectorPreprocessor {
  static const int inputSize = 128;

  static Float32List preprocess(RgbFrame frame) {
    final scale = math.min(inputSize / frame.height, inputSize / frame.width);
    final xOff = (inputSize - frame.width * scale) / 2;
    final yOff = (inputSize - frame.height * scale) / 2;

    // Inverse of [[scale, 0, xOff], [0, scale, yOff]].
    final pixels = frame.warpAffine(
      [
        [1 / scale, 0.0, -xOff / scale],
        [0.0, 1 / scale, -yOff / scale],
      ],
      inputSize,
      inputSize,
      replicateBorder: false,
    );

    final input = Float32List(pixels.length);
    for (int i = 0; i < pixels.length; i++) {
      input[i] = pixels[i] / 127.5 - 1.0;
    }
    return input;
  }
}
