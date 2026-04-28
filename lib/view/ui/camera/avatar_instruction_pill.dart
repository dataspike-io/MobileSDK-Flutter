import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';

class AvatarInstructionPill extends StatelessWidget {
  final AvatarDetectionStatus status;

  const AvatarInstructionPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: status.backgroundColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AppColors.white.withOpacity(0.4), width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.12),
              blurRadius: 10.5,
              offset: const Offset(0, 9),
            ),
            BoxShadow(
              color: AppColors.black.withOpacity(0.06),
              blurRadius: 0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: status.subtitle == null
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (status.image != null) ...[
                  SvgPicture.asset(
                    status.image!,
                    height: 24,
                    width: 24,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  status.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.none,
                    fontFamily: 'Figtree',
                    package: 'dataspikemobilesdk',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            const SizedBox(width: 4),
            if (status.subtitle != null)
              Text(
                status.subtitle!,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                  fontFamily: 'Figtree',
                  package: 'dataspikemobilesdk',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
