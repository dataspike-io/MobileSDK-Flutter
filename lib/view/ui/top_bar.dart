import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../timer/timer_box.dart';
import 'package:dataspikemobilesdk/view/ui/warning_popup.dart';

class TopBar extends StatelessWidget {
  final bool hasTimer;
  final bool isBackButtonHidden;
  final bool isShowingWarningPopup;

  const TopBar({
    super.key,
    required this.hasTimer,
    this.isBackButtonHidden = false,
    this.isShowingWarningPopup = true,
  });

  void showWarningPopup(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: AppColors.clear,
      barrierColor: AppColors.clear,
      builder: (_) => WarningPopup(parentContext: context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showCenterLogo = !hasTimer && !isBackButtonHidden;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          isBackButtonHidden
              ? const _Logo()
              : IconButton(
                  splashRadius: 24,
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.darkIndigo,
                  ),
                  onPressed: () {
                    if (isShowingWarningPopup) {
                      showWarningPopup(context);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ),
          Expanded(
            child: Center(
              child: hasTimer
                  ? TimeBox(isTitle: true)
                  : (showCenterLogo ? const _Logo() : const SizedBox.shrink()),
            ),
          ),
          Opacity(
            opacity: 0.0,
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'packages/dataspikemobilesdk/assets/images/flags_ae.svg',
                    height: 15,
                    width: 20,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: AppColors.darkIndigo,
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

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'packages/dataspikemobilesdk/assets/images/dataspike_logo.svg',
      height: 16,
      width: 80,
      fit: BoxFit.contain,
    );
  }
}
