import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dataspikemobilesdk/view/ui/camera/additional/swipable_view.dart';
import 'package:dataspikemobilesdk/domain/models/instruction_type.dart';

class ErrorBottomSheet extends StatelessWidget {
  const ErrorBottomSheet({
    super.key,
    required this.title,
    required this.message,
    this.instruction,
  });

  final String title;
  final String message;
  final InstructionType? instruction;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        width: double.infinity,
        // height: instruction == null ? h * 0.5 : h * 0.8,
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
                        fontFamily: 'FunnelDisplay',
                        package: 'dataspikemobilesdk',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.transparentRed,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      width: double.infinity,
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: AppColors.lightRed,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Figtree',
                          package: 'dataspikemobilesdk',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32), // Add for case without instruction

                    // if (instruction != null) ...[
                    //   const SizedBox(height: 32),
                    //   SizedBox(
                    //     height: h * 0.6,
                    //     child: SwipableView(
                    //       type: instruction!,
                    //       isError: true,
                    //       isShowingTitle: false,
                    //     ),
                    //   ),
                    // ],
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
