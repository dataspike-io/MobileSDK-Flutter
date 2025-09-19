import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ErrorBottomSheet extends StatelessWidget {
  const ErrorBottomSheet({required this.title, required this.message});

  final String title;
  final String message;

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
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
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
                      title,
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
                      message,
                      style: const TextStyle(
                        color: AppColors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Figtree',
                        package: 'dataspikemobilesdk',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
