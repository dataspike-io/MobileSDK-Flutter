import 'dart:async';
import 'package:dataspikemobilesdk/view_models/verification_completed_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/loader.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import '../../ui/verification_completed/stages_card.dart';
import '../../ui/verification_completed/info_card_with_subtitle.dart';
import '../../ui/onboarding/stage_row.dart';
import 'package:dataspikemobilesdk/main/coordinator/coordinator.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dataspikemobilesdk/main/models/dataspike_verifications_status.dart';

class VerificationCompletedScreen extends StatefulWidget {
  const VerificationCompletedScreen({super.key});

  @override
  State<VerificationCompletedScreen> createState() =>
      _VerificationCompletedScreenState();
}

class _VerificationCompletedScreenState
    extends State<VerificationCompletedScreen> {
  late final VerificationCompletedViewModel viewModel;

  StreamSubscription? _verificationSubscription;
  Object? _state;

  void _onFinish() {
    viewModel.openUrl();
    DataspikeCoordinator.finishFlow(DataspikeVerificationStatus.verificationCompleted); // TODO: CHANGE HERE
  }

  @override
  void initState() {
    super.initState();
    viewModel = DataspikeViewModelFactory()
        .create<VerificationCompletedViewModel>();

    _verificationSubscription = viewModel.verificationFlow.listen((
      verificationState,
    ) {
      setState(() {
        _state = verificationState;
      });
    });

    viewModel.getVerificationCompleted();
  }

  @override
  void dispose() {
    _verificationSubscription?.cancel();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;

    if (state == null) {
      return Scaffold(
        body: Center(child: Loader(color: AppColors.slateGray)),
      );
    }

    if (viewModel.isCustomScreenEnabled) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TopBar(timer: null, isBackButtonHidden: true),
                      const SizedBox(height: 20),
                      Container(
                        height: 1,
                        width: double.infinity,
                        color: AppColors.snowyLilac,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          fontFamily: 'FunnelDisplay',
                          package: 'dataspikemobilesdk',
                        ),
                      ),
                      const SizedBox(height: 12),
                      InfoCardWithSubtitle(
                        title: viewModel.subtitle,
                        subtitle: viewModel.redirectWarning,
                        copyValue: viewModel.link,
                        linkText: 'Save link on status page',
                      ),
                    ],
                  ),
                ),
              ),
              if (viewModel.isButtonAndStagesShown)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: StagesCard(
                      stages: viewModel.stages
                          .map(
                            (s) => Stage(
                              title: s.title,
                              subtitle: s.subtitle,
                              isCompleted: s.completed,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              if (viewModel.isButtonAndStagesShown)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  sliver: SliverToBoxAdapter(
                    child: ContinueButton(
                      onPressed: _onFinish,
                      text: viewModel.continueButtonText,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 64),
                Icon(Icons.check_circle, color: AppColors.mediumSeaGreen, size: 56),
                const SizedBox(height: 24),
                Text(
                  'Thank you!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    fontFamily: 'FunnelDisplay',
                    package: 'dataspikemobilesdk',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have successfully uploaded all required documents.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.darkIndigo,
                    fontFamily: 'FunnelDisplay',
                    package: 'dataspikemobilesdk',
                  ),
                ),
                const Spacer(),
                  ContinueButton(
                    onPressed: _onFinish,
                    text: 'Continue',
                  ),
                const SizedBox(height: 24),
                SvgPicture.asset(
                  'packages/dataspikemobilesdk/assets/images/dataspike_logo.svg',
                  height: 16,
                  width: 80,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    }
  }
}
