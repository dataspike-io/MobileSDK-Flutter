import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../timer/timer_box.dart';

class TopBar extends StatelessWidget {
  final Duration? timer;
  final bool isBackButtonHidden;

  const TopBar({
    super.key,
    required this.timer,
    this.isBackButtonHidden = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasTimer = timer != null;
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
                    color: AppColors.darkGrey,
                  ),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
          Expanded(
            child: Center(
              child: hasTimer
                  ? TimeBox(
                      initialTime: timer!,
                      onFinish: () {
                        Navigator.of(context).maybePop();
                      },
                      isTitle: true,
                    )
                  : (showCenterLogo ? const _Logo() : const SizedBox.shrink()),
            ),
          ),
          GestureDetector(
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
                  color: AppColors.darkGrey,
                ),
              ],
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
