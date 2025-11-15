import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';

class TwoArcsPainter extends CustomPainter {
  const TwoArcsPainter({
    this.color = AppColors.white,
    this.highlightColor = AppColors.lightRed,
    this.topRisePx = 110,
    this.bottomRisePx = 110,
    this.ctrlXpx = 60,
    this.isTopArcHighlighted = false,
    this.isBottomArcHighlighted = false,
  });

  final Color color;
  final Color highlightColor;
  
  final double topRisePx;
  final double bottomRisePx;
  final double ctrlXpx;
  final bool isTopArcHighlighted;
  final bool isBottomArcHighlighted;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final margin = CameraConstants.avatarStrokeWidth / 2 + 0.5;

    final leftX = (w * CameraConstants.avatarSideInsetPct).clamp(margin, w - margin);
    final rightX = (w * (1 - CameraConstants.avatarSideInsetPct)).clamp(margin, w - margin);
    final midX = (leftX + rightX) / 2;

    final topApexY = (h * CameraConstants.avatarTopApexPct) + margin;
    final maxTopRise = ((h - margin) - topApexY).clamp(0, double.infinity);
    final topRise = topRisePx.clamp(0, maxTopRise);
    final topLineY = topApexY + topRise;

    final bottomApexY = (h * (1 - CameraConstants.avatarBottomApexFromBottomPct)) - margin;
    final maxBottomRise = (bottomApexY - margin).clamp(0, double.infinity);
    final bottomRise = bottomRisePx.clamp(0, maxBottomRise);
    final bottomLineY = bottomApexY - bottomRise;

    final topPaintLine = Paint()
      ..color = isTopArcHighlighted ? highlightColor : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = CameraConstants.avatarStrokeWidth
      ..strokeCap = StrokeCap.round;

      final bottomPaintLine = Paint()
      ..color = isBottomArcHighlighted ? highlightColor : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = CameraConstants.avatarStrokeWidth
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

    canvas.drawPath(topPath, topPaintLine);
    canvas.drawPath(bottomPath, bottomPaintLine);
  }

  @override
  bool shouldRepaint(covariant TwoArcsPainter old) =>
      color != old.color ||     
      topRisePx != old.topRisePx ||
      bottomRisePx != old.bottomRisePx ||
      ctrlXpx != old.ctrlXpx || 
      isTopArcHighlighted != old.isTopArcHighlighted || 
      isBottomArcHighlighted != old.isBottomArcHighlighted;
}
