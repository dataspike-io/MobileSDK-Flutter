import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';
import 'dart:math';

class TwoArcsPainter extends CustomPainter {
  const TwoArcsPainter({
    this.color = AppColors.white,
    this.highlightColor = AppColors.lightRed,
    this.secondaryHighlightColor = AppColors.royalPurple,
    this.topRisePx = 110,
    this.bottomRisePx = 110,
    this.ctrlXpx = 60,
    this.isTopArcHighlighted = false,
    this.isBottomArcHighlighted = false,
    this.isShownSecondaryArcLayer = false,
    this.isArrowsEnabled = false,
  });

  final Color color;
  final Color highlightColor;
  final Color secondaryHighlightColor;

  final double topRisePx;
  final double bottomRisePx;
  final double ctrlXpx;
  final bool isTopArcHighlighted;
  final bool isBottomArcHighlighted;
  final bool isShownSecondaryArcLayer;
  final bool isArrowsEnabled;

  Offset _bezierPoint(List<Offset> p, double t) {
    final mt = 1 - t;
    return p[0] * (mt * mt * mt) +
        p[1] * (3 * mt * mt * t) +
        p[2] * (3 * mt * t * t) +
        p[3] * (t * t * t);
  }

  Offset _bezierTangent(List<Offset> p, double t) {
    final mt = 1 - t;
    return (p[1] - p[0]) * (3 * mt * mt) +
        (p[2] - p[1]) * (6 * mt * t) +
        (p[3] - p[2]) * (3 * t * t);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final margin = CameraConstants.avatarStrokeWidth / 2 + 0.5;

    final leftX = (w * CameraConstants.avatarSideInsetPct).clamp(
      margin,
      w - margin,
    );
    final rightX = (w * (1 - CameraConstants.avatarSideInsetPct)).clamp(
      margin,
      w - margin,
    );
    final midX = (leftX + rightX) / 2;

    final topApexY = (h * CameraConstants.avatarTopApexPct) + margin;
    final maxTopRise = ((h - margin) - topApexY).clamp(0, double.infinity);
    final topRise = topRisePx.clamp(0, maxTopRise);
    final topLineY = topApexY + topRise;

    final bottomApexY =
        (h * (1 - CameraConstants.avatarBottomApexFromBottomPct)) - margin;
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

    if (isShownSecondaryArcLayer) {
      final inset = 30.0;
      final sLeftX = leftX + inset;
      final sRightX = rightX - inset;
      final sMidX = (sLeftX + sRightX) / 2;
      final sTopApexY = topApexY + inset;
      final sBottomApexY = bottomApexY - inset;

      final sWidth = sRightX - sLeftX;
      final origWidth = rightX - leftX;
      final sCtrlXpx = ctrlXpx * (sWidth / origWidth);

      final sTopRise = topRise * 1.15; 
      final sBottomRise = bottomRise * 1.15;

      final sTopLineY = topApexY + sTopRise;
      final sBottomLineY = bottomApexY - sBottomRise;

      final sTopPath = Path()
        ..moveTo(sLeftX, sTopLineY)
        ..cubicTo(
          sLeftX,
          sTopLineY - sTopRise * 0.6,
          sMidX - sCtrlXpx,
          sTopApexY,
          sMidX,
          sTopApexY,
        )
        ..cubicTo(
          sMidX + sCtrlXpx,
          sTopApexY,
          sRightX,
          sTopLineY - sTopRise * 0.6,
          sRightX,
          sTopLineY,
        );

      final sBottomPath = Path()
        ..moveTo(sRightX, sBottomLineY)
        ..cubicTo(
          sRightX,
          sBottomLineY + sBottomRise * 0.6,
          sMidX + sCtrlXpx,
          sBottomApexY,
          sMidX,
          sBottomApexY,
        )
        ..cubicTo(
          sMidX - sCtrlXpx,
          sBottomApexY,
          sLeftX,
          sBottomLineY + sBottomRise * 0.6,
          sLeftX,
          sBottomLineY,
        );
      final secondaryPaint = Paint()
        ..color = secondaryHighlightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = CameraConstants.avatarStrokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(sTopPath, secondaryPaint);
      canvas.drawPath(sBottomPath, secondaryPaint);
    }

    if (isArrowsEnabled) {
      const arrowSize = 14.0;
      final arrowPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = CameraConstants.avatarStrokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final topSeg1 = [
        Offset(leftX, topLineY),
        Offset(leftX, topLineY - topRise * 0.6),
        Offset(midX - ctrlXpx, topApexY),
        Offset(midX, topApexY),
      ];
      final topSeg2 = [
        Offset(midX, topApexY),
        Offset(midX + ctrlXpx, topApexY),
        Offset(rightX, topLineY - topRise * 0.6),
        Offset(rightX, topLineY),
      ];
      final bottomSeg1 = [
        Offset(rightX, bottomLineY),
        Offset(rightX, bottomLineY + bottomRise * 0.6),
        Offset(midX + ctrlXpx, bottomApexY),
        Offset(midX, bottomApexY),
      ];
      final bottomSeg2 = [
        Offset(midX, bottomApexY),
        Offset(midX - ctrlXpx, bottomApexY),
        Offset(leftX, bottomLineY + bottomRise * 0.6),
        Offset(leftX, bottomLineY),
      ];

      for (final (seg, t) in [
        (topSeg1, 0.25),
        (topSeg2, 0.75),
        (bottomSeg1, 0.25),
        (bottomSeg2, 0.75),
      ]) {
        final pt = _bezierPoint(seg, t);
        final tan = _bezierTangent(seg, t);
        final normalAngle = atan2(tan.dy, tan.dx) + pi / 2;

        const arcOffset = 12.0;
        final shifted =
            pt + Offset(cos(normalAngle), sin(normalAngle)) * arcOffset;

        canvas.save();
        canvas.translate(shifted.dx, shifted.dy);
        // 2. разворот: убираем лишний +pi/2, добавляем pi чтобы перевернуть
        canvas.rotate(normalAngle - pi / 2);
        // 3. стрелка с палочкой (tip в (0,0), палочка вниз)
        canvas.drawPath(
          Path()
            ..moveTo(-arrowSize * 0.5, arrowSize) // левое крыло
            ..lineTo(0, 0) // кончик
            ..lineTo(arrowSize * 0.5, arrowSize) // правое крыло
            ..moveTo(0, 0)
            ..lineTo(0, arrowSize * 1.6), // палочка
          arrowPaint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant TwoArcsPainter old) =>
      color != old.color ||
      topRisePx != old.topRisePx ||
      bottomRisePx != old.bottomRisePx ||
      ctrlXpx != old.ctrlXpx ||
      isTopArcHighlighted != old.isTopArcHighlighted ||
      isBottomArcHighlighted != old.isBottomArcHighlighted ||
      isShownSecondaryArcLayer != old.isShownSecondaryArcLayer;
}
