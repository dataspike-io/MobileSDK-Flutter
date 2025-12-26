import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view/timer/timer_box.dart';
import '/view_models/onboarding_view_model.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import '../../ui/onboarding/stages_card_with_terms.dart';
import '../../ui/onboarding/info_card.dart';
import '../../ui/onboarding/stage_row.dart';
import 'package:dataspikemobilesdk/main/coordinator/coordinator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = DataspikeViewModelFactory().create<OnboardingViewModel>();
    viewModel.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    viewModel.removeListener(_onVmChanged);
    super.dispose();
  }

  void _onVmChanged() => setState(() {});

  void _onStart() {
    DataspikeCoordinator.proceedNext(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool accepted = viewModel.termsAccepted && viewModel.dataAccepted;

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                      TopBar(hasTimer: false, isBackButtonHidden: true),
                      const SizedBox(height: 8),
                      Text(
                        'Verify your identity',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                          fontFamily: 'FunnelDisplay',
                          package: 'dataspikemobilesdk',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(children: [TimeBox(isTitle: false)]),
                      const SizedBox(height: 12),
                      InfoCard(title: viewModel.infoCardMessage),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: StagesCardWithTerms(
                          stages: viewModel.stages
                              .map(
                                (s) => Stage(
                                  title: s.title,
                                  subtitle: s.subtitle,
                                  isCompleted: s.completed,
                                ),
                              )
                              .toList(),
                          placeholderAsset:
                              'packages/dataspikemobilesdk/assets/images/dinosaur.svg',
                          accepted: accepted,
                          onAcceptChanged: (v) {
                            viewModel.setTermsAccepted(v);
                            viewModel.setDataAccepted(v);
                          },
                          onStartPressed: accepted ? _onStart : null,
                          openTerms: () => viewModel.openTermsUrl(),
                          openPrivacy: () => viewModel.openPrivacyUrl(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SizedBox(
                          height: 40,
                          child: TextButton(
                            onPressed: viewModel.openVerificationUrl,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.deepViolet,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Continue verification on a desktop',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Figtree',
                                package: 'dataspikemobilesdk',
                              ),
                            ),
                          ),
                        ),
                      ),
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
