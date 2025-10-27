import 'dart:async';
import 'package:dataspikemobilesdk/main/manager/dataspike_manager.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view/screens/dataspike_screen/dataspike_screen.dart';
import 'package:dataspikemobilesdk/view/screens/onboarding_screen/onboarding_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_avatar_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_document_screen.dart';
import 'package:dataspikemobilesdk/view/screens/personal_data_screen/personal_data_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/domain/models/document_type.dart';
import 'package:dataspikemobilesdk/view/screens/verification_completed_screen/verification_completed_screen.dart';
import 'package:dataspikemobilesdk/main/models/dataspike_verifications_status.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_access/camera_access_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/camera_access/camera_denied_screen.dart';
import 'package:dataspikemobilesdk/view/screens/verification_expired_screen/verification_expired_screen.dart';
import 'package:dataspikemobilesdk/view/screens/camera/instruction_screen/instruction_screen.dart';
import 'package:dataspikemobilesdk/domain/models/instruction_type.dart';
import 'package:dataspikemobilesdk/view/screens/countries_screen/countries_screen.dart';

enum DataspikeStep {
  onboarding,
  personalData,
  documentInstruction,
  selfieInstruction,
  poaInstruction,
  documentCamera,
  selfieCamera,
  address,
  verificationCompleted,
  cameraAccess,
  cameraDenied,
  verificationExpired
}

class DataspikeCoordinator {
  static BuildContext? _flowContext;
  static Timer? _verificationExpiryTimer;
  
  static bool _lifecycleObserverAttached = false;
  static final WidgetsBindingObserver _lifecycleObserver =
      _CoordinatorLifecycleObserver(_onAppResumed);

  static void _bindFlowContext(BuildContext context) {
      _flowContext = Navigator.of(context).context;
  }

  static void _cancelVerificationExpiryWatch({bool clearContext = false}) {
    _verificationExpiryTimer?.cancel();
    _verificationExpiryTimer = null;

    if (_lifecycleObserverAttached) {
      WidgetsBinding.instance.removeObserver(_lifecycleObserver);
      _lifecycleObserverAttached = false;
    }

    if (clearContext) _flowContext = null;
  }

  static void scheduleVerificationExpiryWatch() {
    final ctx = _flowContext;
    if (ctx == null) return;

    _verificationExpiryTimer?.cancel();

    final vm = DataspikeInjector.component.verificationManager;
    final ms = vm.millisecondsUntilVerificationExpired;
    if (ms <= 0) {
      if (ctx.mounted) {
        showVerificationExpiredScreen(ctx);
      }
      return;
    }

    _verificationExpiryTimer = Timer(Duration(milliseconds: ms), () {
      final c = _flowContext;
      if (c != null && c.mounted) {
        showVerificationExpiredScreen(c);
      }
    });
  }

