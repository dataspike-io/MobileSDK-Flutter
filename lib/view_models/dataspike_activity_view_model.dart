import 'dart:async';
import 'package:dataspikemobilesdk/data/use_cases/verification_use_case.dart';
import 'package:dataspikemobilesdk/domain/models/states/verification_state.dart';

class DataspikeActivityViewModel {
  final VerificationUseCase getVerificationUseCase;
  final StreamController<VerificationState> _verificationController =
      StreamController<VerificationState>.broadcast();

  Stream<VerificationState> get verificationFlow => _verificationController.stream;

  DataspikeActivityViewModel({
    required this.getVerificationUseCase,
  });

  Future<void> getVerification(bool darkModeIsEnabled) async {
    if (_verificationController.isClosed) return;

    final state = await getVerificationUseCase.call(
      darkModeIsEnabled: darkModeIsEnabled,
    );

    if (_verificationController.isClosed) return;

    _verificationController.add(state);
  }

  void dispose() {
    if (!_verificationController.isClosed) {
      _verificationController.close();
    }
  }
}