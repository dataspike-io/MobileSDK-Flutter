import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view/screens/dataspike_screen/dataspike_screen.dart';
import 'package:dataspikemobilesdk/view/screens/onboarding_screen/onboarding_screen.dart';

class DataspikeCoordinator {
  static void startFlow(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DataspikeScreen(
          onSuccess: (context) {
            _showOnboarding(context);
          },
          onFail: (context) {
            // Handle failure
          },
        ),
      ),
    );
  }

  static void _showOnboarding(
    BuildContext context
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingScreen(),
      ),
    );
  }
}