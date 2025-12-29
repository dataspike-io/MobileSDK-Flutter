import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';

class ErrorImageBottomSheet extends StatelessWidget {
  const ErrorImageBottomSheet({super.key, required this.type, this.onContinue});

  final ErrorImageBottomSheetType type;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    // final w = MediaQuery.of(context).size.width;

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        // width: w,
        height: h * 0.8,
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
              padding: const EdgeInsets.fromLTRB(0, 24.0, 0, 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () => Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop(),
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
                            type.title,
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'FunnelDisplay',
                              package: 'dataspikemobilesdk',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 11),
                          Text(
                            type.message,
                            style: const TextStyle(
                              color: AppColors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Figtree',
                              package: 'dataspikemobilesdk',
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                    SizedBox(
                      // height: h * 0.6,
                      child: Image.asset(type.image, fit: BoxFit.contain),
                    ),

                    const SizedBox(height: 11),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0),
                      child: ContinueButton(
                        text: 'Refresh',
                        onPressed: onContinue,
                      ),
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

enum ErrorImageBottomSheetType {
  noInternet;

  String get title {
    switch (this) {
      case ErrorImageBottomSheetType.noInternet:
        return 'Internet connection lost';
    }
  }

  String get message {
    switch (this) {
      case ErrorImageBottomSheetType.noInternet:
        return 'It seems that you experiencing problems with internet connection. Try to restore it and continue verification process';
    }
  }

  String get image {
    switch (this) {
      case ErrorImageBottomSheetType.noInternet:
        return 'packages/dataspikemobilesdk/assets/images/no_internet.png';
    }
  }
}
