import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/domain/models/instruction_type.dart';

class _InstructionSlide {
  final String imageAsset;
  final String title;
  final String hint;
  const _InstructionSlide({
    required this.imageAsset,
    required this.title,
    required this.hint,
  });
}

class SwipableView extends StatefulWidget {
  final InstructionType type;
  final bool isError;
  final bool isShowingTitle;

  const SwipableView({
    super.key,
    required this.type,
    this.isError = false,
    this.isShowingTitle = true,
  });

  final List<_InstructionSlide> _defaultPoiSlides = const [
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/poi_instruction_1.png',
      title: 'Take a photo of your ID',
      hint:
          'Front side only. Follow the instructions below to make sure your document photo is accepted.',
    ),
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/poi_instruction_2.png',
      title: 'The image must be of good quality',
      hint: 'Avoid blur, glare, reflections, or low contrast.',
    ),
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/poi_instruction_3.png',
      title: 'Ensure the entire document is visible',
      hint: 'Avoid faded text, cut corners, or tilted angles.',
    ),
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/poi_instruction_4.png',
      title: 'Use a valid, original document',
      hint: 'Avoid watermarks, stickers, or anything covering details.',
    ),
  ];

  final List<_InstructionSlide> _defaultLivenessSlides = const [
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/liveness_instruction_1.png',
      title: 'Take a selfie',
      hint: 'Look straight at the camera with your face centered in the frame.',
    ),
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/liveness_instruction_2.png',
      title: 'How to place',
      hint: 'Center your face in the frame so we can recognize it clearly.',
    ),
  ];

  final List<_InstructionSlide> _defaultPoaSlides = const [
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/poa_instruction_1.png',
      title: 'Upload a document to prove your address',
      hint: 'You can use a bank statement, utility bill, or lease agreement.',
    ),
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/poa_instruction_2.png',
      title: 'Be careful and use actual documents',
      hint:
          'Documents should be actual — last 3 months for utility bills, bank statements or an active lease agreement.',
    ),
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/poa_instruction_3.png',
      title: 'Check data on your documents',
      hint:
          'Make sure your name and address match those on your identity document.',
    ),
  ];

  List<_InstructionSlide> get _slides => switch (type) {
    InstructionType.liveness => _defaultLivenessSlides,
    InstructionType.poi => _defaultPoiSlides,
    InstructionType.poa => _defaultPoaSlides,
  };

  @override
  State<SwipableView> createState() => _SwipableViewState();
}

class _SwipableViewState extends State<SwipableView> {
  late final PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = widget._slides;
    if (slides.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final slide = slides[index];
              return Column(
                children: [
                  if (widget.isShowingTitle) ...[
                    Text(
                      slide.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        fontFamily: 'FunnelDisplay',
                        package: 'dataspikemobilesdk',
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    slide.hint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.isError
                          ? AppColors.lightRed
                          : AppColors.black,
                      fontFamily: 'Figtree',
                      package: 'dataspikemobilesdk',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Image.asset(
                      slide.imageAsset,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _DotsIndicator(count: slides.length, index: _page),
        ),
      ],
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  final int count;
  final int index;

  const _DotsIndicator({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
        (i) => Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: 4,
            decoration: BoxDecoration(
              color: i == index ? AppColors.royalPurple : AppColors.cadetBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
