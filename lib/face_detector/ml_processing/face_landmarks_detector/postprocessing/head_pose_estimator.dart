import 'dart:math' as math;

class HeadPoseEstimator {
  static const double fov = 63.0;
  static const double near = 1.0;

  // Procrustes basis weights — from geometry_pipeline_metadata_landmarks.pbtxt
  static const Map<int, double> _procrustesBasis = {
    4: 0.070909939706326,
    6: 0.032100144773722,
    10: 0.008446550928056,
    33: 0.058724168688059,
    54: 0.007667080033571,
    67: 0.009078059345484,
    117: 0.009791937656701,
    119: 0.014565368182957,
    121: 0.018591361120343,
    127: 0.005197994410992,
    129: 0.120625205338001,
    132: 0.005560018587857,
    133: 0.053286183625460,
    136: 0.066890455782413,
    143: 0.014816547743976,
    147: 0.014262833632529,
    198: 0.025462191551924,
    205: 0.047252278774977,
    263: 0.058724168688059,
    284: 0.007667080033571,
    297: 0.009078059345484,
    346: 0.009791937656701,
    348: 0.014565368182957,
    350: 0.018591361120343,
    356: 0.005197994410992,
    358: 0.120625205338001,
    361: 0.005560018587857,
    362: 0.053286183625460,
    365: 0.066890455782413,
    372: 0.014816547743976,
    376: 0.014262833632529,
    420: 0.025462191551924,
    425: 0.047252278774977,
  };

  static List<double> _buildWeights(int n) {
    final w = List<double>.filled(n, 0.0);
    for (final entry in _procrustesBasis.entries) {
      w[entry.key] = entry.value;
    }
    return w;
  }

  // Map landmarks back to original image space using inverse affine matrix
  // Port of: lm_orig = (M_inv @ pts.T).T
  static List<List<double>> mapLandmarksToOriginal(
    List<Map<String, double>> landmarks,
    List<List<double>> mInv,
    int ldW,
    int ldH,
  ) {
    final result = <List<double>>[];
    for (final lm in landmarks) {
      final px = lm['x']! * ldW;
      final py = lm['y']! * ldH;
      final ox = mInv[0][0] * px + mInv[0][1] * py + mInv[0][2];
      final oy = mInv[1][0] * px + mInv[1][1] * py + mInv[1][2];
      result.add([ox, oy]);
    }
    return result;
  }

  // Port of estimate_pose from Python
  static List<List<double>>? estimatePose(
    List<List<double>> lmOrig,       // (468, 2) in original image pixels
    List<double> lmZ,                // (468,) z values normalized [0,1]
    List<List<double>> canonical,    // (468, 3) canonical face model
    List<double> weights,            // (468,) procrustes weights
    int imgH,
    int imgW,
  ) {
    // screen = [x/w, y/h, z]
    final screen = List.generate(468, (i) => [
      lmOrig[i][0] / imgW,
      lmOrig[i][1] / imgH,
      lmZ[i],
    ]);

    final hN = 2 * near * math.tan(0.5 * fov * math.pi / 180);
    final wN = imgW * hN / imgH;
    final l = -0.5 * wN;
    final r = 0.5 * wN;
    final b = -0.5 * hN;
    final t = 0.5 * hN;

    // lm = screen transformed to metric space
    final lm = List.generate(3, (_) => List<double>.filled(468, 0.0));
    for (int i = 0; i < 468; i++) {
      lm[0][i] = screen[i][0] * (r - l) + l;
      lm[1][i] = (1 - screen[i][1]) * (t - b) + b;
      lm[2][i] = screen[i][2] * (r - l);
    }

    final doff = lm[2].reduce((a, b) => a + b) / 468;

    // src = canonical transposed (3, 468)
    final src = List.generate(3, (i) => List.generate(468, (j) => canonical[j][i]));

    // Pass 1
    final i1 = List.generate(3, (i) => List<double>.from(lm[i]));
    for (int j = 0; j < 468; j++) i1[2][j] *= -1;
    final m1 = _procrustes(src, i1, weights);
    if (m1 == null) return null;
    final s1 = math.sqrt(m1[0][0] * m1[0][0] + m1[1][0] * m1[1][0] + m1[2][0] * m1[2][0]);

    // Pass 2
    final i2 = List.generate(3, (i) => List<double>.from(lm[i]));
    for (int j = 0; j < 468; j++) {
      i2[2][j] = (i2[2][j] - doff + near) / s1;
      i2[0][j] *= i2[2][j] / near;
      i2[1][j] *= i2[2][j] / near;
      i2[2][j] *= -1;
    }
    final m2 = _procrustes(src, i2, weights);
    if (m2 == null) return null;
    final s2 = math.sqrt(m2[0][0] * m2[0][0] + m2[1][0] * m2[1][0] + m2[2][0] * m2[2][0]);

    final ts = s1 * s2;

    // Final pass
    final m = List.generate(3, (i) => List<double>.from(lm[i]));
    for (int j = 0; j < 468; j++) {
      m[2][j] = (m[2][j] - doff + near) / ts;
      m[0][j] *= m[2][j] / near;
      m[1][j] *= m[2][j] / near;
      m[2][j] *= -1;
    }

    return _procrustes(src, m, weights);
  }

