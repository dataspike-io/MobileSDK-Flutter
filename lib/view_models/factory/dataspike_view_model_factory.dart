import 'package:dataspikemobilesdk/data/use_cases/set_country_use_case.dart';
import 'package:dataspikemobilesdk/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/data/use_cases/verification_use_case.dart';
import 'package:dataspikemobilesdk/data/use_cases/proceed_with_verification_use_case.dart';
import '../dataspike_activity_view_model.dart';
import '../onboarding_view_model.dart';
import '../personal_data_view_model.dart';
import '../camera_document_view_model.dart';
import '../camera_avatar_view_model.dart';
import '../countries_view_model.dart';
import '../verification_completed_view_model.dart';
import 'package:dataspikemobilesdk/data/use_cases/set_profile_use_case.dart';
import 'package:dataspikemobilesdk/data/use_cases/uploading_image_use_case.dart';
import 'package:dataspikemobilesdk/domain/models/document_type.dart'; 

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

      case CameraAvatarViewModel:
        return CameraAvatarViewModel(
          setUseCase: UploadImageUseCase(
            dataspikeRepository: DataspikeInjector.component.dataspikeRepository
          ),
        ) as T;
      case VerificationCompletedViewModel:
        return VerificationCompletedViewModel(
          getProceedWithVerificationUseCase: ProceedWithVerificationUseCase(
            dataspikeRepository: DataspikeInjector.component.dataspikeRepository,
          ),
        ) as T;
      case CountryPickerViewModel:
        return CountryPickerViewModel(
          setCountryUseCase: SetCountryUseCase(
            dataspikeRepository: DataspikeInjector.component.dataspikeRepository,
          ),
        ) as T;
      default:
        throw Exception("Unknown ViewModel Type");
    }
  }

  CameraDocumentViewModel createCameraDocumentViewModel({
    required DocumentType docType
  }) {
    final dataspikeComponent = DataspikeInjector.component;
    
    return CameraDocumentViewModel(
      setUseCase: UploadImageUseCase(
        dataspikeRepository: dataspikeComponent.dataspikeRepository,
      ),
      allowPoiManualUploads: dataspikeComponent.verificationManager.checks.allowPoiManualUploads,
      docType: docType,
    );
  }
}