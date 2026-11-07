import 'dart:math' as math;
import 'package:dataspikemobilesdk/face_detector/ml_processing/image/rgb_frame.dart';

/// Port of calculateIlluminationScores from the web pipeline
/// (face_pipeline_bundle.js; analyze_selfies.py has no illumination step):
/// the face crop is resized to ~100k pixels, a margin is dropped, and each
/// pixel's HSV value (max of R, G, B) is compared against the cut-offs.
class BrightnessChecker {
  static const int lightValue = 230;
  static const int darkValue = 45;
  static const double highIlluminationThreshold = 0.59;
  static const double lowIlluminationThreshold = 0.4;

  static Map<String, double> check(RgbFrame face) {
    const expectedPixels = 1e5;
    final ratio = math.sqrt(expectedPixels / (face.width * face.height));
    final rsw = math.max(1, (face.width * ratio).round());
    final rsh = math.max(1, (face.height * ratio).round());
    final resized = face.resize(rsw, rsh).rgb;

    const margin = 32;
    final x0 = math.min(margin, rsw ~/ 4);
    final y0 = math.min(margin, rsh ~/ 4);
    final x1 = math.max(x0 + 1, rsw - x0);
    final y1 = math.max(y0 + 1, rsh - y0);

    int light = 0;
    int dark = 0;
    int total = 0;
    for (int y = y0; y < y1 && y < rsh; y++) {
      for (int x = x0; x < x1 && x < rsw; x++) {
        final i = (y * rsw + x) * 3;
        final v = math.max(resized[i], math.max(resized[i + 1], resized[i + 2]));
        if (v >= lightValue) light++;
        if (v <= darkValue) dark++;
        total++;
      }
    }

    if (total == 0) return {'brightRatio': 0, 'darkRatio': 0};
    return {'brightRatio': light / total, 'darkRatio': dark / total};
  }

  static bool isTooBright(Map<String, double> result) =>
      result['brightRatio']! > highIlluminationThreshold;

  static bool isTooDark(Map<String, double> result) =>
      result['darkRatio']! > lowIlluminationThreshold;
}
