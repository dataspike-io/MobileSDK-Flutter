import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

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
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.royalPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Figtree',
            package: 'dataspikemobilesdk',
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}