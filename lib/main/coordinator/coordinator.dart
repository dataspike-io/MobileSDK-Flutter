import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view/screens/dataspike_screen/dataspike_screen.dart';
import 'package:dataspikemobilesdk/view/screens/onboarding_screen/onboarding_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_avatar_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_document_screen.dart';
import 'package:dataspikemobilesdk/view/screens/personal_data_screen/personal_data_screen.dart';

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

  static void _showOnboarding(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingScreen(
          onStart: () {
            showPersonalData(context);
          },
        ),
      ),
    );
  }

  static void showSelfieCamera(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LiveAvatarCamera(onCropped: (value) {}),
      ),
    );
  }

  static void showDocumentCamera(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LiveCropCamera(onCropped: (value) {})),
    );
  }

  static void showPersonalData(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PersonalDataScreen()));
  }
}
