import 'dart:async';
import 'package:dataspikemobilesdk/view_models/verification_completed_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/loader.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import '../../ui/verification_completed/verification_stages_card.dart';
import '../../ui/verification_completed/verification_stage_row.dart';
import '../../ui/verification_completed/info_card_with_subtitle.dart';
import 'package:dataspikemobilesdk/main/coordinator/coordinator.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:dataspikemobilesdk/main/models/dataspike_verifications_status.dart';
import 'package:dataspikemobilesdk/domain/models/states/proceed_with_verification_state.dart';
import 'package:dataspikemobilesdk/view/ui/error/error_image_bottom_sheet.dart';
import 'package:dataspikemobilesdk/data/models/errors/common_errors.dart';

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
    DataspikeCoordinator.finishFlow(
      DataspikeVerificationStatus.verificationCompleted,
    ); // TODO: CHANGE HERE
  }

  @override
  void initState() {
    super.initState();
    viewModel = DataspikeViewModelFactory()
        .create<VerificationCompletedViewModel>();

    _verificationSubscription = viewModel.verificationFlow.listen((
      verificationState,
    ) {
      if (!mounted) return;

      if (verificationState is ProceedWithVerificationStateError &&
          verificationState.shouldNavigateToSelectCountry) {
        if (!mounted) return;
        DataspikeCoordinator.showCountryPicker(
          context,
          title: 'Please, choose your country',
        );
      }

      setState(() {
        _state = verificationState;
      });
    });

    try {
      viewModel.getVerificationCompleted();
    } on NoInternetException {
      _showCommonError(ErrorImageBottomSheetType.noInternet);
    }
  }

  void _showCommonError(ErrorImageBottomSheetType type) {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: AppColors.clear,
      barrierColor: AppColors.clear,
      builder: (_) => ErrorImageBottomSheet(
        type: type,
        onContinue: () {
          Navigator.of(context, rootNavigator: true).pop();
          viewModel.getVerificationCompleted();
        },
      ),
    );
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
      return PopScope(
        canPop: false,
        child: Scaffold(
          body: Center(child: Loader(color: AppColors.slateGray)),
        ),
      );
    }

    if (viewModel.isCustomScreenEnabled) {
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
                      child: VerificationStagesCard(
                        stages: viewModel.stages
                            .map(
                              (s) => VerificationStage(
                                title: s.title
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
        ),
      );
    } else {
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
                        const SizedBox(height: 12),
                        Text(
                          viewModel.submittedDocumentSubtitle,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.darkIndigo,
                            fontFamily: 'Figtree',
                            package: 'dataspikemobilesdk',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: VerificationStagesCard(
                      stages: viewModel.stages
                          .map(
                            (s) => VerificationStage(
                              title: s.title
                            ),
                          )
                          .toList(),
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
}
