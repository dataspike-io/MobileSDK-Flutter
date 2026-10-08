import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Flat 8-bit RGB view of a frame with the OpenCV ops used by the
/// production reference (analyze_selfies.py): cv2.warpAffine and
/// cv2.resize, both INTER_LINEAR, results rounded back to uint8.
class RgbFrame {
  final Uint8List rgb;
  final int width;
  final int height;

  RgbFrame(this.rgb, this.width, this.height);

  factory RgbFrame.fromImage(img.Image image) => RgbFrame(
    image.getBytes(order: img.ChannelOrder.rgb),
    image.width,
    image.height,
  );

  // cv2 quantizes warp coordinates to 1/INTER_TAB_SIZE of a pixel.
  static const int _interTabSize = 32;

  /// cv2.warpAffine(INTER_LINEAR). [inv] maps output pixels to source
  /// pixels (i.e. the inverse of the matrix passed to cv2).
  /// [replicateBorder]: BORDER_REPLICATE, otherwise BORDER_CONSTANT (0).
  Uint8List warpAffine(
    List<List<double>> inv,
    int outW,
    int outH, {
    required bool replicateBorder,
  }) {
    final out = Uint8List(outW * outH * 3);
    int o = 0;
    for (int y = 0; y < outH; y++) {
      for (int x = 0; x < outW; x++) {
        final sx = inv[0][0] * x + inv[0][1] * y + inv[0][2];
        final sy = inv[1][0] * x + inv[1][1] * y + inv[1][2];
        final qx = (sx * _interTabSize + 0.5).floor();
        final qy = (sy * _interTabSize + 0.5).floor();
        final x0 = qx >> 5;
        final y0 = qy >> 5;
        final fx = (qx & (_interTabSize - 1)) / _interTabSize;
        final fy = (qy & (_interTabSize - 1)) / _interTabSize;
        for (int c = 0; c < 3; c++) {
          final tl = _px(x0, y0, c, replicateBorder);
          final tr = _px(x0 + 1, y0, c, replicateBorder);
          final bl = _px(x0, y0 + 1, c, replicateBorder);
          final br = _px(x0 + 1, y0 + 1, c, replicateBorder);
          final top = tl + (tr - tl) * fx;
          final bottom = bl + (br - bl) * fx;
          out[o++] = (top + (bottom - top) * fy).round().clamp(0, 255);
        }
      }
    }
    return out;
  }

  int _px(int x, int y, int c, bool replicate) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      if (!replicate) return 0;
      x = x.clamp(0, width - 1);
      y = y.clamp(0, height - 1);
    }
    return rgb[(y * width + x) * 3 + c];
  }

  /// cv2.resize(INTER_LINEAR): half-pixel centers, edge-clamped.
  RgbFrame resize(int outW, int outH) {
    final out = Uint8List(outW * outH * 3);
    final scaleX = width / outW;
    final scaleY = height / outH;
    int o = 0;
    for (int y = 0; y < outH; y++) {
      final (y0, y1, fy) = _axis((y + 0.5) * scaleY - 0.5, height);
      for (int x = 0; x < outW; x++) {
        final (x0, x1, fx) = _axis((x + 0.5) * scaleX - 0.5, width);
        for (int c = 0; c < 3; c++) {
          final tl = rgb[(y0 * width + x0) * 3 + c];
          final tr = rgb[(y0 * width + x1) * 3 + c];
          final bl = rgb[(y1 * width + x0) * 3 + c];
          final br = rgb[(y1 * width + x1) * 3 + c];
          final top = tl + (tr - tl) * fx;
          final bottom = bl + (br - bl) * fx;
          out[o++] = (top + (bottom - top) * fy).round().clamp(0, 255);
        }
      }
    }
    return RgbFrame(out, outW, outH);
  }

  static (int, int, double) _axis(double src, int size) {
    var i0 = src.floor();
    var f = src - i0;
    if (i0 < 0) {
      i0 = 0;
      f = 0;
    }
    if (i0 >= size - 1) {
      i0 = size - 1;
      f = 0;
    }
    final i1 = i0 < size - 1 ? i0 + 1 : i0;
    return (i0, i1, f);
  }

  /// Numpy-style slice rgb[y1:y2, x1:x2]; bounds must already be clamped.
  RgbFrame crop(int x1, int y1, int x2, int y2) {
    final w = x2 - x1;
    final h = y2 - y1;
    final out = Uint8List(w * h * 3);
    for (int y = 0; y < h; y++) {
      final src = ((y1 + y) * width + x1) * 3;
      out.setRange(y * w * 3, (y + 1) * w * 3, rgb, src);
    }
    return RgbFrame(out, w, h);
  }
}
