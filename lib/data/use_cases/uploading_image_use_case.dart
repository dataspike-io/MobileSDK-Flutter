import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';
import 'package:dataspikemobilesdk/data/models/request/image_document_request_body.dart';
import 'package:dataspikemobilesdk/data/models/request/image_selfie_v2_request_body.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state_v2.dart';

class UploadImageUseCase {
  final IDataspikeRepository dataspikeRepository;

  UploadImageUseCase({
    required this.dataspikeRepository,
  });

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

  Future<UploadImageStateV2> uploadImageV2({
    required List<LivenessBatchFrame> frames,
  }) async {
    return await dataspikeRepository.uploadImageV2(
      frames: frames
    );
  }

  Future<UploadImageState> uploadDocument({
    required ImageDocumentRequestBody body,
  }) async {
    return await dataspikeRepository.uploadDocument(
      body: body,
    );
  }
}