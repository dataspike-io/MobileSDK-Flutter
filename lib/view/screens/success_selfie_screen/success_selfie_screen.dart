import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import 'package:dataspikemobilesdk/main/coordinator/coordinator.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SuccessSelfieScreen extends StatefulWidget {
  const SuccessSelfieScreen({super.key});

  @override
  State<SuccessSelfieScreen> createState() => _SuccessSelfieScreenState();
}

class _SuccessSelfieScreenState extends State<SuccessSelfieScreen> {
  void _onFinish() {
    DataspikeCoordinator.proceedNext(
      context,
      after: DataspikeStep.successSelfie,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TopBar(hasTimer: true, isBackButtonHidden: false),

                const SizedBox(height: 119),

                SvgPicture.asset(
                  'packages/dataspikemobilesdk/assets/images/success_selfie.svg',
                  width: 94,
                  height: 94,
                  alignment: Alignment.center,
                ),

                const SizedBox(height: 8),

                Text(
                  "Liveness check passed",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    fontFamily: 'FunnelDisplay',
                    package: 'dataspikemobilesdk',
                  ),
                ),

                const SizedBox(height: 21),

                Text(
                  "Continue verification process",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                    fontFamily: 'Figtree',
                    package: 'dataspikemobilesdk',
                  ),
                ),

                const Spacer(),

                ContinueButton(onPressed: _onFinish, text: "Continue"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
