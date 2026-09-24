import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math' as math;

class FaceDetectorPreprocessor {
  static const int inputSize = 256;

  static Float32List preprocess(img.Image inputImage) {
    final origH = inputImage.height;
    final origW = inputImage.width;
    final scale = math.min(inputSize / origH, inputSize / origW);
    final rw = (origW * scale).toInt();
    final rh = (origH * scale).toInt();

    // Resize keeping aspect ratio
    final resized = img.copyResize(inputImage, width: rw, height: rh);

    // Create black canvas 256x256 and paste resized image
    final padded = img.Image(width: inputSize, height: inputSize);
    img.compositeImage(padded, resized, dstX: 0, dstY: 0);

    final input = Float32List(1 * inputSize * inputSize * 3);
    int index = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = padded.getPixel(x, y);
        input[index++] = pixel.r / 255.0;
        input[index++] = pixel.g / 255.0;
        input[index++] = pixel.b / 255.0;
      }
    }

    return input;
  }
}
