import 'dart:async';
import 'package:dataspikemobilesdk/data/use_cases/verification_use_case.dart';
import 'package:dataspikemobilesdk/domain/models/verification_state.dart';
import 'templates/base_view_model.dart';

class DataspikeActivityViewModel extends BaseViewModel {
  final VerificationUseCase getVerificationUseCase;
  final _verificationController = StreamController<VerificationState>.broadcast();

  Stream<VerificationState> get verificationFlow => _verificationController.stream;

  DataspikeActivityViewModel({
    required this.getVerificationUseCase,
  });

  Future<void> getVerification(bool darkModeIsEnabled) async {
    showLoading(true);
    final state = await getVerificationUseCase.call(darkModeIsEnabled: darkModeIsEnabled);
    _verificationController.add(state);
    showLoading(false);
  }

  @override
  void dispose() {
    _verificationController.close();
    super.dispose();
  }
}