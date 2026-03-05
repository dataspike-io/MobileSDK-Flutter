import 'package:flutter/material.dart';
import '../../../ui/top_bar.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:dataspikemobilesdk/main/coordinator/coordinator.dart';
import 'package:lottie/lottie.dart';

class LivenessInstructionScreen extends StatefulWidget {
  const LivenessInstructionScreen({super.key});

  @override
  State<LivenessInstructionScreen> createState() =>
      _LivenessInstructionScreenState();
}

class _LivenessInstructionScreenState extends State<LivenessInstructionScreen> {
  void _onContinue() {
    DataspikeCoordinator.proceedNext(
      context,
      after: DataspikeStep.selfieInstruction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              TopBar(hasTimer: true),
              Expanded(
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Check this before we continue',
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'FunnelDisplay',
                          package: 'dataspikemobilesdk',
                        ),
                      ),
                      const SizedBox(height: 32.0),
                      Lottie.asset(
                        'packages/dataspikemobilesdk/assets/animations/liveness-check-animation.json',
                        width: 150,
                        height: 150,
                        fit: BoxFit.fill,
                      ),
                      const SizedBox(height: 20.0),
                      Text(
                        'Place your entire face\ninside mask',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Figtree',
                          package: 'dataspikemobilesdk',
                        ),
                      ),
                      const SizedBox(height: 41.0),
                      Text(
                        'Turn smartphone display brightness high',
                        maxLines: 2,
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Figtree',
                          package: 'dataspikemobilesdk',
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Text(
                        'Find a place with a great light',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Figtree',
                          package: 'dataspikemobilesdk',
                        ),
                      ),
                      const SizedBox(height: 15.0),
                      Text(
                        'Follow instructions',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Figtree',
                          package: 'dataspikemobilesdk',
                        ),
                      ),
                      const SizedBox(height: 71.0),
                      ContinueButton(text: 'Start', onPressed: _onContinue),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
