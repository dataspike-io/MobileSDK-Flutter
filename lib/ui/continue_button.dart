import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/colors/app_colors.dart';

class ContinueButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;

  const ContinueButton({
    required this.onPressed,
    this.text = 'Continue',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Mont',
            package: 'dataspikemobilesdk',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}