import 'package:dataspikemobilesdk/data/models/response/upload_image_response.dart';
import 'package:dataspikemobilesdk/data/models/response/upload_image_response_v2.dart';
import 'package:dataspikemobilesdk/data/models/response/upload_image_error_response.dart';
import 'package:dataspikemobilesdk/data/models/response/upload_image_error_response_v2.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state_v2.dart';
import 'package:dataspikemobilesdk/domain/models/dataspike_error_domain_model.dart';
import 'package:dataspikemobilesdk/data/models/response/dataspike_error_response.dart';
import 'package:dataspikemobilesdk/domain/models/document_side.dart';

class UploadImageResponseMapper {
  UploadImageState map({
    UploadImageResponse? response,
    Object? error,
  }) {
    if (response != null) {
      return UploadImageSuccess(
        documentId: response.documentId ?? "",
        detectedDocumentType: response.detectedDocumentType ?? "",
        detectedDocumentSide: DocumentSide.fromRaw(response.detectedDocumentSide),
        detectedTwoSideDocument: response.detectedTwoSideDocument ?? false,
        detectedCountry: response.detectedCountry ?? "",
        errors: response.errors?.map((errorResponse) {
          return DataspikeErrorDomainModel(
            code: errorResponse.code ?? -1,
            message: errorResponse.message ?? "",
          );
        }).toList() ?? [],
      );
    } else if (error is UploadImageErrorResponse) {
      final errors = error.errors ?? [];
      final expiredError = errors.firstWhere(
        (err) => err.code == ERROR_CODE_EXPIRED,
        orElse: () => DataspikeErrorResponse(code: null, message: null),
      );
      final tooManyAttemptsError = errors.firstWhere(
        (err) => err.code == ERROR_TOO_MANY_ATTEMPTS,
        orElse: () => DataspikeErrorResponse(code: null, message: null),
      );
      final firstError = errors.isNotEmpty ? errors.first : DataspikeErrorResponse(code: null, message: null);

      final code = expiredError.code ?? tooManyAttemptsError.code ?? firstError.code ?? -1;
      final message = expiredError.message ?? tooManyAttemptsError.message ?? firstError.message ?? "Unknown error occurred";

      return UploadImageError(
        code: code,
        message: message,
      );
    } else {
      return UploadImageError(
        code: -1,
        message: "Unknown error occurred",
      );
    }
  }

  UploadImageStateV2 mapV2({
    UploadImageResponseV2? response,
    Object? error,
  }) {
    if (response != null) {
      return UploadImageSuccessV2(
        documentIds: response.documentIds,
        detectedDocumentType: response.detectedDocumentType,
      );
    } else if (error is UploadImageErrorResponseV2) {
      final errors = error.errors ?? [];
      final firstError = errors.isNotEmpty ? errors.first : DataspikeErrorResponse(code: null, message: null);

      return UploadImageErrorV2(
        code: firstError.code ?? -1,
        message: error.message ?? firstError.message ?? "Unknown error occurred",
        framesErrors: errors.map((e) => DataspikeErrorDomainModel(
          code: e.code ?? -1,
          message: e.message ?? "",
        )).toList(),
      );
    } else {
      return UploadImageErrorV2(
        code: -1,
        message: "Unknown error occurred",
        framesErrors: [],
      );
    }
  }
}