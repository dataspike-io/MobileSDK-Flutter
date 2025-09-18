import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view/screens/dataspike_screen/dataspike_screen.dart';
import 'package:dataspikemobilesdk/view/screens/onboarding_screen/onboarding_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_avatar_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_document_screen.dart';
import 'package:dataspikemobilesdk/view/screens/personal_data_screen/personal_data_screen.dart';
import '/dependencies_provider/dataspike_injector.dart';

enum DataspikeStep {
  onboarding,
  personalData,
  documentCamera,
  selfieCamera,
  address,
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
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          (route) => false,
        );
        break;
      case DataspikeStep.personalData:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const PersonalDataScreen()),
        );
        break;
      case DataspikeStep.documentCamera:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LiveCropCamera()),
        );
        break;
      case DataspikeStep.selfieCamera:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LiveAvatarCamera()),
        );
        break;
      case DataspikeStep.address:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LiveCropCamera()),
        );
        break;
    }
  }

  static List<DataspikeStep> _requiredSteps() {
    final vm = DataspikeInjector.component.verificationManager.checks;
 
    final requiresDocument = vm.poiIsRequired;
    final requiresSelfie = vm.livenessIsRequired;
    final requiresAddress = vm.poaIsRequired;
    final personalData = vm.personalDataRequired;

    final steps = <DataspikeStep>[];
    if (personalData) steps.add(DataspikeStep.personalData);
    if (requiresDocument) steps.add(DataspikeStep.documentCamera);
    if (requiresSelfie) steps.add(DataspikeStep.selfieCamera);
    if (requiresAddress) steps.add(DataspikeStep.address);
    return steps;
  }

  static void proceedNext(BuildContext context, {DataspikeStep? after}) {
    final steps = _requiredSteps();
    if (steps.isEmpty) return;

    DataspikeStep? next;
    if (after == null) {
      next = steps.first; 
    } else {
      final idx = steps.indexOf(after);
      if (idx >= 0 && idx + 1 < steps.length) {
        next = steps[idx + 1];
      }
    }

    if (next != null) {
      showNextStep(context, next);
    } else {  }
  }

  static void showOnboarding(BuildContext context) =>
      showNextStep(context, DataspikeStep.onboarding);
  static void showSelfieCamera(BuildContext context) =>
      showNextStep(context, DataspikeStep.selfieCamera);
  static void showDocumentCamera(BuildContext context) =>
      showNextStep(context, DataspikeStep.documentCamera);
  static void showPersonalData(BuildContext context) =>
      showNextStep(context, DataspikeStep.personalData);
}
