import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class Label extends StatelessWidget {
  final String text;
  const Label({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontFamily: 'Figtree',
        package: 'dataspikemobilesdk',
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    );
  }
}