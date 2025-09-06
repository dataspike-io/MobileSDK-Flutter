import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view/screens/dataspike_screen/dataspike_screen.dart';
import 'package:dataspikemobilesdk/view/screens/onboarding_screen/onboarding_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_avatar_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_document_screen.dart';
import 'package:dataspikemobilesdk/view/screens/personal_data_screen/personal_data_screen.dart';

enum DataspikeStep {
  onboarding,
  personalData,
  selfieCamera,
  documentCamera,
}

class DataspikeCoordinator {
  static void startFlow(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DataspikeScreen(
          onSuccess: (context) {
            showNextStep(context, DataspikeStep.onboarding);
          },
          onFail: (context) {
            // Handle failure
          },
        ),
      ),
    );
  }

  static void showNextStep(BuildContext context, DataspikeStep step) {
    switch (step) {
      case DataspikeStep.onboarding:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OnboardingScreen(
              onStart: () => showNextStep(context, DataspikeStep.personalData),
            ),
          ),
        );
        break;
      case DataspikeStep.personalData:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PersonalDataScreen()),
        );
        break;
      case DataspikeStep.selfieCamera:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LiveAvatarCamera(onCropped: (value) {}),
          ),
        );
        break;
      case DataspikeStep.documentCamera:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => LiveCropCamera(onCropped: (value) {}),
          ),
        );
        break;
    }
  }

  static void _showOnboarding(BuildContext context) =>
      showNextStep(context, DataspikeStep.onboarding);

  static void showSelfieCamera(BuildContext context) =>
      showNextStep(context, DataspikeStep.selfieCamera);

  static void showDocumentCamera(BuildContext context) =>
      showNextStep(context, DataspikeStep.documentCamera);

  static void showPersonalData(BuildContext context) =>
      showNextStep(context, DataspikeStep.personalData);
}
