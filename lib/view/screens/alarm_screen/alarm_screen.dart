import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/timer/timer_box.dart';

class VerificationExpiredScreen extends StatelessWidget {
  const VerificationExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(16, topPadding, 16, 32),
          child: Column(
            children: [
              const Text(
                "Your verification link has expired",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Mont',
                  fontWeight: FontWeight.w500,
                  package: 'dataspikemobilesdk',
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 12),

              TimeBox(initialTime: Duration(), onFinish: () { }),

              const SizedBox(height: 12),

              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 110,
                    width: 110,
                    child: SvgPicture.asset(
                      'packages/dataspikemobilesdk/assets/images/alarm.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),

              Spacer(),

              // Кнопка
              SizedBox(
                height: 44,
                width: double.infinity,
                child: ContinueButton(onPressed: () {}, text: "Complete"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
