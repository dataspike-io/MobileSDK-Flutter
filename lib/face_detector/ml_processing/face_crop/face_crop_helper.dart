import 'dart:math' as math;
import 'package:image/image.dart' as img;

class FaceCropHelper {
  // Oriented square crop — port of crop_face_roi from Python
  // box: [xMin, yMin, xMax, yMax] in original image pixels
  // kps: keypoints from face detector [rightEye, leftEye, ...]
  static ({img.Image patch, List<List<double>> mInv}) cropFaceRoi(
    img.Image frame,
    Map<String, dynamic> box,
    List<Map<String, double>> kps,
    int ldH,
    int ldW, {
    double scale = 1.5,
  }) {
    final x1 = box['xMin'] as double;
    final y1 = box['yMin'] as double;
    final x2 = box['xMax'] as double;
    final y2 = box['yMax'] as double;

    final cx = (x1 + x2) / 2;
    final cy = (y1 + y2) / 2;
    final size = math.max(x2 - x1, y2 - y1) * scale;

    // Rotation angle from eye keypoints (kps[0]=rightEye, kps[1]=leftEye)
    final angle = math.atan2(
      kps[1]['y']! - kps[0]['y']!,
      kps[1]['x']! - kps[0]['x']!,
    );
    final ca = math.cos(angle);
    final sa = math.sin(angle);

    // Oriented square corners
    final half = size / 2;
    // tl = c - half*right - half*down
    final tlX = cx - half * ca - half * (-sa);
    final tlY = cy - half * sa - half * ca;
    // bl = c - half*right + half*down
    final blX = cx - half * ca + half * (-sa);
    final blY = cy - half * sa + half * ca;
    // tr = c + half*right - half*down
    final trX = cx + half * ca - half * (-sa);
    final trY = cy + half * sa - half * ca;

    // Affine transform src→dst
    // src: [tl, bl, tr], dst: [(0,0), (0,ldH), (ldW,0)]
    final src = [
      [tlX, tlY],
      [blX, blY],
      [trX, trY],
    ];
    final dst = [
      [0.0, 0.0],
      [0.0, ldH.toDouble()],
      [ldW.toDouble(), 0.0],
    ];

    final M = _getAffineTransform(src, dst);
    final mInv = _invertAffine(M);

    // Warp image
    final patch = img.Image(width: ldW, height: ldH);
    for (int py = 0; py < ldH; py++) {
      for (int px = 0; px < ldW; px++) {
        // Apply inverse transform to find source pixel
        final srcX = (mInv[0][0] * px + mInv[0][1] * py + mInv[0][2]).round();
        final srcY = (mInv[1][0] * px + mInv[1][1] * py + mInv[1][2]).round();

        if (srcX >= 0 &&
            srcX < frame.width &&
            srcY >= 0 &&
            srcY < frame.height) {
          patch.setPixel(px, py, frame.getPixel(srcX, srcY));
        }
      }
    }

    return (patch: patch, mInv: mInv);
  }

  // Compute 2x3 affine matrix from 3 point pairs
  static List<List<double>> _getAffineTransform(
    List<List<double>> src,
    List<List<double>> dst,
  ) {
    // Solve: dst = M * src
    final a = [
      [src[0][0], src[0][1], 1.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, src[0][0], src[0][1], 1.0],
      [src[1][0], src[1][1], 1.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, src[1][0], src[1][1], 1.0],
      [src[2][0], src[2][1], 1.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, src[2][0], src[2][1], 1.0],
    ];
    final b = [
      dst[0][0],
      dst[0][1],
      dst[1][0],
      dst[1][1],
      dst[2][0],
      dst[2][1],
    ];

    final x = _solve6x6(a, b);
    return [
      [x[0], x[1], x[2]],
      [x[3], x[4], x[5]],
    ];
  }

  // Invert 2x3 affine matrix
  static List<List<double>> _invertAffine(List<List<double>> M) {
    final a = M[0][0], b = M[0][1], c = M[0][2];
    final d = M[1][0], e = M[1][1], f = M[1][2];
    final det = a * e - b * d;
    return [
      [e / det, -b / det, (b * f - c * e) / det],
      [-d / det, a / det, (c * d - a * f) / det],
    ];
  }

  // Gaussian elimination for 6x6 system
  static List<double> _solve6x6(List<List<double>> A, List<double> b) {
    final n = 6;
    final aug = List.generate(n, (i) => [...A[i], b[i]]);

    for (int col = 0; col < n; col++) {
      int maxRow = col;
      for (int row = col + 1; row < n; row++) {
        if (aug[row][col].abs() > aug[maxRow][col].abs()) maxRow = row;
      }
      final tmp = aug[col];
      aug[col] = aug[maxRow];
      aug[maxRow] = tmp;

      for (int row = col + 1; row < n; row++) {
        final factor = aug[row][col] / aug[col][col];
        for (int j = col; j <= n; j++) {
          aug[row][j] -= factor * aug[col][j];
        }
      }
    }

    final x = List<double>.filled(n, 0);
    for (int i = n - 1; i >= 0; i--) {
      x[i] = aug[i][n];
      for (int j = i + 1; j < n; j++) {
        x[i] -= aug[i][j] * x[j];
      }
      x[i] /= aug[i][i];
    }
    return x;
  }
}
