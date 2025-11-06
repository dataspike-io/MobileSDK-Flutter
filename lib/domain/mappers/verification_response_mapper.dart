import 'package:dataspikemobilesdk/data/models/response/verification_response.dart';
import 'package:dataspikemobilesdk/domain/models/states/verification_state.dart';
import 'package:dataspikemobilesdk/domain/models/dataspike_verification_checks_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/dataspike_checks_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/dataspike_error_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/verification_settings_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/manual_field_settings_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/manual_field_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/finish_screen_settings_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_option_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_option_type.dart';

class VerificationResponseMapper {
  VerificationState map({
    VerificationResponse? response,
    Exception? error,
    required bool darkModeIsEnabled,
  }) {
    if (response != null) {
      ManualFieldDomainModel field(f) => ManualFieldDomainModel(
        enabled: f?.enabled ?? false,
        caption: f?.caption ?? "",
        order: f?.order ?? 0,
      );

      ManualFieldsSettingsDomainModel settingsField(f) =>
          ManualFieldsSettingsDomainModel(
            enabled: f?.enabled ?? false,
            description: f?.description,
            fullName: field(f?.fullName),
            email: field(f?.email),
            phone: field(f?.phone),
            country: field(f?.country),
            dob: field(f?.dob),
            gender: field(f?.gender),
            citizenship: field(f?.citizenship),
            address: field(f?.address),
            certificateOfIncorporation: field(f?.certificateOfIncorporation),
            ownershipDocument: field(f?.ownershipDocument),
            customFields: f?.customFields?.map<ManualCustomFieldDomainModel>((
              c,
            ) {
              final o = c.options;
              return ManualCustomFieldDomainModel(
                label: c.label ?? "",
                caption: c.caption ?? "",
                order: c.order,
                options: o == null
                    ? null
                    : ManualCustomFieldOptionsDomainModel(
                        type: ManualCustomFieldOptionType.fromRaw(o.type),
                        choices: o.choices,
                        attachmentTypePreset: o.attachmentTypePreset,
                        allowedMimeTypes: o.allowedMimeTypes,
                        maxSize: o.maxSize,
                      ),
              );
            }).toList(),
          );

      return VerificationSuccess(
        id: response.id ?? "",
        status: response.status ?? "",
        checks: DataspikeVerificationChecksDomainModel(
          faceComparison: DataspikeChecksDomainModel(
            status: response.checks?.faceComparison?.status ?? "",
            errors:
                response.checks?.faceComparison?.errors
                    ?.map(
                      (e) => DataspikeErrorDomainModel(
                        code: e.code ?? -1,
                        message: e.message ?? "",
                      ),
                    )
                    .toList() ??
                [],
            pendingDocuments:
                response.checks?.faceComparison?.pendingDocuments ?? [],
          ),
          liveness: DataspikeChecksDomainModel(
            status: response.checks?.liveness?.status ?? "",
            errors:
                response.checks?.liveness?.errors
                    ?.map(
                      (e) => DataspikeErrorDomainModel(
                        code: e.code ?? -1,
                        message: e.message ?? "",
                      ),
                    )
                    .toList() ??
                [],
            pendingDocuments: response.checks?.liveness?.pendingDocuments ?? [],
          ),
          documentMrz: DataspikeChecksDomainModel(
            status: response.checks?.documentMrz?.status ?? "",
            errors:
                response.checks?.documentMrz?.errors
                    ?.map(
                      (e) => DataspikeErrorDomainModel(
                        code: e.code ?? -1,
                        message: e.message ?? "",
                      ),
                    )
                    .toList() ??
                [],
            pendingDocuments:
                response.checks?.documentMrz?.pendingDocuments ?? [],
          ),
          poa: DataspikeChecksDomainModel(
            status: response.checks?.poa?.status ?? "",
            errors:
                response.checks?.poa?.errors
                    ?.map(
                      (e) => DataspikeErrorDomainModel(
                        code: e.code ?? -1,
                        message: e.message ?? "",
                      ),
                    )
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
          faceComparisonRequired:
              response.settings?.faceComparisonRequired ?? false,
          faceComparisonAllowedDocuments:
              response.settings?.faceComparisonAllowedDocuments ?? [],
          poaRequired: response.settings?.poaRequired ?? false,
          allowPoiManualUploads:
              response.settings?.allowPoiManualUploads ?? false,
          poaAllowedDocuments: response.settings?.poaAllowedDocuments ?? [],
          countries: response.settings?.countries ?? [],
          manualFields: settingsField(response.settings?.manualFields),
          finishScreenSettings: FinishScreenSettingsDomainModel(
            enabled: response.settings?.finishScreenSettings?.enabled ?? false,
            title: response.finishScreenSettings?.title,
            redirectLink: response.finishScreenSettings?.redirectLink,
            mainText: response.finishScreenSettings?.mainText,
            redirectWarning: response.finishScreenSettings?.redirectWarning,
            cta: response.finishScreenSettings?.cta,
          ),
          // uiConfig: UiConfigModel.getConfig(darkModeIsEnabled),
        ),
        expiresAt: response.expiresAt ?? "",
        manualFields: settingsField(response.manualFields),
        finishScreenSettings: FinishScreenSettingsDomainModel(
          enabled: response.finishScreenSettings?.enabled ?? false,
          title: response.finishScreenSettings?.title,
          redirectLink: response.finishScreenSettings?.redirectLink,
          mainText: response.finishScreenSettings?.mainText,
          redirectWarning: response.finishScreenSettings?.redirectWarning,
          cta: response.finishScreenSettings?.cta,
        ),
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
