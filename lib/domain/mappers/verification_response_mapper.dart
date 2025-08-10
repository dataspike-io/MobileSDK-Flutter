import 'package:dataspikemobilesdk/data/models/response/verification_response.dart';
import 'package:dataspikemobilesdk/domain/models/verification_state.dart';
import 'package:dataspikemobilesdk/domain/models/dataspike_verification_checks_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/dataspike_checks_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/dataspike_error_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/verification_settings_domain_model.dart';
// import 'package:dataspikemobilesdk/domain/models/ui_config_model.dart';

class VerificationResponseMapper {
  VerificationState map({
    VerificationResponse? response,
    Exception? error,
    required bool darkModeIsEnabled,
  }) {
    if (response != null) {
      return VerificationSuccess(
        id: response.id ?? "",
        status: response.status ?? "",
        checks: DataspikeVerificationChecksDomainModel(
          faceComparison: DataspikeChecksDomainModel(
            status: response.checks?.faceComparison?.status ?? "",
            errors: response.checks?.faceComparison?.errors
                    ?.map((e) => DataspikeErrorDomainModel(
                          code: e.code ?? -1,
                          message: e.message ?? "",
                        ))
                    .toList() ??
                [],
            pendingDocuments: response.checks?.faceComparison?.pendingDocuments ?? [],
          ),
          liveness: DataspikeChecksDomainModel(
            status: response.checks?.liveness?.status ?? "",
            errors: response.checks?.liveness?.errors
                    ?.map((e) => DataspikeErrorDomainModel(
                          code: e.code ?? -1,
                          message: e.message ?? "",
                        ))
                    .toList() ??
                [],
            pendingDocuments: response.checks?.liveness?.pendingDocuments ?? [],
          ),
          documentMrz: DataspikeChecksDomainModel(
            status: response.checks?.documentMrz?.status ?? "",
            errors: response.checks?.documentMrz?.errors
                    ?.map((e) => DataspikeErrorDomainModel(
                          code: e.code ?? -1,
                          message: e.message ?? "",
                        ))
                    .toList() ??
                [],
            pendingDocuments: response.checks?.documentMrz?.pendingDocuments ?? [],
          ),
          poa: DataspikeChecksDomainModel(
            status: response.checks?.poa?.status ?? "",
            errors: response.checks?.poa?.errors
                    ?.map((e) => DataspikeErrorDomainModel(
                          code: e.code ?? -1,
                          message: e.message ?? "",
                        ))
                    .toList() ??
                [],
            pendingDocuments: response.checks?.poa?.pendingDocuments ?? [],
          ),
        ),
        verificationUrl: response.verificationUrl ?? "",
        countryCode: response.countryCode ?? "",
        settings: VerificationSettingsDomainModel(
          poiRequired: response.settings?.poiRequired ?? false,
          poiAllowedDocuments: response.settings?.poiAllowedDocuments ?? [],
          faceComparisonRequired: response.settings?.faceComparisonRequired ?? false,
          faceComparisonAllowedDocuments: response.settings?.faceComparisonAllowedDocuments ?? [],
          poaRequired: response.settings?.poaRequired ?? false,
          poaAllowedDocuments: response.settings?.poaAllowedDocuments ?? [],
          countries: response.settings?.countries ?? [],
          // uiConfig: UiConfigModel.getConfig(darkModeIsEnabled),
        ),
        expiresAt: response.expiresAt ?? "",
      );
    } else if (error != null) {
      return VerificationError(
        error: error.toString(),
        details: "Try again later",
      );
    } else {
      return VerificationError(
        error: "Unknown error occurred",
        details: "Try again later",
      );
    }
  }
}