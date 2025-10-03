import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class InfoCardWithoutImage extends StatelessWidget {
  final String title;

  const InfoCardWithoutImage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mistyLilac,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.darkIndigo,
            fontFamily: 'Figtree',
            package: 'dataspikemobilesdk',
            fontWeight: FontWeight.w500,
          ),
        ),
    );
  }
}
