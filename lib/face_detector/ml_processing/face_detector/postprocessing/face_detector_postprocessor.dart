import 'dart:math';

class FaceDetectorPostprocessor {
  static const int inputSize = 256;
  static const double scoreThreshold = 0.5;
  static const double nmsThreshold = 0.3;

  // Generate anchor boxes for BlazeFace 128x128 model
  static List<List<double>> _generateAnchors() {
    final anchors = <List<double>>[];
    const strides = [16, 32];
    const anchorsPerStride = [2, 6];

    for (int i = 0; i < strides.length; i++) {
      final stride = strides[i];
      final gridSize = inputSize ~/ stride;
      final numAnchors = anchorsPerStride[i];

      for (int y = 0; y < gridSize; y++) {
        for (int x = 0; x < gridSize; x++) {
          for (int a = 0; a < numAnchors; a++) {
            anchors.add([(x + 0.5) / gridSize, (y + 0.5) / gridSize]);
          }
        }
      }
    }

    return anchors; // 896 anchors total
  }

  // Decode raw regressors using anchor boxes
  // regressors shape: [1, 896, 16]
  // Each regressor: [cx, cy, w, h, kp0x, kp0y, kp1x, kp1y, ... kp5x, kp5y]
  static List<Map<String, dynamic>> _decodeBoxes(
    List<List<double>> coords, // (896, 16) — без batch dim
    List<List<double>> anchors, // (896, 2)
    double scale,
  ) {
    final boxes = <Map<String, dynamic>>[];

    for (int i = 0; i < coords.length; i++) {
      final reg = coords[i]; // List<double> длиной 16
      final anchor = anchors[i]; // List<double> длиной 2

      final ap0 = anchor[0] * inputSize.toDouble();
      final ap1 = anchor[1] * inputSize.toDouble();

      final cx = (reg[0] + ap0) / scale;
      final cy = (reg[1] + ap1) / scale;
      final w = reg[2] / scale;
      final h = reg[3] / scale;

      final keypoints = <Map<String, double>>[];
      for (int k = 0; k < 6; k++) {
        keypoints.add({
          'x': (reg[4 + k * 2] + ap0) / scale,
          'y': (reg[4 + k * 2 + 1] + ap1) / scale,
        });
      }

      boxes.add({
        'xMin': cx - w / 2,
        'yMin': cy - h / 2,
        'xMax': cx + w / 2,
        'yMax': cy + h / 2,
        'keypoints': keypoints,
      });
    }

    return boxes;
  }

  // Sigmoid activation for raw scores
  static double _sigmoid(double x) => 1.0 / (1.0 + exp(-x));

  // Non-Maximum Suppression
  static List<int> _nms(List<Map<String, dynamic>> boxes, List<double> scores) {
    final indices = List<int>.generate(scores.length, (i) => i)
      ..sort((a, b) => scores[b].compareTo(scores[a]));

    final selected = <int>[];

    for (final i in indices) {
      if (scores[i] < scoreThreshold) break;

      bool keep = true;
      for (final j in selected) {
        if (_iou(boxes[i], boxes[j]) > nmsThreshold) {
          keep = false;
          break;
        }
      }
      if (keep) selected.add(i);
    }

    return selected;
  }

  // Intersection over Union
  static double _iou(Map<String, dynamic> a, Map<String, dynamic> b) {
    final xMin = max<double>(a['xMin'], b['xMin']);
    final yMin = max<double>(a['yMin'], b['yMin']);
    final xMax = min<double>(a['xMax'], b['xMax']);
    final yMax = min<double>(a['yMax'], b['yMax']);

    final intersection = max(0.0, xMax - xMin) * max(0.0, yMax - yMin);
    final aArea = (a['xMax'] - a['xMin']) * (a['yMax'] - a['yMin']);
    final bArea = (b['xMax'] - b['xMin']) * (b['yMax'] - b['yMin']);

    return intersection / (aArea + bArea - intersection);
  }

  // Main postprocess method
  // Returns list of detected faces with bounding boxes and keypoints
  static List<Map<String, dynamic>> postprocess(
    List<List<List<double>>> boxCoords1, // [1, 512, 16]
    List<List<List<double>>> boxCoords2, // [1, 384, 16]
    List<List<List<double>>> boxScores1, // [1, 512, 1]
    List<List<List<double>>> boxScores2, // [1, 384, 1]
    double scale,
  ) {
    final coords = [...boxCoords1[0], ...boxCoords2[0]]; // (896, 16)

    final rawScores = [
      ...boxScores1[0].map((s) => s[0]),
      ...boxScores2[0].map((s) => s[0]),
    ]; // (896,)

    final anchors = _generateAnchors();

    final boxes = _decodeBoxes(coords, anchors, scale);
    final scores = rawScores.map(_sigmoid).toList();
    final selectedIndices = _nms(boxes, scores);

    return selectedIndices
        .map(
          (i) => {
            'box': boxes[i],
            'score': scores[i],
            'keypoints': boxes[i]['keypoints'],
          },
        )
        .toList();
  }
}
