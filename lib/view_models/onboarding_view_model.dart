import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:url_launcher/url_launcher.dart';
import '/domain/models/stage_item.dart';

class OnboardingViewModel extends ChangeNotifier {
  bool termsAccepted = false;
  bool dataAccepted = false;

  String verificationUrl = '';


  List<StageItem> stages = const [];
  
  OnboardingViewModel() {
    buildStages();
    verificationUrl = DataspikeInjector.component.verificationManager.verificationUrl;
  }

  void buildStages() {
    final vm = DataspikeInjector.component.verificationManager.checks;

    final requiresDocument = vm.poiIsRequired;
    final requiresSelfie = vm.livenessIsRequired;
    final requiresAddress = vm.poaIsRequired;
    final personalData = vm.personalDataRequired;
    final personalDataDescription = vm.manualFields?.description;

    final list = <StageItem>[
      if (personalData)
        StageItem(
          id: 'personal',
          title: 'Fill in your details',
          subtitle: personalDataDescription?.isNotEmpty == true ? personalDataDescription! : 'Nothing extra needed',
          required: true,
          completed: false,
        ),
      if (requiresDocument)
        const StageItem(
          id: 'document',
          title: 'Scan your ID',
          subtitle: 'You’ll need passport or ID to make photo.',
          required: true,
          completed: false,
        ),
      if (requiresSelfie)
        const StageItem(
          id: 'selfie',
          title: 'Take a selfie',
          subtitle: 'Use a plain background and good lighting.',
          required: true,
          completed: false,
        ),
      if (requiresAddress)
        const StageItem(
          id: 'address',
          title: 'Confirm your address',
          subtitle: 'Upload a recent utility bill or bank statement.',
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