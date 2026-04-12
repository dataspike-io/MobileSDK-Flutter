import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';

class DefaultFaceCornersPainter extends CustomPainter {
  const DefaultFaceCornersPainter({
    this.color = AppColors.white,
    this.cornerLength = 85.0,
    this.strokeWidth = 5.0,
    this.borderRadius = 46.0,
  });

  final Color color;
  final double cornerLength;
  final double strokeWidth;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final margin = strokeWidth / 2 + 0.5;

    final leftX = (w * CameraConstants.avatarSideInsetPct).clamp(margin, w - margin);
    final rightX = (w * (1 - CameraConstants.avatarSideInsetPct)).clamp(margin, w - margin);
    final topY = (h * CameraConstants.avatarTopApexPct) + margin;
    final bottomY = (h * (1 - CameraConstants.avatarBottomApexFromBottomPct)) - margin;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final r = borderRadius;
    final cl = cornerLength;

    // Top-left
    _drawCorner(canvas, paint,
      x: leftX, y: topY,
      dx: 1, dy: 1,
      r: r, cl: cl,
    );

    // Top-right
    _drawCorner(canvas, paint,
      x: rightX, y: topY,
      dx: -1, dy: 1,
      r: r, cl: cl,
    );

    // Bottom-left
    _drawCorner(canvas, paint,
      x: leftX, y: bottomY,
      dx: 1, dy: -1,
      r: r, cl: cl,
    );

    // Bottom-right
    _drawCorner(canvas, paint,
      x: rightX, y: bottomY,
      dx: -1, dy: -1,
      r: r, cl: cl,
    );
  }

  void _drawCorner(
    Canvas canvas,
    Paint paint, {
    required double x,
    required double y,
    required double dx,
    required double dy,
    required double r,
    required double cl,
  }) {
    final path = Path()
      ..moveTo(x + dx * cl, y)
      ..lineTo(x + dx * r, y)
      ..arcToPoint(
        Offset(x, y + dy * r),
        radius: Radius.circular(r),
        clockwise: dx != dy,
      )
      ..lineTo(x, y + dy * cl);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant DefaultFaceCornersPainter old) =>
      color != old.color ||
      cornerLength != old.cornerLength ||
      strokeWidth != old.strokeWidth ||
      borderRadius != old.borderRadius;
}