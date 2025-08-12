import '../models/new_verification_state.dart';
import '../../data/models/responses/new_verification_response.dart';
import '../../data/models/responses/new_verification_error_response.dart';
import '../models/verification_check_domain_model.dart';
import '../models/check_domain_model.dart';
import '../models/error_domain_model.dart';
import '../models/result.dart';
import '../models/http_exceptions.dart';

class NewVerificationResponseMapper {
  NewVerificationState map(Result<NewVerificationResponse> result) {
    if (result.isSuccess) {
      final newVerificationResponse = result.value!;
      return NewVerificationSuccess(
        id: newVerificationResponse.id ?? '',
        status: newVerificationResponse.status ?? '',
        checks: VerificationChecksDomainModel(
          faceComparison: CheckDomainModel(
            status: newVerificationResponse.checks?.faceComparison?.status ?? '',
            errors: (newVerificationResponse.checks?.faceComparison?.errors ?? [])
                .map((errorResponse) => ErrorDomainModel(
                      code: errorResponse.code ?? -1,
                      message: errorResponse.message ?? '',
                    ))
                .toList(),
            pendingDocuments: newVerificationResponse.checks?.faceComparison?.pendingDocuments ?? [],
          ),
          liveness: CheckDomainModel(
            status: newVerificationResponse.checks?.liveness?.status ?? '',
            errors: (newVerificationResponse.checks?.liveness?.errors ?? [])
                .map((errorResponse) => ErrorDomainModel(
                      code: errorResponse.code ?? -1,
                      message: errorResponse.message ?? '',
                    ))
                .toList(),
            pendingDocuments: newVerificationResponse.checks?.liveness?.pendingDocuments ?? [],
          ),
          documentMrz: CheckDomainModel(
            status: newVerificationResponse.checks?.documentMrz?.status ?? '',
            errors: (newVerificationResponse.checks?.documentMrz?.errors ?? [])
                .map((errorResponse) => ErrorDomainModel(
                      code: errorResponse.code ?? -1,
                      message: errorResponse.message ?? '',
                    ))
                .toList(),
            pendingDocuments: newVerificationResponse.checks?.documentMrz?.pendingDocuments ?? [],
          ),
          poa: CheckDomainModel(
            status: newVerificationResponse.checks?.poa?.status ?? '',
            errors: (newVerificationResponse.checks?.poa?.errors ?? [])
                .map((errorResponse) => ErrorDomainModel(
                      code: errorResponse.code ?? -1,
                      message: errorResponse.message ?? '',
                    ))
                .toList(),
            pendingDocuments: newVerificationResponse.checks?.poa?.pendingDocuments ?? [],
          ),
        ),
        createdAt: newVerificationResponse.createdAt ?? '',
        isSandbox: newVerificationResponse.isSandbox ?? false,
        verificationUrl: newVerificationResponse.verificationUrl ?? '',
        verificationUrlId: newVerificationResponse.verificationUrlId ?? '',
        expiresAt: newVerificationResponse.expiresAt ?? '',
      );
    } else if (result.error != null) {
      final throwable = result.error!;
      if (throwable is HttpException) {
        return _toNewVerificationErrorMessage(throwable);
      } else {
        return NewVerificationError(
          validationError: "Unknown error occurred",
          error: "Try again later",
        );
      }
    }
    throw Exception("Unknown error occurred");
  }

  NewVerificationError _toNewVerificationErrorMessage(HttpException exception) {
    NewVerificationErrorResponse? errorResponse;
    try {
      errorResponse = NewVerificationErrorResponse.fromJson(exception.errorBody);
    } catch (_) {
    }
    return NewVerificationError(
      validationError: (errorResponse?.validationErrors?.isNotEmpty ?? false)
          ? errorResponse!.validationErrors!.first
          : "Unknown error occurred",
      error: errorResponse?.error ?? "Try again later",
    );
  }
}