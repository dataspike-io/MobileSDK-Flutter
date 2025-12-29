import 'package:dataspikemobilesdk/domain/models/dataspike_error_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/document_side.dart';

abstract class UploadImageState {}

class UploadImageSuccess extends UploadImageState {
  final String documentId;
  final String detectedDocumentType;
  final DocumentSide detectedDocumentSide;
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

    bool get isFront => detectedDocumentSide == DocumentSide.front;
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
        return 'We’re having trouble with your document photo';
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

  bool get withInstruction {
    switch (code) {
      default:
        return false;
    }
  }
}

const int ERROR_CODE_EXPIRED = 8000;
const int ERROR_TOO_MANY_ATTEMPTS = 9000;