import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class CircularContinueButton extends StatelessWidget {
  const CircularContinueButton({
    super.key,
    required this.onPressed,
    this.size = 60,
    this.backgroundColor = AppColors.royalPurple,
    this.disabledBackgroundColor = AppColors.snowyLilac,
    this.ringColor = AppColors.white,
    this.ringWidth = 2,
    this.ringDiameterFraction = 0.4,
    this.child,
  });

  final VoidCallback? onPressed;
  final double size;
  final Color backgroundColor;
  final Color disabledBackgroundColor;
  final Color ringColor;
  final double ringWidth;
  final double ringDiameterFraction;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ringSize = (size * ringDiameterFraction).clamp(0.0, size);

    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: disabledBackgroundColor,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          elevation: 0,
          minimumSize: Size(size, size),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: ringSize,
              height: ringSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: ringWidth),
              ),
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
