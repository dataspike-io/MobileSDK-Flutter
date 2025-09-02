import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:dataspikemobilesdk/view/screens/builders/screens_factory.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:dataspikemobilesdk/view/timer/timer_box.dart';
import 'package:dataspikemobilesdk/view/screens/alarm_screen/alarm_screen.dart';
import '/view_models/onboarding_view_model.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.onStart, 
  });

  final VoidCallback? onStart;

  static Route route({VoidCallback? onStart}) =>
      MaterialPageRoute<void>(builder: (_) => OnboardingScreen(onStart: onStart));

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = DataspikeViewModelFactory().create<OnboardingViewModel>();
    viewModel.setVerificationTimer();
    viewModel.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    viewModel.removeListener(_onVmChanged);
    super.dispose();
  }

  void _onVmChanged() => setState(() {});

  Future<void> _openUrl(String urlStr) async {
    final url = Uri.parse(urlStr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _onRequirementsTap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            RequirementScreenFactory.documentRequirementsScreen(
              context: context,
              onContinue: () {},
            ),
      ),
    );
  }

  void _onStart() {
    // Локальная логика перед стартом (если нужна)
    widget.onStart?.call();
  }

  @override
  Widget build(BuildContext context) {
    final timer = viewModel.timerDuration;

    final bool accepted = viewModel.termsAccepted && viewModel.dataAccepted;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, c) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 26),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight - 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(
                          'packages/dataspikemobilesdk/assets/images/dataspike_logo.svg',
                          height: 16,
                          width: 80,
                          fit: BoxFit.contain,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
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
                                color: AppColors.accent,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: AppColors.lightAccent.withOpacity(.1),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Get verified for\nJP Morgan application',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        // fontFamily: 'Mont',
                        // package: 'dataspikemobilesdk',
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (timer != null)
                      Row(
                        children: [
                          TimeBox(
                            initialTime: timer,
                            onFinish: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const VerificationExpiredScreen(),
                                ),
                                (r) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),

                    _InfoCard(),
                    const SizedBox(height: 16),

                    _StagesCard(
                      stages: viewModel.stages
                          .map(
                            (s) => _Stage(title: s.title, subtitle: s.subtitle),
                          )
                          .toList(),
                      placeholderAsset:
                          'packages/dataspikemobilesdk/assets/images/dinosaur.svg',
                      accepted: accepted,
                      onAcceptChanged: (v) {
                        viewModel.setTermsAccepted(v);
                        viewModel.setDataAccepted(v);
                      },
                      onStartPressed: accepted ? _onStart : null, // изменено
                      onRequirementsTap: _onRequirementsTap,
                      openTerms: () =>
                          _openUrl("https://dataspike.io/terms?lang=en"),
                      openPrivacy: () =>
                          _openUrl("https://dataspike.io/privacy?lang=en"),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Stage {
  final String title;
  final String subtitle;
  const _Stage({required this.title, required this.subtitle});
}

class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightAccent.withOpacity(.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Image.asset(
            'packages/dataspikemobilesdk/assets/images/jp_logo.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'JP Morgan requests proof of address verification and documents check to complete bank account opening.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
                // fontFamily: 'Mont',
                fontWeight: FontWeight.w500,
                // package: 'dataspikemobilesdk',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StagesCard extends StatelessWidget {
  final List<_Stage> stages;
  final String placeholderAsset;
  final bool accepted;
  final ValueChanged<bool> onAcceptChanged;
  final VoidCallback? onStartPressed;
  final VoidCallback onRequirementsTap;
  final VoidCallback openTerms;
  final VoidCallback openPrivacy;

  const _StagesCard({
    required this.stages,
    required this.placeholderAsset,
    required this.accepted,
    required this.onAcceptChanged,
    required this.onStartPressed,
    required this.onRequirementsTap,
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
        border: Border.all(color: AppColors.lightAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _SectionHeader()),
              const SizedBox(width: 12),
              SizedBox(
                width: 65,
                height: 65,
                child: SvgPicture.asset(
                  placeholderAsset,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          ...stages.map((s) => _StageRow(stage: s)),
          const SizedBox(height: 46),

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
                    border: Border.all(
                      color: accepted ? AppColors.accent : AppColors.accent,
                      width: 1.4,
                    ),
                    color: accepted ? AppColors.accent : Colors.transparent,
                  ),
                  child: accepted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
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
                            // fontFamily: 'Mont',
                            fontWeight: FontWeight.w400,
                            // package: 'dataspikemobilesdk',
                          ),
                        ),
                        TextSpan(
                          text: 'terms & services',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.black,
                            // fontFamily: 'Mont',
                            fontWeight: FontWeight.w400,
                            // package: 'dataspikemobilesdk',
                          ),
                          recognizer: TapGestureRecognizer()..onTap = openTerms,
                        ),
                        const TextSpan(
                          text: ' and ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.black,
                            // fontFamily: 'Mont',
                            fontWeight: FontWeight.w400,
                            // package: 'dataspikemobilesdk',
                          ),
                        ),
                        TextSpan(
                          text: 'privacy policy',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.black,
                            // fontFamily: 'Mont',
                            fontWeight: FontWeight.w400,
                            // package: 'dataspikemobilesdk',
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
          ContinueButton(
              onPressed: onStartPressed,
              text: "Start verification",
            ),
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  final _Stage stage;
  const _StageRow({required this.stage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.lightAccent.withOpacity(.55),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset('packages/dataspikemobilesdk/assets/images/onboarding_unchecked.svg')
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.title,
                  style: TextStyle(
                    fontSize: 14,
                    // fontFamily: 'Mont',
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    // package: 'dataspikemobilesdk',
                  ),
                ),
                Text(
                  stage.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    // height: 1.3,
                    // fontFamily: 'Mont',
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                    // package: 'dataspikemobilesdk',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow this stages',
          style: TextStyle(
            fontSize: 20,
            // fontFamily: 'Mont',
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            // package: 'dataspikemobilesdk',
          ),
        ),
        Text(
          'Check what documents you’ll needed',
          style: TextStyle(
            fontSize: 12,
            // fontFamily: 'Mont',
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
            // package: 'dataspikemobilesdk',
          ),
        ),
      ],
    );
  }
}
