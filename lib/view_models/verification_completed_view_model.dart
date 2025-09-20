import 'dart:async';
import 'package:dataspikemobilesdk/data/use_cases/proceed_with_verification_use_case.dart';
import 'package:dataspikemobilesdk/domain/models/states/proceed_with_verification_state.dart';
import 'templates/base_view_model.dart';

class VerificationCompletedViewModel extends BaseViewModel {
  final ProceedWithVerificationUseCase getProceedWithVerificationUseCase;
  final _verificationController = StreamController<ProceedWithVerificationState>.broadcast();

  Stream<ProceedWithVerificationState> get verificationFlow => _verificationController.stream;

  VerificationCompletedViewModel({
    required this.getProceedWithVerificationUseCase,
  });

  Future<void> getVerificationCompleted() async {
    showLoading(true);
    final state = await getProceedWithVerificationUseCase.call();
    _verificationController.add(state);
    showLoading(false);
  }

  @override
  void dispose() {
    _verificationController.close();
    super.dispose();
  }
}