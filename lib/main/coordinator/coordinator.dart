import 'package:dataspikemobilesdk/main/manager/dataspike_manager.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view/screens/dataspike_screen/dataspike_screen.dart';
import 'package:dataspikemobilesdk/view/screens/onboarding_screen/onboarding_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_avatar_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_document_screen.dart';
import 'package:dataspikemobilesdk/view/screens/personal_data_screen/personal_data_screen.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/domain/models/document_type.dart';
import 'package:dataspikemobilesdk/view/screens/verification_completed_screen/verification_completed_screen.dart';
import 'package:dataspikemobilesdk/main/models/dataspike_verifications_status.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_access/camera_access_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_access/camera_denied_screen.dart';
import 'package:dataspikemobilesdk/view/screens/verification_expired_screen/verification_expired_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/instruction_screen/instruction_screen.dart';
import 'package:dataspikemobilesdk/domain/models/instruction_type.dart';

enum DataspikeStep {
  onboarding,
  personalData,
  documentInstructionScreen,
  selfieInstructionScreen,
  documentCamera,
  selfieCamera,
  address,
  verificationCompleted,
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
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PersonalDataScreen()));
        break;
      case DataspikeStep.documentInstructionScreen:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const InstructionScreen(type: InstructionType.poi),
          ),
        );
        break;
      case DataspikeStep.documentCamera:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const LiveCropCamera(docType: DocumentType.identity),
          ),
        );
        break;
      case DataspikeStep.selfieInstructionScreen:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const InstructionScreen(type: InstructionType.liveness),
          ),
        );
        break;
      case DataspikeStep.selfieCamera:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const LiveAvatarCamera()));
        break;
      case DataspikeStep.address:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const LiveCropCamera(docType: DocumentType.address),
          ),
        );
        break;
      case DataspikeStep.verificationCompleted:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const VerificationCompletedScreen(),
          ),
          (route) => false,
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
    if (requiresDocument) {
      steps.add(DataspikeStep.documentInstructionScreen);
      steps.add(DataspikeStep.documentCamera);
    }
    if (requiresSelfie) {
      steps.add(DataspikeStep.selfieInstructionScreen);
      steps.add(DataspikeStep.selfieCamera);
    }
    if (requiresAddress) steps.add(DataspikeStep.address);
    steps.add(DataspikeStep.verificationCompleted);
    return steps;
  }

  static void proceedNext(BuildContext context, {DataspikeStep? after}) {
    final steps = _requiredSteps();
    if (steps.isEmpty) {
      showNextStep(context, DataspikeStep.verificationCompleted);
      return;
    }

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
    } else {
      showNextStep(context, DataspikeStep.verificationCompleted);
    }
  }

  static void showOnboarding(BuildContext context) =>
      showNextStep(context, DataspikeStep.onboarding);
  static void showSelfieCamera(BuildContext context) =>
      showNextStep(context, DataspikeStep.selfieCamera);
  static void showDocumentCamera(BuildContext context) =>
      showNextStep(context, DataspikeStep.documentCamera);
  static void showPersonalData(BuildContext context) =>
      showNextStep(context, DataspikeStep.personalData);
  static void showVerificationCompleted(BuildContext context) =>
      showNextStep(context, DataspikeStep.verificationCompleted);

  static void showAddressScreen(BuildContext context) =>
      showNextStep(context, DataspikeStep.address);

  static void showDocumentInstructionScreen(
    BuildContext context,
    InstructionType type,
  ) => {
    if (type == InstructionType.poi)
      showNextStep(context, DataspikeStep.documentInstructionScreen)
    else if (type == InstructionType.liveness)
      showNextStep(context, DataspikeStep.selfieInstructionScreen),
  };

  static void finishFlow(DataspikeVerificationStatus status) {
    DataspikeManager.passVerificationCompletedResult(status);
  }
}
