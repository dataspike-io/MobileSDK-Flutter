import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class TwoArcsPainter extends CustomPainter {
  const TwoArcsPainter({
    this.color = AppColors.white,
    this.strokeWidth = 3,
    this.sideInsetPct = 0.10,
    this.topApexPct = 0.10,
    this.bottomApexFromBottomPct = 0.2,
    this.topRisePx = 100,
    this.bottomRisePx = 100,
    this.ctrlXpx = 100,
  });

  final Color color;
  final double strokeWidth;
  final double sideInsetPct;
  final double topApexPct;
  final double bottomApexFromBottomPct;
  final double topRisePx;
  final double bottomRisePx;
  final double ctrlXpx;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final margin = strokeWidth / 2 + 0.5;

    final leftX = (w * sideInsetPct).clamp(margin, w - margin);
    final rightX = (w * (1 - sideInsetPct)).clamp(margin, w - margin);
    final midX = (leftX + rightX) / 2;

    final topApexY = (h * topApexPct) + margin;
    final maxTopRise = ((h - margin) - topApexY).clamp(0, double.infinity);
    final topRise = topRisePx.clamp(0, maxTopRise);
    final topLineY = topApexY + topRise;

    final bottomApexY = (h * (1 - bottomApexFromBottomPct)) - margin;
    final maxBottomRise = (bottomApexY - margin).clamp(0, double.infinity);
    final bottomRise = bottomRisePx.clamp(0, maxBottomRise);
    final bottomLineY = bottomApexY - bottomRise;

    final paintLine = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final topPath = Path()
      ..moveTo(leftX, topLineY)
      ..cubicTo(
        leftX,
        topLineY - topRise * 0.6,
        midX - ctrlXpx,
        topApexY,
        midX,
        topApexY,
      )
      ..cubicTo(
        midX + ctrlXpx,
        topApexY,
        rightX,
        topLineY - topRise * 0.6,
        rightX,
        topLineY,
      );

    final bottomPath = Path()
      ..moveTo(rightX, bottomLineY)
      ..cubicTo(
        rightX,
        bottomLineY + bottomRise * 0.6,
        midX + ctrlXpx,
        bottomApexY,
        midX,
        bottomApexY,
      )
      ..cubicTo(
        midX - ctrlXpx,
        bottomApexY,
        leftX,
        bottomLineY + bottomRise * 0.6,
        leftX,
        bottomLineY,
      );

    canvas.drawPath(topPath, paintLine);
    canvas.drawPath(bottomPath, paintLine);
  }

  @override
  bool shouldRepaint(covariant TwoArcsPainter old) =>
      color != old.color ||
      strokeWidth != old.strokeWidth ||
      sideInsetPct != old.sideInsetPct ||
      topApexPct != old.topApexPct ||
      bottomApexFromBottomPct != old.bottomApexFromBottomPct ||
      topRisePx != old.topRisePx ||
      bottomRisePx != old.bottomRisePx ||
      ctrlXpx != old.ctrlXpx;
}
