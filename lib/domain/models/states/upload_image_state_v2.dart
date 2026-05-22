import 'package:dataspikemobilesdk/domain/models/dataspike_error_domain_model.dart';

abstract class UploadImageStateV2 {}

class UploadImageSuccessV2 extends UploadImageStateV2 {
  final List<String> documentIds;
  final String detectedDocumentType;

  UploadImageSuccessV2({
    required this.documentIds,
    required this.detectedDocumentType,
  });
}

class UploadImageErrorV2 extends UploadImageStateV2 {
  final int code;
  final String message;
  final List<DataspikeErrorDomainModel> framesErrors;

  UploadImageErrorV2({
    required this.code,
    required this.message,
    required this.framesErrors,
  });
}