import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/data/models/request/profile_fields_request_body.dart';
import 'package:dataspikemobilesdk/domain/models/states/message_state.dart';
import 'package:dataspikemobilesdk/domain/managers/dataspike_verification_manager.dart';
import 'package:dataspikemobilesdk/domain/managers/dataspike_personal_data_fields_manager.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_representation_type.dart';

class SetProfileUseCase {
  final IDataspikeRepository dataspikeRepository;
  final VerificationManager verificationSettingsManager;
  final PersonalDataManager personalDataManager;

  SetProfileUseCase({
    required this.dataspikeRepository,
    required this.verificationSettingsManager,
    required this.personalDataManager,
  });

  Future<MessageState> call(ProfileFieldsRequestBody body) async {
    return await dataspikeRepository.setProfileFields(body);
  }

  List<ManualCustomFieldRepresentationModel> getFields() {
    return personalDataManager.getPersonalDataFields(
      verificationSettingsManager.checks.manualFields,
    );
  }

  String? get description {
    return verificationSettingsManager.checks.manualFields?.description;
  }
}