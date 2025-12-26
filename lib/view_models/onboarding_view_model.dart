import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:url_launcher/url_launcher.dart';
import '/domain/models/stage_item.dart';

class OnboardingViewModel extends ChangeNotifier {
  bool termsAccepted = false;
  bool dataAccepted = false;

  String verificationUrl = '';
  bool requiresAddress = false;

  List<StageItem> stages = const [];

  OnboardingViewModel() {
    buildStages();
    verificationUrl =
        DataspikeInjector.component.verificationManager.verificationUrl;
  }

  void buildStages() {
    final vm = DataspikeInjector.component.verificationManager.checks;

    final requiresDocument = vm.poiIsRequired;
    final requiresSelfie = vm.livenessIsRequired;

    requiresAddress = vm.poaIsRequired;

    final personalData = vm.personalDataRequired;
    final personalDataDescription = vm.manualFields?.description;

    final list = <StageItem>[
      if (personalData)
        StageItem(
          id: 'personal',
          title: 'Complete your personal details',
          subtitle: personalDataDescription?.isNotEmpty == true
              ? personalDataDescription!
              : 'No additional information needed.',
          required: true,
          completed: false,
        ),
      if (requiresDocument)
        const StageItem(
          id: 'document',
          title: 'Verify your documents',
          subtitle: 'Have your passport or national ID ready.',
          required: true,
          completed: false,
        ),
      if (requiresSelfie)
        const StageItem(
          id: 'selfie',
          title: 'Take a selfie',
          subtitle: 'Use good lighting and a clear background.',
          required: true,
          completed: false,
        ),
      if (requiresAddress)
        const StageItem(
          id: 'address',
          title: 'Confirm your address',
          subtitle:
              'Upload a recent utility bill, bank statement, or other proof of address.',
          required: true,
          completed: false,
        ),
    ];

    stages = list;
    notifyListeners();
  }

  void setTermsAccepted(bool value) {
    termsAccepted = value;
    notifyListeners();
  }

  void setDataAccepted(bool value) {
    dataAccepted = value;
    notifyListeners();
  }

  String get infoCardMessage {
    return requiresAddress
    ? 'The company needs to confirm your identity and address.'
    : 'The company needs to confirm your identity.';
  }

  Future<void> openVerificationUrl() async {
    _openUrl(verificationUrl);
  }

  Future<void> openTermsUrl() async {
    _openUrl("https://dataspike.io/terms?lang=en");
  }

  Future<void> openPrivacyUrl() async {
    _openUrl("https://dataspike.io/privacy?lang=en");
  }

  Future<void> _openUrl(String urlStr) async {
    final url = Uri.parse(urlStr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
