import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class GreyCornersPainter extends CustomPainter {
  final Rect rect;

  GreyCornersPainter({required this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final cornerLen = 40.0;
    final radius = 20.0;
    final stroke = 5.0;
    final color = AppColors.palePeriwinkle;

    final corners = [
      rect.topLeft,
      rect.topRight,
      rect.bottomRight,
      rect.bottomLeft,
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = stroke
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final path = Path();
      switch (i) {
        case 0:
          path.moveTo(corners[i].dx + radius, corners[i].dy);
          path.lineTo(corners[i].dx + cornerLen, corners[i].dy);
          path.moveTo(corners[i].dx, corners[i].dy + radius);
          path.lineTo(corners[i].dx, corners[i].dy + cornerLen);
          path.moveTo(corners[i].dx + radius, corners[i].dy);
          path.arcToPoint(
            Offset(corners[i].dx, corners[i].dy + radius),
            radius: Radius.circular(radius),
            clockwise: false,
          );
          break;
        case 1:
          path.moveTo(corners[i].dx - radius, corners[i].dy);
          path.lineTo(corners[i].dx - cornerLen, corners[i].dy);
          path.moveTo(corners[i].dx, corners[i].dy + radius);
          path.lineTo(corners[i].dx, corners[i].dy + cornerLen);
          path.moveTo(corners[i].dx - radius, corners[i].dy);
          path.arcToPoint(
            Offset(corners[i].dx, corners[i].dy + radius),
            radius: Radius.circular(radius),
            clockwise: true,
          );
          break;
        case 2:
          path.moveTo(corners[i].dx - radius, corners[i].dy);
          path.lineTo(corners[i].dx - cornerLen, corners[i].dy);
          path.moveTo(corners[i].dx, corners[i].dy - radius);
          path.lineTo(corners[i].dx, corners[i].dy - cornerLen);
          path.moveTo(corners[i].dx - radius, corners[i].dy);
          path.arcToPoint(
            Offset(corners[i].dx, corners[i].dy - radius),
            radius: Radius.circular(radius),
            clockwise: false,
          );
          break;
        case 3:
          path.moveTo(corners[i].dx + radius, corners[i].dy);
          path.lineTo(corners[i].dx + cornerLen, corners[i].dy);
          path.moveTo(corners[i].dx, corners[i].dy - radius);
          path.lineTo(corners[i].dx, corners[i].dy - cornerLen);
          path.moveTo(corners[i].dx + radius, corners[i].dy);
          path.arcToPoint(
            Offset(corners[i].dx, corners[i].dy - radius),
            radius: Radius.circular(radius),
            clockwise: true,
          );
          break;
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
