import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/domain/models/states/proceed_with_verification_state.dart';

class ProceedWithVerificationUseCase {
  final IDataspikeRepository dataspikeRepository;

  ProceedWithVerificationUseCase({
    required this.dataspikeRepository,
  });

  Future<ProceedWithVerificationState> call() async {
    return await dataspikeRepository.proceedWithVerification();
  }
}