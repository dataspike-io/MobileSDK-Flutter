import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'section_header.dart';
import 'stage_row.dart';

class StagesCard extends StatelessWidget {
  final List<Stage> stages;
  final String placeholderAsset;
  final bool accepted;
  final ValueChanged<bool> onAcceptChanged;
  final VoidCallback? onStartPressed;
  final VoidCallback openTerms;
  final VoidCallback openPrivacy;

  const StagesCard({
    required this.stages,
    required this.placeholderAsset,
    required this.accepted,
    required this.onAcceptChanged,
    required this.onStartPressed,
    required this.openTerms,
    required this.openPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.palePeriwinkle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: SectionHeader()),
              const SizedBox(width: 12),
              SizedBox(
                width: 65,
                height: 65,
                child: SvgPicture.asset(placeholderAsset, fit: BoxFit.contain),
              ),
            ],
          ),
          const SizedBox(height: 26),
          ...stages.map((s) => StageRow(stage: s)),

          // const SizedBox(height: 46),
          const Spacer(),

          InkWell(
            onTap: () => onAcceptChanged(!accepted),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.deepViolet, width: 1.4),
                    color: accepted ? AppColors.deepViolet : Colors.transparent,
                  ),
                  child: accepted
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: AppColors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'I accept ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.black,
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w400,
                            package: 'dataspikemobilesdk',
                          ),
                        ),
                        TextSpan(
                          text: 'terms & services',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.black,
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w400,
                            package: 'dataspikemobilesdk',
                          ),
                          recognizer: TapGestureRecognizer()..onTap = openTerms,
                        ),
                        const TextSpan(
                          text: ' and ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.black,
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w400,
                            package: 'dataspikemobilesdk',
                          ),
                        ),
                        TextSpan(
                          text: 'privacy policy',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.black,
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w400,
                            package: 'dataspikemobilesdk',
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = openPrivacy,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ContinueButton(onPressed: onStartPressed, text: "Start verification"),
        ],
      ),
    );
  }
}