import 'package:dataspikemobilesdk/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dataspikemobilesdk/ui/dashboard_underline_text.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:dataspikemobilesdk/screens/templates/requirements_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => const OnboardingScreen());
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool termsAccepted = true;
  bool dataAccepted = true;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _slides = [
    _OnboardingSlide(
      image: 'packages/dataspikemobilesdk/assets/images/onboarding_1.svg',
      text: 'Step 1. Prepare a valid identity document',
    ),
    _OnboardingSlide(
      image: 'packages/dataspikemobilesdk/assets/images/onboarding_2.svg',
      text: 'Step 2. Be prepared to take Selfie',
    ),
    _OnboardingSlide(
      image: 'packages/dataspikemobilesdk/assets/images/onboarding_3.svg',
      text: 'Step 3. Prepare a proof of Address document',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Spacer(),
                const Text(
                  "Let's get you verified",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Mont',
                    fontWeight: FontWeight.w500,
                    package: 'dataspikemobilesdk',
                    color: AppColors.black
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Swipeable block (PageView + dots)
                SizedBox(
                  height: 238,
                  width: double.infinity,
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _slides.length,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            final slide = _slides[index];
                            return Column(
                              children: [
                                SvgPicture.asset(
                                  slide.image,
                                  height: 130,
                                  width: 160,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  height: 52,
                                  width: 222,
                                  child: Text(
                                    slide.text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: AppColors.black,
                                      fontFamily: 'Mont',
                                      fontWeight: FontWeight.w500,
                                      package: 'dataspikemobilesdk'
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.accent
                                  : AppColors.lightAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                // Checkbox 1
                CustomCheckboxTile(
                  value: termsAccepted,
                  onChanged: (v) => setState(() => termsAccepted = v ?? false),
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'I accept ',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                          fontFamily: 'Mont',
                          fontWeight: FontWeight.w500,
                          package: 'dataspikemobilesdk',
                        ),
                      ),
                      TextSpan(
                        text: 'Terms and Conditions',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontFamily: 'Mont',
                          fontWeight: FontWeight.w500,
                          package: 'dataspikemobilesdk',
                          fontSize: 12,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final url = Uri.parse(
                              "https://dataspike.io/terms?lang=en",
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Checkbox 2
                CustomCheckboxTile(
                  value: dataAccepted,
                  onChanged: (v) => setState(() => dataAccepted = v ?? false),
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'I agree to processing my ',
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                          fontFamily: 'Mont',
                          fontWeight: FontWeight.w500,
                          package: 'dataspikemobilesdk',
                        ),
                      ),
                      TextSpan(
                        text: 'Personal Data',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontFamily: 'Mont',
                          fontWeight: FontWeight.w500,
                          package: 'dataspikemobilesdk',
                          fontSize: 12,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final url = Uri.parse(
                              "https://dataspike.io/privacy?lang=en",
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Requirements with dashed underline
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => documentRequirementsScreen,
                      ),
                    );
                  },
                  child: const DashedUnderlineText(
                    text: 'Requirements',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontFamily: 'Mont',
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      letterSpacing: 0.2,
                    ),
                    dashColor: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 44,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: termsAccepted && dataAccepted ? () {} : null,
                    child: const Text(
                      'Start Verification',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white,
                        fontFamily: 'Mont',
                        fontWeight: FontWeight.w500,
                        package: 'dataspikemobilesdk',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final documentRequirementsScreen = DocumentRequirementsScreen(
  title: 'Document Requirements',
  subtitle: 'To confirm your identity, we need you to upload a valid document. Check out the requirements below',
  requirements: [
    Requirement(
      image: 'packages/dataspikemobilesdk/assets/images/document_requirements_1.svg',
      text: 'Original, full-size, unedited document',
    ),
    Requirement(
      image: 'packages/dataspikemobilesdk/assets/images/document_requirements_2.svg',
      text: 'No black and white images',
    ),
    Requirement(
      image: 'packages/dataspikemobilesdk/assets/images/document_requirements_3.svg',
      text: 'No dark images',
    ),
    Requirement(
      image: 'packages/dataspikemobilesdk/assets/images/document_requirements_4.svg',
      text: 'No blurred and without reflections',
    ),
    Requirement(
      image: 'packages/dataspikemobilesdk/assets/images/document_requirements_5.svg',
      text: 'No damaged documents',
    ),
    Requirement(
      image: 'packages/dataspikemobilesdk/assets/images/document_requirements_6.svg',
      text: 'No expired documents',
    ),
  ],
  onContinue: () {
    /* ... */
  },
);

class _OnboardingSlide {
  final String image;
  final String text;
  const _OnboardingSlide({required this.image, required this.text});
}

class CustomCheckboxTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final InlineSpan text;

  const CustomCheckboxTile({
    required this.value,
    required this.onChanged,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(1),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.accent, width: 1),
                color: Colors.transparent,
              ),
              alignment: Alignment.center,
              child: value
                  ? SvgPicture.asset(
                      'packages/dataspikemobilesdk/assets/images/check_icon.svg',
                      height: 8.5,
                      width: 12,
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(text: text, textAlign: TextAlign.left),
          ),
        ],
      ),
    );
  }
}
