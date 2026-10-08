import 'dart:math' as math;
import 'dart:typed_data';
import 'package:dataspikemobilesdk/face_detector/ml_processing/image/rgb_frame.dart';

class FaceCropHelper {
  static const double boxScale = 1.5;

  /// Oriented square crop fed to the landmarks model.
  /// Port of crop_face_roi (analyze_selfies.py): cv2.warpAffine with
  /// INTER_LINEAR + BORDER_REPLICATE, normalized to [0, 1].
  ///
  /// box: {xMin, yMin, xMax, yMax} in original image pixels.
  /// kps: detector keypoints [rightEye, leftEye, ...].
  static ({Float32List input, List<List<double>> mInv, double roiSize})
  cropFaceRoi(
    RgbFrame frame,
    Map<String, dynamic> box,
    List<Map<String, double>> kps,
    int ldH,
    int ldW,
  ) {
    final x1 = box['xMin'] as double;
    final y1 = box['yMin'] as double;
    final x2 = box['xMax'] as double;
    final y2 = box['yMax'] as double;

    final cx = (x1 + x2) / 2;
    final cy = (y1 + y2) / 2;
    final size = math.max(x2 - x1, y2 - y1) * boxScale;

    final angle = math.atan2(
      kps[1]['y']! - kps[0]['y']!,
      kps[1]['x']! - kps[0]['x']!,
    );
    final ca = math.cos(angle);
    final sa = math.sin(angle);
    final half = size / 2;

    final src = [
      [cx - half * ca + half * sa, cy - half * sa - half * ca], // tl
      [cx - half * ca - half * sa, cy - half * sa + half * ca], // bl
      [cx + half * ca + half * sa, cy + half * sa - half * ca], // tr
    ];
    final dst = [
      [0.0, 0.0],
      [0.0, ldH.toDouble()],
      [ldW.toDouble(), 0.0],
    ];

    final m = _getAffineTransform(src, dst);
    final mInv = _invertAffine(m);

    final pixels = frame.warpAffine(mInv, ldW, ldH, replicateBorder: true);
    final input = Float32List(pixels.length);
    for (int i = 0; i < pixels.length; i++) {
      input[i] = pixels[i] / 255.0;
    }

    return (input: input, mInv: mInv, roiSize: size);
  }

  // Closed-form 3-point affine, same result as
  // cv2.getAffineTransform.
  static List<List<double>> _getAffineTransform(
    List<List<double>> src,
    List<List<double>> dst,
  ) {
    final sx0 = src[0][0], sy0 = src[0][1];
    final sx1 = src[1][0], sy1 = src[1][1];
    final sx2 = src[2][0], sy2 = src[2][1];
    final det =
        sx0 * (sy1 - sy2) - sy0 * (sx1 - sx2) + (sx1 * sy2 - sx2 * sy1);
    if (det.abs() < 1e-12) {
      return [
        [1.0, 0.0, 0.0],
        [0.0, 1.0, 0.0],
      ];
    }
    final invDet = 1 / det;
    final i00 = (sy1 - sy2) * invDet;
    final i01 = (sx2 - sx1) * invDet;
    final i02 = (sx1 * sy2 - sx2 * sy1) * invDet;
    final i10 = (sy2 - sy0) * invDet;
    final i11 = (sx0 - sx2) * invDet;
    final i12 = (sx2 * sy0 - sx0 * sy2) * invDet;
    final i20 = (sy0 - sy1) * invDet;
    final i21 = (sx1 - sx0) * invDet;
    final i22 = (sx0 * sy1 - sx1 * sy0) * invDet;
    final dx0 = dst[0][0], dy0 = dst[0][1];
    final dx1 = dst[1][0], dy1 = dst[1][1];
    final dx2 = dst[2][0], dy2 = dst[2][1];
    return [
      [
        dx0 * i00 + dx1 * i10 + dx2 * i20,
        dx0 * i01 + dx1 * i11 + dx2 * i21,
        dx0 * i02 + dx1 * i12 + dx2 * i22,
      ],
      [
        dy0 * i00 + dy1 * i10 + dy2 * i20,
        dy0 * i01 + dy1 * i11 + dy2 * i21,
        dy0 * i02 + dy1 * i12 + dy2 * i22,
      ],
    ];
  }

  static List<List<double>> _invertAffine(List<List<double>> m) {
    final a = m[0][0], b = m[0][1], e = m[0][2];
    final c = m[1][0], d = m[1][1], f = m[1][2];
    final det = a * d - b * c;
    if (det.abs() < 1e-12) {
      return [
        [1.0, 0.0, 0.0],
        [0.0, 1.0, 0.0],
      ];
    }
    final id = 1 / det;
    return [
      [d * id, -b * id, (b * f - d * e) * id],
      [-c * id, a * id, (c * e - a * f) * id],
    ];
  }
}
