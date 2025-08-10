import 'package:flutter/material.dart';

class DashedUnderlineText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color dashColor;

  const DashedUnderlineText({
    super.key,
    required this.text,
    required this.style,
    required this.dashColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: style.copyWith(
            decoration: TextDecoration.none, 
          ),
        ),
        Positioned.fill(
          bottom: -2,
          child: CustomPaint(
            painter: _DashedLinePainter(dashColor: dashColor),
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color dashColor;

  _DashedLinePainter({required this.dashColor});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    final paint = Paint()
      ..color = dashColor
      ..strokeWidth = 1.0;
    double x = 0;
    final y = size.height - 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
