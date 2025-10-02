import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/domain/models/instruction_type.dart';

class _InstructionSlide {
  final String imageAsset;
  final String hint;
  const _InstructionSlide({required this.imageAsset, required this.hint});
}

class SwipableView extends StatefulWidget {
  final InstructionType type;

  const SwipableView({super.key, required this.type});

  final List<_InstructionSlide> _defaultPoiSlides = const [
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/poi_instruction_1.png',
      hint:
          'Front-side only. Follow the instructions below to make sure your document photo is accepted.',
    ),
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/poi_instruction_2.png',
      hint: 'No blurry image, glare, reflection, low contrast',
    ),
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/poi_instruction_3.png',
      hint:
          'No incomplete document, faded text, obstructed information or incorrect perspective',
    ),
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/poi_instruction_4.png',
      hint:
          'No watermarks or stamps covering crucial details, non-standard or expired.',
    ),
  ];

  final List<_InstructionSlide> _defaultLivenessSlides = const [
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/liveness_instruction_1.png',
      hint: 'Place your face fully to mask for recognition',
    ),
    _InstructionSlide(
      imageAsset:
          'packages/dataspikemobilesdk/assets/images/liveness_instruction_2.png',
      hint: 'Place your face fully to mask for recognition',
    ),
  ];

  List<_InstructionSlide> get _slides => (type == InstructionType.liveness)
      ? _defaultLivenessSlides
      : _defaultPoiSlides;

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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      slide.hint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        fontFamily: 'Figtree',
                        package: 'dataspikemobilesdk',
                      ),
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
          padding:  const EdgeInsets.symmetric(horizontal: 20),
          child:  _DotsIndicator(count: slides.length, index: _page),
        )
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
