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

  // Extract specific landmark groups for convenience
  static Map<String, dynamic> extractKeyGroups(
    List<Map<String, double>> landmarks,
  ) {
    return {
      // Eyes
      'rightEye': landmarks[33],
      'leftEye': landmarks[263],
      'rightEyeInner': landmarks[133],
      'leftEyeInner': landmarks[362],

      // Eye blink landmarks
      'rightEyeTop': landmarks[159],
      'rightEyeBottom': landmarks[145],
      'leftEyeTop': landmarks[386],
      'leftEyeBottom': landmarks[374],

      // Nose
      'noseTip': landmarks[1],
      'noseBottom': landmarks[2],

      // Mouth
      'mouthLeft': landmarks[61],
      'mouthRight': landmarks[291],
      'mouthTop': landmarks[13],
      'mouthBottom': landmarks[14],

      // Face contour
      'chin': landmarks[152],
      'foreHead': landmarks[10],
    };
  }

  static Map<String, bool> checkEyesClosed(
    List<Map<String, double>> landmarks, {
    double threshold = 0.030,
  }) {
    final rightHeight = (landmarks[159]['y']! - landmarks[145]['y']!).abs();
    final rightClosed = rightHeight < threshold;

    final leftHeight = (landmarks[386]['y']! - landmarks[374]['y']!).abs();
    final leftClosed = leftHeight < threshold;
    
    return {
      'leftEyeClosed': leftClosed,
      'rightEyeClosed': rightClosed,
      'bothEyesClosed': rightClosed && leftClosed,
    };
  }
}
