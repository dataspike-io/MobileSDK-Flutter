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

  String get title {
    switch (code) {
      case ERROR_CODE_EXPIRED:
        return 'Uploaded document is outdated';
      case ERROR_TOO_MANY_ATTEMPTS:
        return 'Too many attempts to proceed liveness check';
      default:
        return 'We are experiencing problems with photo';
    }
  }

  String get subtitle {
    switch (code) {
      case ERROR_CODE_EXPIRED:
        return 'Please, upload actual document to proceed verifications.';
      case ERROR_TOO_MANY_ATTEMPTS:
        return 'Please, try to proceed verification later';
      default:
        return message;
    }
  }
}

const int ERROR_CODE_EXPIRED = 8000;
const int ERROR_TOO_MANY_ATTEMPTS = 9000;