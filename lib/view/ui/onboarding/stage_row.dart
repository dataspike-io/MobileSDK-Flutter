import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Stage {
  final String title;
  final String subtitle;
  final bool isCompleted;
  const Stage({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });
}

class StageRow extends StatelessWidget {
  final Stage stage;
  const StageRow({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24.0,
            decoration: BoxDecoration(
              color: stage.isCompleted
                  ? AppColors.mediumSeaGreen
                  : AppColors.softLavender,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'packages/dataspikemobilesdk/assets/images/onboarding_unchecked.svg',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      fontFamily: 'Figtree',
                      package: 'dataspikemobilesdk',
                    ),
                  ),
                  Text(
                    stage.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkIndigo,
                      fontFamily: 'Figtree',
                      package: 'dataspikemobilesdk',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
