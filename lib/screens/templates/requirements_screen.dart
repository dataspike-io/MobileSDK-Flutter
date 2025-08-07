import 'package:dataspikemobilesdk/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Requirement {
  final String image;
  final String text;

  Requirement({required this.image, required this.text});
}

class DocumentRequirementsScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Requirement> requirements;
  final VoidCallback onContinue;

  const DocumentRequirementsScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.requirements,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPadding, 16, 0),
          decoration: const BoxDecoration(color: AppColors.white),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'Mont',
                            package: 'dataspikemobilesdk',
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontFamily: 'Mont',
                                  package: 'dataspikemobilesdk',
                                  color: AppColors.textGrey,
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                          ),
                        ),
                        SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 6,
                                childAspectRatio: 1,
                              ),
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final r = requirements[index];
                            return RequirementBox(
                              image: r.image,
                              label: r.text,
                            );
                          }, childCount: requirements.length),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(height: 70),
                        ), // отступ под кнопку
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 24,
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: onContinue,
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          fontFamily: 'Mont',
                          package: 'dataspikemobilesdk',
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.white,
                        ),
                      ),
                    ),
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

class RequirementBox extends StatelessWidget {
  final String image;
  final String label;

  const RequirementBox({required this.image, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SvgPicture.asset(
            image,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.fill, // или BoxFit.cover для полного заполнения
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          width: double.infinity,
          child: Text(
            label,
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Mont',
              package: 'dataspikemobilesdk',
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: AppColors.black,
            ),
          ),
        ),
      ],
    );
  }
}
