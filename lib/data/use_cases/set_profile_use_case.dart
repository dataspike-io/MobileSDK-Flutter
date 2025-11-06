import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/data/models/request/profile_fields_request_body.dart';
import 'package:dataspikemobilesdk/domain/models/states/message_state.dart';
import 'package:dataspikemobilesdk/domain/managers/dataspike_verification_manager.dart';
import 'package:dataspikemobilesdk/domain/managers/dataspike_personal_data_fields_manager.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_representation_type.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_manual_file_state.dart';

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

  Future<UploadImageState> uploadImage({
    required String documentType,
    required List<int> imageBytes,
    required String ext,
    required String fileName,
  }) async {
    return await dataspikeRepository.uploadImage(
      documentType: documentType,
      imageBytes: imageBytes,
      ext: ext,
      fileName: fileName,
    );
  }

  Future<UploadManualFileState> uploadManualFile({
    required String type,
    required List<int> imageBytes,
    required String ext,
    required String fileName,
  }) async {
    return await dataspikeRepository.uploadManualFile(
      type: type,
      imageBytes: imageBytes,
      ext: ext,
      fileName: fileName,
    );
  }
}