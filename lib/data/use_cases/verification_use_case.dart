import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/domain/managers/dataspike_verification_manager.dart';
import 'package:dataspikemobilesdk/domain/models/states/verification_state.dart';
// import 'package:dataspikemobilesdk/domain/ui/ui_manager.dart';

class VerificationUseCase {
  final IDataspikeRepository dataspikeRepository;
  final VerificationManager verificationSettingsManager;

  VerificationUseCase({
    required this.dataspikeRepository,
    required this.verificationSettingsManager,
  });

  Future<VerificationState> call({required bool darkModeIsEnabled}) async {
    final state = await dataspikeRepository.getVerification(darkModeIsEnabled: darkModeIsEnabled);

    if (state is VerificationSuccess) {
      // UIManager.initUIManager(state.settings.uiConfig);
      verificationSettingsManager.setChecksAndExpiration(
        state.settings,
        state.status,
        state.expiresAt,
      );
    }

    return state;
  }
}