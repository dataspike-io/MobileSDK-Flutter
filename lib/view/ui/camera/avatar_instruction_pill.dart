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
      width: 240,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.black,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            if (status.image != null) ...[
              SvgPicture.asset(
                status.image!,
                height: 24,
                width: 24,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                status.text,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  fontFamily: 'Figtree',
                  package: 'dataspikemobilesdk',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
