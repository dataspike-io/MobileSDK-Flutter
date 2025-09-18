import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/domain/managers/dataspike_verification_manager.dart';
import 'package:dataspikemobilesdk/domain/models/states/countries_state.dart';
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
    final countriesState = await dataspikeRepository.getCountries();

    if (state is VerificationSuccess) {
      // UIManager.initUIManager(state.settings.uiConfig);
      verificationSettingsManager.setChecksAndExpiration(
        state.settings,
        countriesState is CountriesSuccess ? countriesState.countries : [],
        state.status,
        state.expiresAt,
        state.verificationUrl,
      );
    }

    return state;
  }
}