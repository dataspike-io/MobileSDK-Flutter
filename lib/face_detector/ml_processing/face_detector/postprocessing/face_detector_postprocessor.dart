import 'dart:math';
import 'dart:typed_data';

/// Decoding for BlazeFace short-range (128x128, v4).
/// Port of _make_anchors / detect_faces / _nms_weighted (analyze_selfies.py).
class FaceDetectorPostprocessor {
  static const int inputSize = 128;
  static const double scoreThreshold = 0.5;
  static const double nmsThreshold = 0.3;

  static final List<List<double>> _anchors = _generateAnchors();

  static List<List<double>> _generateAnchors() {
    final anchors = <List<double>>[];
    const strides = [8, 16];
    const anchorsPerStride = [2, 6];

    for (int i = 0; i < strides.length; i++) {
      final gridSize = inputSize ~/ strides[i];
      for (int y = 0; y < gridSize; y++) {
        for (int x = 0; x < gridSize; x++) {
          for (int a = 0; a < anchorsPerStride[i]; a++) {
            anchors.add([(x + 0.5) / gridSize, (y + 0.5) / gridSize]);
          }
        }
      }
    }

    return anchors; // 512 + 384 = 896
  }

  static double _sigmoid(double x) => 1.0 / (1.0 + exp(-x.clamp(-100.0, 100.0)));

  static double _iou(List<double> a, List<double> b) {
    final interX1 = max(a[0], b[0]);
    final interY1 = max(a[1], b[1]);
    final interX2 = min(a[2], b[2]);
    final interY2 = min(a[3], b[3]);
    final inter = max(0.0, interX2 - interX1) * max(0.0, interY2 - interY1);
    if (inter == 0.0) return 0.0;
    final areaA = (a[2] - a[0]) * (a[3] - a[1]);
    final areaB = (b[2] - b[0]) * (b[3] - b[1]);
    return inter / (areaA + areaB - inter);
  }

  /// Flat model outputs: regressors [896 * 16], classificators [896].
  /// Returns faces sorted by score, boxes/keypoints in original image pixels.
  static List<Map<String, dynamic>> postprocess(
    Float32List regressors,
    Float32List classificators,
    int origW,
    int origH,
  ) {
    final scale = min(inputSize / origH, inputSize / origW);
    final xOff = (inputSize - origW * scale) / 2;
    final yOff = (inputSize - origH * scale) / 2;

    final boxes = <List<double>>[];
    final keypoints = <List<List<double>>>[];
    final scores = <double>[];

    for (int a = 0; a < _anchors.length; a++) {
      final s = _sigmoid(classificators[a]);
      if (s < scoreThreshold) continue;

      final reg = Float32List.sublistView(regressors, a * 16, a * 16 + 16);
      final apX = _anchors[a][0] * inputSize;
      final apY = _anchors[a][1] * inputSize;

      final cx = reg[0] + apX;
      final cy = reg[1] + apY;
      final w = reg[2];
      final h = reg[3];
      boxes.add([
        (cx - w / 2 - xOff) / scale,
        (cy - h / 2 - yOff) / scale,
        (cx + w / 2 - xOff) / scale,
        (cy + h / 2 - yOff) / scale,
      ]);

      final kps = <List<double>>[];
      for (int k = 2; k < 8; k++) {
        kps.add([
          (reg[k * 2] + apX - xOff) / scale,
          (reg[k * 2 + 1] + apY - yOff) / scale,
        ]);
      }
      keypoints.add(kps);
      scores.add(s);
    }

    if (boxes.isEmpty) return [];
    return _weightedNms(boxes, scores, keypoints);
  }

  static List<Map<String, dynamic>> _weightedNms(
    List<List<double>> boxes,
    List<double> scores,
    List<List<List<double>>> keypoints,
  ) {
    final order = List<int>.generate(scores.length, (i) => i)
      ..sort((a, b) => scores[b].compareTo(scores[a]));
    final active = List<bool>.filled(scores.length, true);
    final results = <Map<String, dynamic>>[];

    for (final i in order) {
      if (!active[i]) continue;
      final candidates = [i];
      for (final j in order) {
        if (j == i || !active[j]) continue;
        if (_iou(boxes[i], boxes[j]) > nmsThreshold) {
          candidates.add(j);
          active[j] = false;
        }
      }
      active[i] = false;

      final total = candidates.fold<double>(0, (sum, c) => sum + scores[c]);
      final box = List<double>.filled(4, 0);
      final numKps = keypoints[i].length;
      final kps = List.generate(numKps, (_) => [0.0, 0.0]);
      for (final c in candidates) {
        final w = scores[c] / total;
        for (int k = 0; k < 4; k++) {
          box[k] += w * boxes[c][k];
        }
        for (int k = 0; k < numKps; k++) {
          kps[k][0] += w * keypoints[c][k][0];
          kps[k][1] += w * keypoints[c][k][1];
        }
      }

      results.add({
        'box': {
          'xMin': box[0],
          'yMin': box[1],
          'xMax': box[2],
          'yMax': box[3],
        },
        'score': scores[i],
        'keypoints': kps.map((p) => {'x': p[0], 'y': p[1]}).toList(),
      });
    }

    return results;
  }
}
