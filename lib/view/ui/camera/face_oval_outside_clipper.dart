import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';

class FaceOvalOutsideClipper extends CustomClipper<Path> {
  const FaceOvalOutsideClipper({
    this.topRisePx = 110.0,
    this.bottomRisePx = 110.0,
    this.ctrlXpx = 60.0,
  });

  final double topRisePx;
  final double bottomRisePx;
  final double ctrlXpx;

  @override
  Path getClip(Size size) {
    final fullRect = Path()..addRect(Offset.zero & size);
    final oval = buildFaceOvalPath(
      size,
      topRisePx: topRisePx,
      bottomRisePx: bottomRisePx,
      ctrlXpx: ctrlXpx,
    );
    return Path.combine(PathOperation.difference, fullRect, oval);
  }

  @override
  bool shouldReclip(covariant FaceOvalOutsideClipper old) =>
      topRisePx != old.topRisePx ||
      bottomRisePx != old.bottomRisePx ||
      ctrlXpx != old.ctrlXpx;

  Path buildFaceOvalPath(
    Size size, {
    double topRisePx = 110.0,
    double bottomRisePx = 110.0,
    double ctrlXpx = 60.0,
  }) {
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

    return Path()
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
      )
      ..lineTo(rightX, bottomLineY)
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
      )
      ..close();
  }
}
