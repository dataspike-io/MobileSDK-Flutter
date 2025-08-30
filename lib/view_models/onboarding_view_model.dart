import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';

class OnboardingViewModel extends ChangeNotifier {
  bool termsAccepted = true;
  bool dataAccepted = true;

  Duration? timerDuration;

  List<StageItem> stages = const [];

  OnboardingViewModel() {
    setVerificationTimer();
    buildStages();
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

    final list = <StageItem>[
      const StageItem(
        id: 'personal',
        title: 'Complete your personal data',
        subtitle: 'No special needed',
        required: true,
        completed: true, 
      ),
      if (requiresDocument)
        const StageItem(
          id: 'document',
            title: 'Verify your documents',
          subtitle: 'You’ll need passport or ID to make photo.',
          required: true,
          completed: false,
        ),
      if (requiresSelfie)
        const StageItem(
          id: 'selfie',
          title: 'Make a selfie',
          subtitle: 'Please use clear background and daylight',
          required: true,
          completed: false,
        ),
      if (requiresAddress)
        const StageItem(
          id: 'address',
          title: 'Confirm your address',
          subtitle: 'No special needed',
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