import 'dart:math' as math;

class FaceLandmarksPostprocessor {
  // Parse raw output from face_landmarks_detector
  // Identity shape: [1, 1, 1, 1434] → 478 landmarks × 3 (x, y, z)
  // Identity_1 shape: [1, 1, 1, 1] → face presence score
  // Identity_2 shape: [1, 1] → detection score

  static Map<String, dynamic> postprocess(
    List<List<List<double>>> landmarks, // [1, 468, 3]
    List<double> scores,
  ) {
    final lms = <Map<String, double>>[];
    for (int i = 0; i < 468; i++) {
      lms.add({
        'x': landmarks[0][i][0],
        'y': landmarks[0][i][1],
        'z': landmarks[0][i][2],
      });
    }
    return {'landmarks': lms, 'facePresenceScore': scores[0]};
  }

  static const List<int> _leftEyeIdx = [362, 385, 387, 263, 373, 380];
  static const List<int> _rightEyeIdx = [33, 160, 158, 133, 153, 144];

  static Map<String, bool> checkEyesClosedFromPixels(
    List<List<double>> lmOrig, {
    double threshold = 0.2,
  }) {
    final leftEAR = _eyeAspectRatio(lmOrig, _leftEyeIdx);
    final rightEAR = _eyeAspectRatio(lmOrig, _rightEyeIdx);
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
}