  static void startFlow(BuildContext context) {
    if (!_lifecycleObserverAttached) {
      WidgetsBinding.instance.addObserver(_lifecycleObserver);
      _lifecycleObserverAttached = true;
    }

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
        
        // TODO: IN CASE OF REMOVING ONBOARDING CHANGE PLACE OF CALLING
        _bindFlowContext(context);
        scheduleVerificationExpiryWatch();
        break;
      case DataspikeStep.personalData:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PersonalDataScreen()));
        break;
      case DataspikeStep.cameraAccess:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CameraAccessScreen(),
          ),
        );
        break;
      case DataspikeStep.cameraDenied:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const CameraDeniedScreen(),
          ),
        );
        break;
      case DataspikeStep.documentInstruction:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const InstructionScreen(type: InstructionType.poi),
          ),
        );
        break;
      case DataspikeStep.documentCamera:
        Navigator.of(context).push(
          MaterialPageRoute(
            maintainState: false,
            builder: (_) =>
                const LiveCropCamera(docType: DocumentType.identity),
          ),
        );
        break;
      case DataspikeStep.selfieInstruction:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const InstructionScreen(type: InstructionType.liveness),
          ),
        );
        break;
      case DataspikeStep.poaInstruction:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                const InstructionScreen(type: InstructionType.poa),
          ),
        );
        break;
      case DataspikeStep.selfieCamera:
        Navigator.of(
          context,
        ).push(
          MaterialPageRoute(
            maintainState: false,
            builder: (_) => const LiveAvatarCamera()
          )
        );
        break;
      case DataspikeStep.address:
        Navigator.of(context).push(
          MaterialPageRoute(
            maintainState: false,
            builder: (_) => const LiveCropCamera(docType: DocumentType.address),
          ),
        );
        break;
      case DataspikeStep.verificationCompleted:
        _cancelVerificationExpiryWatch(clearContext: true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const VerificationCompletedScreen(),
          ),
          (route) => false,
        );
        break;
      case DataspikeStep.verificationExpired:
        _cancelVerificationExpiryWatch(clearContext: true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const VerificationExpiredScreen(),
          ),
          (route) => false,
        );
        break;  
    }
  }

  static List<DataspikeStep> _requiredSteps()  {
    final vm = DataspikeInjector.component.verificationManager.checks;

    final requiresDocument = vm.poiIsRequired;
    final requiresSelfie = vm.livenessIsRequired;
    final requiresAddress = vm.poaIsRequired;
    final personalData = vm.personalDataRequired;

    final steps = <DataspikeStep>[];
    if (personalData) steps.add(DataspikeStep.personalData);

    if (requiresDocument || requiresSelfie) {
      final cameraStatus = DataspikeInjector.component.permissionService.initialStatus;

      switch (cameraStatus) {
        case PermissionStatus.restricted:
        case PermissionStatus.permanentlyDenied:
          steps.add(DataspikeStep.cameraDenied);
        case PermissionStatus.granted:
          break;
        case PermissionStatus.denied:
        case PermissionStatus.limited:
        default:
          steps.add(DataspikeStep.cameraAccess);
      }
    }
    if (requiresDocument) {
      steps.add(DataspikeStep.documentInstruction);
      steps.add(DataspikeStep.documentCamera);
    }
    if (requiresSelfie) {
      steps.add(DataspikeStep.selfieInstruction);
      steps.add(DataspikeStep.selfieCamera);
    }
    if (requiresAddress) {
      steps.add(DataspikeStep.poaInstruction);
      steps.add(DataspikeStep.address);
    }

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

  static void showCameraAccessScreen(BuildContext context) =>
      showNextStep(context, DataspikeStep.cameraAccess);

  static void showCameraDeniedScreen(BuildContext context) =>
      showNextStep(context, DataspikeStep.cameraDenied);

  static void showVerificationExpiredScreen(BuildContext context) =>
      showNextStep(context, DataspikeStep.verificationExpired);

  static void showDocumentInstructionScreen(
    BuildContext context,
    InstructionType type,
  ) {
    switch (type) {
      case InstructionType.poi:
        showNextStep(context, DataspikeStep.documentInstruction);
        break;
      case InstructionType.liveness:
        showNextStep(context, DataspikeStep.selfieInstruction);
        break;
      case InstructionType.poa:
        showNextStep(context, DataspikeStep.poaInstruction);
        break;
    }
  }

  static void finishFlow(DataspikeVerificationStatus status) {
    _cancelVerificationExpiryWatch(clearContext: true);
    DataspikeManager.passVerificationCompletedResult(status);
  }

  static void _onAppResumed() {
    scheduleVerificationExpiryWatch();
  }

  static Future<String?> showCountryPicker(
    BuildContext context, {
    required String title,
    ValueChanged<String>? onSelected,
  }) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CountryPickerScreen(
          title: title,
          onCountrySelected: onSelected,
        ),
      ),
    );
  }
}

class _CoordinatorLifecycleObserver with WidgetsBindingObserver {
  final VoidCallback onResumed;
  _CoordinatorLifecycleObserver(this.onResumed);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}