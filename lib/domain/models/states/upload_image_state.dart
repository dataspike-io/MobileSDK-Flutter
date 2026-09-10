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
  final bool? limitReached;

  UploadImageSuccess({
    required this.documentId,
    required this.detectedDocumentType,
    required this.detectedDocumentSide,
    required this.detectedTwoSideDocument,
    required this.detectedCountry,
    required this.errors,
    required this.limitReached
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
      case ERROR_CODE_DOCUMENT_IS_SCAN:
        return 'Take a photo of the physical document — not a scan or a screen.';
      case ERROR_CODE_INCORRECT_DOCUMENT_LAYOUT:
        return 'Fit all four edges of the document into the frame.';
      case ERROR_CODE_DOCUMENT_NOT_RECOGNIZED:
        return 'Document not recognized. Try again or use another one.';
      case ERROR_CODE_DOCUMENT_NOT_FLAT:
        return 'Lay the document flat and straight on a plain background.';
      case ERROR_CODE_FACE_NOT_VISIBLE_ON_DOC:
        return 'Face not visible. Check for glare or anything covering the photo page.';
      case ERROR_CODE_POOR_DOCUMENT_QUALITY:
        return 'Photo is too blurry. Retake it in better light.';
      case ERROR_CODE_SELFIE_WITH_DOC:
      case ERROR_CODE_MIRRORED_DOC:
        return 'Photo the document alone — flat, in full frame, in focus.';
      case ERROR_CODE_DOCUMENT_TYPE_MISMATCH:
        return 'The document type does not match the expected type. Upload another one.';
      case ERROR_CODE_COUNTRY_NOT_ACCEPTED:
        return 'Documents from this country are not accepted.';
      default:
        return message.isNotEmpty
            ? message
            : 'We’re having trouble with your document photo';
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

// POI: document doesn't meet the required standards
const int ERROR_CODE_DOCUMENT_IS_SCAN = 1012;
const int ERROR_CODE_INCORRECT_DOCUMENT_LAYOUT = 1013;
const int ERROR_CODE_DOCUMENT_NOT_RECOGNIZED = 1014;
const int ERROR_CODE_DOCUMENT_NOT_FLAT = 1015;
const int ERROR_CODE_FACE_NOT_VISIBLE_ON_DOC = 1016;
const int ERROR_CODE_POOR_DOCUMENT_QUALITY = 1017;
const int ERROR_CODE_SELFIE_WITH_DOC = 1018;
const int ERROR_CODE_MIRRORED_DOC = 1019;

// POI: document type mismatch
const int ERROR_CODE_DOCUMENT_TYPE_MISMATCH = 3100;
const int ERROR_CODE_COUNTRY_NOT_ACCEPTED = 3101;