import 'dart:async';
import 'package:dataspikemobilesdk/data/use_cases/proceed_with_verification_use_case.dart';
import 'package:dataspikemobilesdk/domain/models/finish_screen_settings_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/states/proceed_with_verification_state.dart';
import '/domain/models/verification_stage_item.dart';
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
  List<VerificationStageItem> stages = const [];

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
    return 'Company received your documents and processing them now';
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
    finishScreenSettings = vm.finishScreenSettings;

    final list = <VerificationStageItem>[
      if (personalData)
        VerificationStageItem(
          title: 'Personal details',
        ),
      if (requiresDocument)
        const VerificationStageItem(
          title: 'Identity Documents',
        ),
      if (requiresSelfie)
        const VerificationStageItem(
          title: 'Liveness check',
        ),
      if (requiresAddress)
        const VerificationStageItem(
          title: 'Proof of address',
        ),
    ];

    stages = list;
  }
}