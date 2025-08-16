import 'package:dataspikemobilesdk/data/models/response/proceed_with_verification_response.dart';
import 'package:dataspikemobilesdk/data/models/response/proceed_with_verification_error_response.dart';
import 'package:dataspikemobilesdk/domain/models/states/proceed_with_verification_state.dart';

class ProceedWithVerificationResponseMapper {
  ProceedWithVerificationState map({
    ProceedWithVerificationResponse? response,
    Object? error,
  }) {
    if (response != null) {
      return ProceedWithVerificationStateSuccess(
        id: response.id ?? "",
        status: response.status ?? "",
      );
    } else if (error is ProceedWithVerificationErrorResponse) {
      return ProceedWithVerificationStateError(
        error: error.error ?? "",
        pendingDocuments: error.pendingDocuments ?? [],
        message: error.message ?? "",
      );
    } else {
      return ProceedWithVerificationStateError(
        error: "",
        pendingDocuments: [],
        message: "",
      );
    }
  }
}