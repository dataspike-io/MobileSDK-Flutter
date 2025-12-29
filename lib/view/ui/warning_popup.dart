import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';

class WarningPopup extends StatelessWidget {
  final BuildContext parentContext;

  const WarningPopup({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        width: double.infinity,
        height: h * 0.5,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
              BoxShadow(
                color: AppColors.shadowBlack,
                blurRadius: 30,
                spreadRadius: 0,
                offset: Offset(0, -14),
              ),
            ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () =>
                              Navigator.of(parentContext, rootNavigator: true)
                                  .pop(),
                          child: SvgPicture.asset(
                            'packages/dataspikemobilesdk/assets/images/cross_circled.svg',
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 11),
                    Text(
                      "Go back to the previous step?",
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Figtree',
                        package: 'dataspikemobilesdk',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 11),
                    Text(
                      "If you return, you'll need to redo the previous step from the start.",
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Figtree',
                        package: 'dataspikemobilesdk',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    ContinueButton(
                      onPressed: () =>
                          Navigator.of(parentContext, rootNavigator: true)
                              .pop(),
                      text: 'Stay here',
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 60.0,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(parentContext, rootNavigator: true).pop();
                            Navigator.of(parentContext, rootNavigator: true).pop();
                          },
                          child: Text(
                            'Go back',
                            style: TextStyle(
                              color: AppColors.royalPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Figtree',
                              package: 'dataspikemobilesdk',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
}