  // Port of _procrustes from Python
  static List<List<double>>? _procrustes(
    List<List<double>> src, // (3, 468)
    List<List<double>> tgt, // (3, 468)
    List<double> w,
  ) {
    try {
      final W = w.reduce((a, b) => a + b);

      // Weighted means
      final ms = List<double>.filled(3, 0.0);
      final mt = List<double>.filled(3, 0.0);
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 468; j++) {
          ms[i] += src[i][j] * w[j];
          mt[i] += tgt[i][j] * w[j];
        }
        ms[i] /= W;
        mt[i] /= W;
      }

      // Centered
      final sc = List.generate(3, (i) => List.generate(468, (j) => src[i][j] - ms[i]));
      final tc = List.generate(3, (i) => List.generate(468, (j) => tgt[i][j] - mt[i]));

      // H = sc @ (tc * w).T → (3,3)
      final H = List.generate(3, (_) => List<double>.filled(3, 0.0));
      for (int i = 0; i < 3; i++) {
        for (int k = 0; k < 3; k++) {
          for (int j = 0; j < 468; j++) {
            H[i][k] += sc[i][j] * tc[k][j] * w[j];
          }
        }
      }

      // SVD of H
      final svdResult = _svd3x3(H);
      if (svdResult == null) return null;
      final U = svdResult.$1;
      final sv = svdResult.$2;
      final Vt = svdResult.$3;

      // d = det(Vt.T @ U.T)
      final VtT = _transpose3x3(Vt);
      final UT = _transpose3x3(U);
      final d = _det3x3(_multiply3x3(VtT, UT));
      final sign = d < 0 ? -1.0 : 1.0;

