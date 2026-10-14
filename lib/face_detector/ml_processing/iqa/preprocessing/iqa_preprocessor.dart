import 'dart:typed_data';
import 'package:dataspikemobilesdk/face_detector/ml_processing/image/rgb_frame.dart';

/// Input for iqa_mobilenetv3small100_sigmoid (v3).
/// Port of iqa_score (analyze_selfies.py): cv2.resize to 224x224,
/// ImageNet mean/std normalization.
class IQAPreprocessor {
  static const int inputSize = 224;
  static const List<double> mean = [0.485, 0.456, 0.406];
  static const List<double> std = [0.229, 0.224, 0.225];

  static Float32List preprocess(RgbFrame face) {
    final pixels = face.resize(inputSize, inputSize).rgb;
    final input = Float32List(pixels.length);
    for (int i = 0; i < pixels.length; i += 3) {
      input[i] = (pixels[i] / 255.0 - mean[0]) / std[0];
      input[i + 1] = (pixels[i + 1] / 255.0 - mean[1]) / std[1];
      input[i + 2] = (pixels[i + 2] / 255.0 - mean[2]) / std[2];
    }
    return input;
  }
}
