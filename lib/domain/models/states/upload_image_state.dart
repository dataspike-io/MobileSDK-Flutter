import 'package:dataspikemobilesdk/domain/models/dataspike_error_domain_model.dart';

abstract class UploadImageState {}

class UploadImageSuccess extends UploadImageState {
  final String documentId;
  final String detectedDocumentType;
  final String detectedDocumentSide;
  final bool detectedTwoSideDocument;
  final String detectedCountry;
  final List<DataspikeErrorDomainModel> errors;

  UploadImageSuccess({
    required this.documentId,
    required this.detectedDocumentType,
    required this.detectedDocumentSide,
    required this.detectedTwoSideDocument,
    required this.detectedCountry,
    required this.errors,
  });
}

class UploadImageError extends UploadImageState {
  final int code;
  final String message;

  UploadImageError({
    required this.code,
    required this.message,
  });
}