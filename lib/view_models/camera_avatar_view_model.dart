import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/data/use_cases/uploading_image_use_case.dart';

class CameraAvatarViewModel extends ChangeNotifier {
  Duration? timerDuration;

  final UploadImageUseCase _setUseCase;

  CameraAvatarViewModel({required UploadImageUseCase setUseCase}) 
    : _setUseCase = setUseCase {
    setVerificationTimer();
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
}
