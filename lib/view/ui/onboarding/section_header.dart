import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow this stages',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            fontFamily: 'FunnelDisplay',
            package: 'dataspikemobilesdk',
          ),
        ),
        Text(
          'Check what documents you’ll needed',
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'Figtree',
            package: 'dataspikemobilesdk',
            fontWeight: FontWeight.w500,
            color: AppColors.darkIndigo,
          ),
        ),
      ],
    );
  }
}