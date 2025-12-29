import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter/gestures.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'section_header.dart';
import 'stage_row.dart';

class StagesCardWithTerms extends StatefulWidget {
  final List<Stage> stages;
  final String placeholderAsset;
  final bool accepted;
  final ValueChanged<bool> onAcceptChanged;
  final VoidCallback? onStartPressed;
  final VoidCallback openTerms;
  final VoidCallback openPrivacy;

  const StagesCardWithTerms({
    super.key,
    required this.stages,
    required this.placeholderAsset,
    required this.accepted,
    required this.onAcceptChanged,
    required this.onStartPressed,
    required this.openTerms,
    required this.openPrivacy,
  });

  @override
  State<StagesCardWithTerms> createState() => _StagesCardWithTermsState();
}

class _StagesCardWithTermsState extends State<StagesCardWithTerms> {
  bool _showAcceptError = false;

  void _toggleAccept() {
    final next = !widget.accepted;
    widget.onAcceptChanged(next);
    if (next) {
      setState(() => _showAcceptError = false);
    }
  }

  void _handleStart() {
    if (!widget.accepted) {
      setState(() => _showAcceptError = true);
      return;
    }
    widget.onStartPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final highlight = _showAcceptError && !widget.accepted;

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
                child: SvgPicture.asset(widget.placeholderAsset, fit: BoxFit.contain),
              ),
            ],
          ),
          const SizedBox(height: 26),
          ...widget.stages.map((s) => StageRow(stage: s)),
          const Spacer(),
          InkWell(
            onTap: _toggleAccept,
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: widget.accepted ? AppColors.deepViolet : AppColors.clear,
                    border: Border.all(
                      color: highlight ? AppColors.lightRed : AppColors.deepViolet,
                      width: 2,
                    ),
                  ),
                  child: widget.accepted
                      ? const Icon(Icons.check, size: 16, color: AppColors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'I accept the ',
                          style: TextStyle(
                            fontSize: 12,
                            color: highlight ? AppColors.lightRed : AppColors.black,
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w400,
                            package: 'dataspikemobilesdk',
                          ),
                        ),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.royalPurple,
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.royalPurple,
                            package: 'dataspikemobilesdk',
                          ),
                          recognizer: TapGestureRecognizer()..onTap = widget.openTerms,
                        ),
                        TextSpan(
                          text: ' and ',
                          style: TextStyle(
                            fontSize: 12,
                            color: highlight ? AppColors.lightRed : AppColors.black,
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w400,
                            package: 'dataspikemobilesdk',
                          ),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.royalPurple,
                            fontFamily: 'Figtree',
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.royalPurple,
                            package: 'dataspikemobilesdk',
                          ),
                          recognizer: TapGestureRecognizer()..onTap = widget.openPrivacy,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ContinueButton(
            onPressed: _handleStart,
            text: "Start verification",
          ),
        ],
      ),
    );
  }
}
