import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter/material.dart';

class TabChip extends StatelessWidget {
  final String text;
  final bool active;
  final double progress;
  final Color progressColor;

  const TabChip({
    required this.text,
    this.active = false,
    this.progress = 0.0,
    this.progressColor = Colors.green,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'Mont',
            fontSize: 12,
            package: 'dataspikemobilesdk',
            color: active ? AppColors.accent : AppColors.lightGrey,
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            width: 91,
            child: LinearProgressIndicator(
              minHeight: 6,
              value: progress.clamp(0, 1),
              backgroundColor: active ? AppColors.accent : AppColors.lightGrey,
            ),
          ),
        ),
      ],
    );
  }
}
