import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class InfoCard extends StatelessWidget {  
  final String title;

  const InfoCard({
    super.key,
    required this.title
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mistyLilac,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(
            'packages/dataspikemobilesdk/assets/images/jp_logo.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.darkIndigo,
                fontFamily: 'Figtree',
                package: 'dataspikemobilesdk',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}