      // R = Vt.T @ D @ U.T
      final D = [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, sign]];
      final R = _multiply3x3(VtT, _multiply3x3(D, UT));

      // s = dot([1,1,d], sv) / sum(sc^2 * w)
      final num = sv[0] + sv[1] + sign * sv[2];
      double denom = 0.0;
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 468; j++) {
          denom += sc[i][j] * sc[i][j] * w[j];
        }
      }
      final s = num / denom;

      // t = mt - s * R @ ms
      final Rms = [
        R[0][0] * ms[0] + R[0][1] * ms[1] + R[0][2] * ms[2],
        R[1][0] * ms[0] + R[1][1] * ms[1] + R[1][2] * ms[2],
        R[2][0] * ms[0] + R[2][1] * ms[1] + R[2][2] * ms[2],
      ];
      final tr = [mt[0] - s * Rms[0], mt[1] - s * Rms[1], mt[2] - s * Rms[2]];

      // Build 4x4 matrix
      final mat = List.generate(4, (_) => List<double>.filled(4, 0.0));
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          mat[i][j] = s * R[i][j];
        }
        mat[i][3] = tr[i];
      }
      mat[3][3] = 1.0;

      return mat;
    } catch (_) {
      return null;
    }
  }

  // Port of angles_from_matrix + decompose44
  static Map<String, double> anglesFromMatrix(List<List<double>> mat44) {
    final R = _decompose44(mat44);

    final sy = math.sqrt(R[0][0] * R[0][0] + R[1][0] * R[1][0]);
    final singular = sy < 1e-6;

    double pitch, yaw, roll;
    if (!singular) {
      pitch = math.atan2(R[2][1], R[2][2]);
      yaw = math.atan2(-R[2][0], sy);
      roll = math.atan2(R[1][0], R[0][0]);
    } else {
      pitch = math.atan2(-R[1][2], R[1][1]);
      yaw = math.atan2(-R[2][0], sy);
      roll = 0.0;
    }

    return {
      'pitch': pitch * 180 / math.pi,
      'yaw': yaw * 180 / math.pi,
      'roll': roll * 180 / math.pi,
    };
  }

  // Port of _decompose44
  static List<List<double>> _decompose44(List<List<double>> A) {
    final M0 = [A[0][0], A[1][0], A[2][0]];
    final M1 = [A[0][1], A[1][1], A[2][1]];
    final M2 = [A[0][2], A[1][2], A[2][2]];

    final sx = math.sqrt(M0[0]*M0[0] + M0[1]*M0[1] + M0[2]*M0[2]);
    for (int i = 0; i < 3; i++) M0[i] /= sx;

    final dot01 = M0[0]*M1[0] + M0[1]*M1[1] + M0[2]*M1[2];
    for (int i = 0; i < 3; i++) M1[i] -= dot01 * M0[i];
    final sy = math.sqrt(M1[0]*M1[0] + M1[1]*M1[1] + M1[2]*M1[2]);
    for (int i = 0; i < 3; i++) M1[i] /= sy;

    final dot02 = M0[0]*M2[0] + M0[1]*M2[1] + M0[2]*M2[2];
    final dot12 = M1[0]*M2[0] + M1[1]*M2[1] + M1[2]*M2[2];
    for (int i = 0; i < 3; i++) M2[i] -= dot02 * M0[i] + dot12 * M1[i];
    final sz = math.sqrt(M2[0]*M2[0] + M2[1]*M2[1] + M2[2]*M2[2]);
    for (int i = 0; i < 3; i++) M2[i] /= sz;

    final R = [
      [M0[0], M1[0], M2[0]],
      [M0[1], M1[1], M2[1]],
      [M0[2], M1[2], M2[2]],
    ];

    if (_det3x3(R) < 0) {
      for (int i = 0; i < 3; i++) R[i][0] *= -1;
    }

    return R;
  }

  // Helper: 3x3 matrix multiply
  static List<List<double>> _multiply3x3(List<List<double>> A, List<List<double>> B) {
    final C = List.generate(3, (_) => List<double>.filled(3, 0.0));
    for (int i = 0; i < 3; i++)
      for (int j = 0; j < 3; j++)
        for (int k = 0; k < 3; k++)
          C[i][j] += A[i][k] * B[k][j];
    return C;
  }

  // Helper: 3x3 transpose
  static List<List<double>> _transpose3x3(List<List<double>> A) =>
      List.generate(3, (i) => List.generate(3, (j) => A[j][i]));

  // Helper: 3x3 determinant
  static double _det3x3(List<List<double>> A) =>
      A[0][0] * (A[1][1]*A[2][2] - A[1][2]*A[2][1]) -
      A[0][1] * (A[1][0]*A[2][2] - A[1][2]*A[2][0]) +
      A[0][2] * (A[1][0]*A[2][1] - A[1][1]*A[2][0]);

  // SVD for 3x3 via eigendecomposition of A^T*A. Port of svd3x3 (reference
  // JS): singular values sorted descending, so the reflection fix in
  // _procrustes always lands on the smallest one.
  static (List<List<double>>, List<double>, List<List<double>>)? _svd3x3(
    List<List<double>> A,
  ) {
    final eig = _eigen3x3Symmetric(_multiply3x3(_transpose3x3(A), A));
    final values = eig.$1;
    final vectors = eig.$2;

    final idx = [0, 1, 2]..sort((a, b) => values[b].compareTo(values[a]));
    final sv = idx.map((i) => math.sqrt(math.max(0.0, values[i]))).toList();
    final V = List.generate(
      3,
      (r) => List.generate(3, (c) => vectors[r][idx[c]]),
    );

    // U = A*V * diag(1/sv); degenerate columns completed by cross product.
    final AV = _multiply3x3(A, V);
    final U = List.generate(3, (_) => List<double>.filled(3, 0.0));
    for (int j = 0; j < 3; j++) {
      if (sv[j] > 1e-10) {
        for (int i = 0; i < 3; i++) {
          U[i][j] = AV[i][j] / sv[j];
        }
      }
    }
    for (int j = 0; j < 3; j++) {
      if (sv[j] <= 1e-10) {
        final a = (j + 1) % 3;
        final b = (j + 2) % 3;
        U[0][j] = U[1][a] * U[2][b] - U[2][a] * U[1][b];
        U[1][j] = U[2][a] * U[0][b] - U[0][a] * U[2][b];
        U[2][j] = U[0][a] * U[1][b] - U[1][a] * U[0][b];
      }
    }

    return (U, sv, _transpose3x3(V));
  }

  // Jacobi eigendecomposition for 3x3 symmetric matrix.
  // Port of jacobiEigen3x3 (reference JS).
  static (List<double>, List<List<double>>) _eigen3x3Symmetric(
    List<List<double>> A,
  ) {
    final a = List.generate(3, (i) => List<double>.from(A[i]));
    final v = [
      [1.0, 0.0, 0.0],
      [0.0, 1.0, 0.0],
      [0.0, 0.0, 1.0],
    ];

    for (int iter = 0; iter < 100; iter++) {
      double maxOff = 0;
      int p = 0, q = 1;
      for (int i = 0; i < 3; i++) {
        for (int j = i + 1; j < 3; j++) {
          if (a[i][j].abs() > maxOff) {
            maxOff = a[i][j].abs();
            p = i;
            q = j;
          }
        }
      }
      if (maxOff < 1e-15) break;

      final diff = a[p][p] - a[q][q];
      double tanTheta;
      if (diff.abs() < 1e-15) {
        tanTheta = 1;
      } else {
        final tau = diff / (2 * a[p][q]);
        tanTheta = tau.sign / (tau.abs() + math.sqrt(1 + tau * tau));
      }
      final c = 1 / math.sqrt(1 + tanTheta * tanTheta);
      final s = tanTheta * c;

      final apq = a[p][q];
      a[p][p] += tanTheta * apq;
      a[q][q] -= tanTheta * apq;
      a[p][q] = 0;
      a[q][p] = 0;

      for (int r = 0; r < 3; r++) {
        if (r != p && r != q) {
          final arp = a[r][p];
          final arq = a[r][q];
          final rp = c * arp + s * arq;
          final rq = -s * arp + c * arq;
          a[r][p] = rp;
          a[p][r] = rp;
          a[r][q] = rq;
          a[q][r] = rq;
        }
      }
      for (int r = 0; r < 3; r++) {
        final vrp = v[r][p];
        final vrq = v[r][q];
        v[r][p] = c * vrp + s * vrq;
        v[r][q] = -s * vrp + c * vrq;
      }
    }

    return ([a[0][0], a[1][1], a[2][2]], v);
  }

  static final List<double> _weights = _buildWeights(468);

  // Main method — call this from FacePipeline
  static Map<String, double>? estimate(
    List<Map<String, double>> landmarks, // normalized [0,1], first 468 used
    List<List<double>> lmOrig, // landmarks in original image pixels
    List<List<double>> canonical, // canonical face model
    double roiSize, // side of the landmarks ROI in original pixels
    int imgH,
    int imgW,
  ) {
    // z is relative to the ROI width; rescale to the full-frame width.
    final roiWidthNorm = roiSize / imgW;
    final lmZ = landmarks.map((l) => l['z']! * roiWidthNorm).toList();

    final mat44 = estimatePose(lmOrig, lmZ, canonical, _weights, imgH, imgW);
    if (mat44 == null) return null;

    return anglesFromMatrix(mat44);
  }

  // Head counts as rotated once any angle reaches its threshold
  // (PITCH_THR / YAW_THR / ROLL_THR in the reference).
  static const double maxPitch = 15.0;
  static const double maxYaw = 11.0;
  static const double maxRoll = 15.0;

  static bool isAcceptable(Map<String, double> angles) {
    return angles['pitch']!.abs() < maxPitch &&
        angles['yaw']!.abs() < maxYaw &&
        angles['roll']!.abs() < maxRoll;
  }
}
