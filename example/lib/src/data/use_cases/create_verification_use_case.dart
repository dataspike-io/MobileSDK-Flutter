import '../repository/sample_app_repository.dart';
import '../../domain/models/new_verification_state.dart';

class CreateVerificationUseCase {
  final ISampleAppRepository Function() sampleAppRepositoryProvider;

  CreateVerificationUseCase({
    required this.sampleAppRepositoryProvider,
  });

  Future<NewVerificationState> call() {
    return sampleAppRepositoryProvider().createVerification();
  }
}