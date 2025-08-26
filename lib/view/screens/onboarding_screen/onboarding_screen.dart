import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:dataspikemobilesdk/view/screens/builders/screens_factory.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:dataspikemobilesdk/view/timer/timer_box.dart';
import 'package:dataspikemobilesdk/view/screens/alarm_screen/alarm_screen.dart';
import 'package:dataspikemobilesdk/view/screens/recommendations_screen/recommendations_screen.dart';
import '/view_models/onboarding_view_model.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  static Route route() => MaterialPageRoute<void>(builder: (_) => const OnboardingScreen());

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingViewModel viewModel;

  // Один дефолтный ассет для всех иллюстраций (замени путём на существующий у тебя).
  static const String _placeholderAsset = 'assets/images/onboarding_placeholder.svg';

  // Ступени (данные для списка).
  final List<_Stage> _stages = const [
    _Stage(
      title: 'Complete your personal data',
      subtitle: 'No special needed',
    ),
    _Stage(
      title: 'Verify your documents',
      subtitle: 'You’ll need passport or ID to make photo.',
    ),
    _Stage(
      title: 'Make a selfie',
      subtitle: 'Please use clear background and daylight',
    ),
    _Stage(
      title: 'Confirm your address',
      subtitle: 'No special needed',
    ),
  ];

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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DocumentRecomendationScreen(),
      ),
    );
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: c.maxHeight - 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Верх (логотип / можно вставить AppBar отдельно если нужно)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Лого (замени при необходимости)
                        Text(
                          'dataspike',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                            fontFamily: 'Mont',
                            package: 'dataspikemobilesdk',
                          ),
                        ),
                        // Флаг / язык (упрощённый placeholder)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.lightAccent.withOpacity(.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flag, size: 16, color: AppColors.accent),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.accent),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Заголовок блока
                    Text(
                      'Get verified for\nJP Morgan application',
                      style: TextStyle(
                        fontSize: 28,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        fontFamily: 'Mont',
                        package: 'dataspikemobilesdk',
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (timer != null)
                      Row(
                        children: [
                          Text(
                            'Remaining time ',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.accent,
                              fontFamily: 'Mont',
                              fontWeight: FontWeight.w500,
                              package: 'dataspikemobilesdk',
                            ),
                          ),
                          TimeBox(
                            initialTime: timer,
                            onFinish: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (_) => const VerificationExpiredScreen(),
                                ),
                                (r) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),

                    // Инфо карточка
                    _InfoCard(
                      asset: _placeholderAsset,
                      text:
                          'JP Morgan requests proof of address verification and documents check to complete bank account opening.',
                    ),
                    const SizedBox(height: 28),

                    // Карточка со стадиями и чекбоксом + кнопкой
                    _StagesCard(
                      stages: _stages,
                      placeholderAsset: _placeholderAsset,
                      accepted: accepted,
                      onAcceptChanged: (v) {
                        viewModel.setTermsAccepted(v);
                        viewModel.setDataAccepted(v);
                      },
                      onRequirementsTap: _onRequirementsTap,
                      onStartPressed: accepted ? _onStart : null,
                      openTerms: () => _openUrl("https://dataspike.io/terms?lang=en"),
                      openPrivacy: () => _openUrl("https://dataspike.io/privacy?lang=en"),
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
  final String asset;
  final String text;
  const _InfoCard({required this.asset, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightAccent.withOpacity(.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              asset,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
            const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: AppColors.black,
                fontFamily: 'Mont',
                fontWeight: FontWeight.w500,
                package: 'dataspikemobilesdk',
              ),
            ),
          )
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
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 26),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.lightAccent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок + иллюстрация справа
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SectionHeader(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...stages.map((s) => _StageRow(stage: s)).toList(),
          const SizedBox(height: 20),
          // Единый чекбокс
          InkWell(
            onTap: () => onAcceptChanged(!accepted),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 20,
                  height: 20,
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
                            color: AppColors.textGrey,
                            fontFamily: 'Mont',
                            fontWeight: FontWeight.w500,
                            package: 'dataspikemobilesdk',
                          ),
                        ),
                        TextSpan(
                          text: 'terms & services',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.accent,
                            fontFamily: 'Mont',
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            package: 'dataspikemobilesdk',
                          ),
                          recognizer: TapGestureRecognizer()..onTap = openTerms,
                        ),
                        const TextSpan(
                          text: ' and ',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                            fontFamily: 'Mont',
                            fontWeight: FontWeight.w500,
                            package: 'dataspikemobilesdk',
                          ),
                        ),
                        TextSpan(
                          text: 'privacy policy',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.accent,
                            fontFamily: 'Mont',
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            package: 'dataspikemobilesdk',
                          ),
                          recognizer: TapGestureRecognizer()..onTap = openPrivacy,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: ContinueButton(
              onPressed: onStartPressed,
              text: "Start verification",
            ),
          ),
          const SizedBox(height: 18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Иконка чек (пока всегда одинаковая — можно связать с прогрессом)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.lightAccent.withOpacity(.55),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check, size: 18, color: AppColors.accent.withOpacity(.9)),
          ),
          const SizedBox(width: 14),
            Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Mont',
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    package: 'dataspikemobilesdk',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stage.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    fontFamily: 'Mont',
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey,
                    package: 'dataspikemobilesdk',
                  ),
                ),
              ],
            ),
          )
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
            fontFamily: 'Mont',
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            package: 'dataspikemobilesdk',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Check what documents you’ll needed',
          style: TextStyle(
            fontSize: 13,
            fontFamily: 'Mont',
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
            package: 'dataspikemobilesdk',
          ),
        ),
      ],
    );
  }
}
