import 'dart:async';
import 'package:dataspikemobilesdk/data/use_cases/verification_use_case.dart';
import 'package:dataspikemobilesdk/domain/models/states/verification_state.dart';

class DataspikeActivityViewModel {
  final VerificationUseCase getVerificationUseCase;
  final _verificationController = StreamController<VerificationState>.broadcast();

  Stream<VerificationState> get verificationFlow => _verificationController.stream;

  DataspikeActivityViewModel({
    required this.getVerificationUseCase,
  });

  Future<void> getVerification(bool darkModeIsEnabled) async {
    final state = await getVerificationUseCase.call(darkModeIsEnabled: darkModeIsEnabled);
    _verificationController.add(state);
  }

  @override
  void dispose() {
    _verificationController.close();
  }
}