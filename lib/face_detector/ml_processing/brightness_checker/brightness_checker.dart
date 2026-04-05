import 'package:image/image.dart' as img;

class BrightnessChecker {
  static const double brightThreshold = 230;
  static const double darkThreshold = 45;

  static Map<String, double> check(img.Image image) {
    int brightPixels = 0;
    int darkPixels = 0;
    int totalPixels = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final brightness = (pixel.r + pixel.g + pixel.b) / 3;

        if (brightness > brightThreshold) brightPixels++;
        if (brightness < darkThreshold) darkPixels++;
      }
    }

    return {
      'brightRatio': brightPixels / totalPixels,
      'darkRatio': darkPixels / totalPixels,
    };
  }

  // Check if image is too bright or too dark
  static bool isTooBright(Map<String, double> result, {double threshold = 0.3}) {
    return result['brightRatio']! > threshold;
  }

  static bool isTooDark(Map<String, double> result, {double threshold = 0.3}) {
    return result['darkRatio']! > threshold;
  }
}