import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';

class OnboardingViewModel extends ChangeNotifier {
  bool termsAccepted = true;
  bool dataAccepted = true;

  Duration? timerDuration;

  void setVerificationTimer() {
    final verificationManager = DataspikeInjector.component.verificationManager;
    final millisecondsUntilVerificationExpired = verificationManager.millisecondsUntilVerificationExpired;
    timerDuration = Duration(milliseconds: millisecondsUntilVerificationExpired);
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