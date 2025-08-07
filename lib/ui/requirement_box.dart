import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/colors/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RequirementBox extends StatelessWidget {
  final String image;
  final String label;

  const RequirementBox({required this.image, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SvgPicture.asset(
            image,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          width: double.infinity,
          child: Text(
            label,
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Mont',
              package: 'dataspikemobilesdk',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }
}
