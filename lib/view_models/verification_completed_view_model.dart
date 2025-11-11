import 'dart:async';
import 'package:dataspikemobilesdk/data/use_cases/proceed_with_verification_use_case.dart';
import 'package:dataspikemobilesdk/domain/models/finish_screen_settings_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/states/proceed_with_verification_state.dart';
import '/domain/models/stage_item.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:url_launcher/url_launcher.dart';

class VerificationCompletedViewModel {
  final ProceedWithVerificationUseCase getProceedWithVerificationUseCase;
  final _verificationController = StreamController<ProceedWithVerificationState>.broadcast();

  Stream<ProceedWithVerificationState> get verificationFlow => _verificationController.stream;

  VerificationCompletedViewModel({
    required this.getProceedWithVerificationUseCase,
  }) {
    buildStagesAndFinishScreen();
  }

  Future<void> getVerificationCompleted() async {
    final state = await getProceedWithVerificationUseCase.call();
    _verificationController.add(state);
  }

  void dispose() {
    _verificationController.close();
  }

  FinishScreenSettingsDomainModel? finishScreenSettings;
  List<StageItem> stages = const [];

  String get title {
    final settings = finishScreenSettings;
    final t = settings?.title?.trim();
    if (settings?.enabled == true && t != null && t.isNotEmpty) {
      return t;
    }
    return 'All set!\nVerification submitted';
  }

  String get subtitle {
    final settings = finishScreenSettings;
    final t = settings?.mainText?.trim();
    if (settings?.enabled == true && t != null && t.isNotEmpty) {
      return t;
    }
    return 'We’ve received your documents and are processing them for J.P. Morgan.';
  }

  String get submittedDocumentSubtitle {
    return 'Information submitted';
  }

  String? get redirectWarning {
    return finishScreenSettings?.redirectWarning?.trim();
  }

  String? get link {
    return finishScreenSettings?.redirectLink?.trim();
  }

  String get continueButtonText {
    return finishScreenSettings?.cta?.trim() ?? 'Continue';
  }

   bool get isCustomScreenEnabled {
    return (finishScreenSettings?.enabled == true);
  }

  bool get isButtonAndStagesShown {
    return (redirectWarning?.isEmpty == true) 
    || (link?.isEmpty == true);
  }
  
  Future<void> openUrl() async {
    final url = Uri.parse(link ?? '');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void buildStagesAndFinishScreen() {
    final vm = DataspikeInjector.component.verificationManager;

    final requiresDocument = vm.checks.poiIsRequired;
    final requiresSelfie = vm.checks.livenessIsRequired;
    final requiresAddress = vm.checks.poaIsRequired;
    final personalData = vm.checks.personalDataRequired;
    final personalDataDescription = vm.checks.manualFields?.description;
    finishScreenSettings = vm.finishScreenSettings;

    final list = <StageItem>[
      if (personalData)
        StageItem(
          id: 'personal',
          title: 'Fill in your details',
          subtitle: personalDataDescription?.isNotEmpty == true ? personalDataDescription! : 'Nothing extra needed',
          required: true,
          completed: true,
        ),
      if (requiresDocument)
        const StageItem(
          id: 'document',
          title: 'Scan your ID',
          subtitle: 'You’ll need passport or ID to make photo.',
          required: true,
          completed: true,
        ),
      if (requiresSelfie)
        const StageItem(
          id: 'selfie',
          title: 'Take a selfie',
          subtitle: 'Use a plain background and good lighting.',
          required: true,
          completed: true,
        ),
      if (requiresAddress)
        const StageItem(
          id: 'address',
          title: 'Confirm your address',
          subtitle: 'Upload a recent utility bill or bank statement.',
          required: true,
          completed: true,
        ),
    ];

    stages = list;
  }
}