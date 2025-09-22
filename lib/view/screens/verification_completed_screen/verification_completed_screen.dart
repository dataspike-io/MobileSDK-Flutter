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
    DataspikeCoordinator.proceedNext(context);
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
                      'Title',
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
                      title: 'We’re now processing your documents for J.P. Morgan.',
                      subtitle: 'You can track your verification status on this page, and we’ll also notify you by email when the status changes.',
                      copyValue: 'https://example.com',
                      linkText: 'Save link on status page',
                    ),
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
                      child: StagesCard(
                        stages: viewModel.stages
                            .map(
                              (s) =>
                                  Stage(title: s.title, subtitle: s.subtitle),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ContinueButton(
            onPressed: _onFinish,
            text: "CTA",
          ),
          ],
        ),
      ),
    );
  }
}