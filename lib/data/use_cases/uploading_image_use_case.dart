import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';

class UploadImageUseCase {
  final IDataspikeRepository dataspikeRepository;

  UploadImageUseCase({
    required this.dataspikeRepository,
  });

  Future<UploadImageState> call({
    required String documentType,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    return await dataspikeRepository.uploadImage(
      documentType: documentType,
      imageBytes: imageBytes,
      fileName: fileName,
    );
  }
}