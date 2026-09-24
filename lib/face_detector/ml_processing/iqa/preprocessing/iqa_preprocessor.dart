import 'dart:typed_data';
import 'package:image/image.dart' as img;

class IQAPreprocessor {
  static const int inputSize = 224;
  static const List<double> mean = [0.485, 0.456, 0.406];
  static const List<double> std = [0.229, 0.224, 0.225];

  static Float32List preprocess(img.Image face) {
    final resized = img.copyResize(face, width: inputSize, height: inputSize);
    final input = Float32List(1 * inputSize * inputSize * 3);
    int index = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        input[index++] = (pixel.r / 255.0 - mean[0]) / std[0];
        input[index++] = (pixel.g / 255.0 - mean[1]) / std[1];
        input[index++] = (pixel.b / 255.0 - mean[2]) / std[2];
      }
    }

    return input;
  }
}