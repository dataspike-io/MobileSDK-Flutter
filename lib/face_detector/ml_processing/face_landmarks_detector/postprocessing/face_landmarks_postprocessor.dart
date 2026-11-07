import 'dart:math' as math;

class FaceLandmarksPostprocessor {
  // Parse raw output from face_landmarks_detector (v4, 256x256).
  // Port of run_landmarks (analyze_selfies.py).
  // Identity shape: [1, 1, 1, 1434] → 478 landmarks × 3 (x, y, z).
  //   All 478 are returned (the IQA crop uses them); head pose only reads
  //   the first 468 (face mesh, no iris).
  // Identity_1 shape: [1, 1, 1, 1] → face presence logit.
  static Map<String, dynamic> postprocess(
    List<double> raw, // flattened Identity, 1434 values
    double faceFlagLogit,
    int ldW,
    int ldH,
  ) {
    final numLandmarks = raw.length ~/ 3;

    double maxXY = double.negativeInfinity;
    for (int i = 0; i < numLandmarks; i++) {
      maxXY = math.max(maxXY, math.max(raw[i * 3], raw[i * 3 + 1]));
    }
    // v4 outputs pixel coordinates in the 256x256 crop.
    final normalize = maxXY > 1.5;

    final lms = <Map<String, double>>[];
    for (int i = 0; i < numLandmarks; i++) {
      final x = raw[i * 3];
      final y = raw[i * 3 + 1];
      final z = raw[i * 3 + 2];
      lms.add(
        normalize
            ? {'x': x / ldW, 'y': y / ldH, 'z': z / ldW}
            : {'x': x, 'y': y, 'z': z},
      );
    }

    final score = 1.0 / (1.0 + math.exp(-faceFlagLogit.clamp(-100.0, 100.0)));
    return {'landmarks': lms, 'facePresenceScore': score};
  }

  static const List<int> _leftEyeIdx = [362, 385, 387, 263, 373, 380];
  static const List<int> _rightEyeIdx = [33, 160, 158, 133, 153, 144];
  static const int _chinIdx = 152;
  static const List<int> _foreheadIdx = [10, 338, 107, 297, 336];

  static ({double left, double right}) eyeAspectRatios(
    List<List<double>> lmOrig,
  ) => (
    left: _eyeAspectRatio(lmOrig, _leftEyeIdx),
    right: _eyeAspectRatio(lmOrig, _rightEyeIdx),
  );

  // Production rule (analyze_selfies.py, EAR_THR): eyes count as closed
  // when the average EAR of both eyes drops below this.
  static const double earThreshold = 0.09;

  static Map<String, bool> checkEyesClosedFromPixels(
    List<List<double>> lmOrig, {
    double threshold = earThreshold,
  }) {
    final (left: leftEAR, right: rightEAR) = eyeAspectRatios(lmOrig);
    final avgEAR = (leftEAR + rightEAR) / 2.0;

    return {
      'leftEyeClosed': leftEAR < threshold,
      'rightEyeClosed': rightEAR < threshold,
      'bothEyesClosed': avgEAR < threshold,
    };
  }

  static double _eyeAspectRatio(List<List<double>> lm, List<int> idxs) {
    double dist(List<double> a, List<double> b) {
      final dx = a[0] - b[0];
      final dy = a[1] - b[1];
      return math.sqrt(dx * dx + dy * dy);
    }

    final p2p6 = dist(lm[idxs[1]], lm[idxs[5]]);
    final p3p5 = dist(lm[idxs[2]], lm[idxs[4]]);
    final p1p4 = dist(lm[idxs[0]], lm[idxs[3]]);

    return (p2p6 + p3p5) / (2.0 * p1p4 + 1e-6);
  }

  // Port of is_chin_visible (analyze_selfies.py).
  static bool isChinVisible(
    List<List<double>> lmOrig,
    double imgW,
    double imgH,
    Map<String, dynamic> box,
  ) {
    final x = lmOrig[_chinIdx][0];
    final y = lmOrig[_chinIdx][1];
    if (x < 0 || x >= imgW || y < 0 || y >= imgH) return false;
    final y2 = box['yMax'] as double;
    return y2 < imgH * 0.97;
  }

  // Port of is_forehead_visible (analyze_selfies.py).
  static bool isForeheadVisible(
    List<List<double>> lmOrig,
    double imgW,
    double imgH,
  ) {
    for (final idx in _foreheadIdx) {
      final x = lmOrig[idx][0];
      final y = lmOrig[idx][1];
      if (x < 0 || x >= imgW || y < 0 || y >= imgH) return false;
    }
    return true;
  }

}
