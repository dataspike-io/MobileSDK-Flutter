import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingViewModel extends ChangeNotifier {
  bool termsAccepted = true;
  bool dataAccepted = true;

  String verificationUrl = '';

  Duration? timerDuration;

  List<StageItem> stages = const [];
  
  OnboardingViewModel() {
    setVerificationTimer();
    buildStages();
    verificationUrl = DataspikeInjector.component.verificationManager.checks.verificationUrl;
  }

  void setVerificationTimer() {
    final verificationManager = DataspikeInjector.component.verificationManager;
    final millisecondsUntilVerificationExpired =
        verificationManager.millisecondsUntilVerificationExpired;
    timerDuration = Duration(
      milliseconds: millisecondsUntilVerificationExpired,
    );
    notifyListeners();
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
          subtitle: personalDataDescription ?? 'Nothing extra needed',
          required: true,
          completed: true,
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

  // void onTimerFinish(BuildContext context) {
  //   Navigator.of(context).pushAndRemoveUntil(
  //     MaterialPageRoute(
  //       builder: (_) => VerificationExpiredScreen(),
  //     ),
  //     (route) => false,
  //   );
  // }

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

class StageItem {
  final String id;
  final String title;
  final String subtitle;
  final bool required;
  final bool completed;

  const StageItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.required,
    required this.completed,
  });

  StageItem copyWith({bool? completed}) => StageItem(
    id: id,
    title: title,
    subtitle: subtitle,
    required: required,
    completed: completed ?? this.completed,
  );
}
