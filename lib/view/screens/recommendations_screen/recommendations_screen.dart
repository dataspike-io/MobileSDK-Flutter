import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dataspikemobilesdk/view/screens/builders/screens_factory.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:dataspikemobilesdk/view/ui/dashboard_underline_text.dart';
import 'package:dataspikemobilesdk/view/ui/rich_title.dart';
import 'package:dataspikemobilesdk/view/ui/tab_chip.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_screen.dart';

class DocumentRecomendationScreen extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onRedo;
  final VoidCallback? onContinue;
  // final ImageProvider image;
  final String title;
  final String linkWord;
  final double step_1_3;

  const DocumentRecomendationScreen({
    super.key,
    // required this.image,
    this.onBack,
    this.onRedo,
    this.onContinue,
    this.title = 'Please take a photo of the document front side',
    this.linkWord = 'front',
    this.step_1_3 = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPadding, 16, 32),
          decoration: const BoxDecoration(color: AppColors.white),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: SvgPicture.asset(
                          'packages/dataspikemobilesdk/assets/images/back_arrow.svg',
                          width: 24,
                          height: 30,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichTitle(full: title, linkWord: linkWord),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    child: Row(
                      children: const [
                        TabChip(text: 'Document', active: true),
                        SizedBox(width: 8),
                        TabChip(text: 'Selfie'),
                        SizedBox(width: 8),
                        TabChip(text: 'Address'),
                      ],
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              RequirementScreenFactory.documentRequirementsScreen(
                                context: context,
                                onContinue: () {},
                              ),
                        ),
                      );
                    },
                    child: const DashedUnderlineText(
                      text: 'Requirements',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontFamily: 'Mont',
                        package: 'dataspikemobilesdk',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                      dashColor: AppColors.accent,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ContinueButton(onPressed: () {
                     Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                           LiveCropCamera(
                            cropBox: const Size(260, 360),
                            onCropped: (bytes) { }
                           )
                      )
                     );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// — helpers —
