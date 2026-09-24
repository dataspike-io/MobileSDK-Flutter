import 'dart:typed_data';
import 'package:image/image.dart' as img;

class FaceLandmarksPreprocessor {
  static const int inputSize = 192;

  static Float32List preprocess(img.Image croppedFace) {
    // Resize cropped face to 256x256
    final resized = img.copyResize(
      croppedFace,
      width: inputSize,
      height: inputSize,
    );

    final input = Float32List(1 * inputSize * inputSize * 3);
    int index = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        input[index++] = pixel.r / 255.0;
        input[index++] = pixel.g / 255.0;
        input[index++] = pixel.b / 255.0;
      }
    }

    return input;
  }
}
