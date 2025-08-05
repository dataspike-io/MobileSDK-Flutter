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
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(color: AppColors.white),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: SvgPicture.asset(
                          'packages/dataspikemobilesdk/assets/images/back_arrow.svg',
                          width: 36,
                          height: 36,
                          fit: BoxFit.fill,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
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
                  Expanded(
                    child: GridView.builder(
                      itemCount: requirements.length,
                      padding: EdgeInsets.only(bottom: 70),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 6,
                          ),
                      itemBuilder: (context, index) {
                        final r = requirements[index];
                        return RequirementBox(image: r.image, label: r.text);
                      },
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
