import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class DimOverlayPainter extends CustomPainter {
  final Rect holeRect;
  final double borderRadius;
  final Color overlayColor;

  DimOverlayPainter({
    required this.holeRect,
    this.borderRadius = 20,
    this.overlayColor = AppColors.blackTransparent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectXY(holeRect, borderRadius, borderRadius));
    path.fillType = PathFillType.evenOdd;
    final paint = Paint()..color = overlayColor;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}