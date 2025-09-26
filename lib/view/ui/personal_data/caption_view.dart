import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class Caption extends StatelessWidget {
  final String text;
  const Caption({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontFamily: 'Figtree',
        package: 'dataspikemobilesdk',
        fontWeight: FontWeight.w500,
        color: AppColors.darkIndigo,
      ),
    );
  }
}