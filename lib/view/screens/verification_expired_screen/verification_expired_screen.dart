import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import '../../ui/onboarding/info_card.dart';

class VerificationExpiredScreen extends StatelessWidget {
  const VerificationExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopBar(hasTimer: false, isBackButtonHidden: true),
                    const SizedBox(height: 20),
                    Container(
                      height: 1,
                      width: double.infinity,
                      color: AppColors.snowyLilac,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Verification session expired',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                        fontFamily: 'FunnelDisplay',
                        package: 'dataspikemobilesdk',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your verification took too long and has timed out.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkIndigo,
                        fontFamily: 'Figtree',
                        package: 'dataspikemobilesdk',
                      ),
                    ),
                    const SizedBox(height: 12),
                    InfoCard(
                      title:
                          'Please request a new verification to continue with Company',
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Image.asset(
                  'packages/dataspikemobilesdk/assets/images/verification_expired.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
