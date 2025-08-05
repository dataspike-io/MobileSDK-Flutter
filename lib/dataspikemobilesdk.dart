
import 'dataspikemobilesdk_platform_interface.dart';
import 'package:flutter/material.dart';
import 'screens/onboarding_screen.dart';

class Dataspikemobilesdk {
  Future<String?> getPlatformVersion() {
    return DataspikemobilesdkPlatform.instance.getPlatformVersion();
  }

  static Future<void> navigateToMyScreen(BuildContext context) async {
    await Navigator.of(context).push(OnboardingScreen.route());
  }
}
