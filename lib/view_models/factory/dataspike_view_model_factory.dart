import 'package:dataspikemobilesdk/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/data/use_cases/verification_use_case.dart';
import '../dataspike_activity_view_model.dart';
import '../templates/base_view_model.dart';
import '../onboarding_view_model.dart';
import '../personal_data_view_model.dart';
import 'package:dataspikemobilesdk/data/use_cases/set_profile_use_case.dart';

class DataspikeViewModelFactory {
  T create<T extends Object>() {
    switch (T) {
      case DataspikeActivityViewModel:
        return DataspikeActivityViewModel(
          getVerificationUseCase: VerificationUseCase(
            dataspikeRepository: DataspikeInjector.component.dataspikeRepository,
            verificationSettingsManager: DataspikeInjector.component.verificationManager,
          ),
        ) as T;

      case BaseViewModel:
        return BaseViewModel() as T;

      case OnboardingViewModel:
        return OnboardingViewModel() as T;

      case PersonalDataViewModel:
        return PersonalDataViewModel(
          setProfileUseCase: SetProfileUseCase(
            dataspikeRepository: DataspikeInjector.component.dataspikeRepository,
            verificationSettingsManager: DataspikeInjector.component.verificationManager,
            personalDataManager: DataspikeInjector.component.personalDataManager,
          ),
        ) as T;

      default:
        throw Exception("Unknown ViewModel Type");
    }
  }
}