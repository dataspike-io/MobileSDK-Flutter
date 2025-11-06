import 'manual_fields_settings_response.dart';
import 'finish_screen_settings_response.dart';

class VerificationSettingsResponse {
  final bool? poiRequired;
  final List<String>? poiAllowedDocuments;
  final bool? faceComparisonRequired;
  final List<String>? faceComparisonAllowedDocuments;
  final bool? poaRequired;
  final bool? allowPoiManualUploads;
  final List<String>? poaAllowedDocuments;
  final List<String>? countries;
  final ManualFieldsSettingsResponse? manualFields;
  final FinishScreenSettingsResponse? finishScreenSettings;
  final String? uiSettings;

  VerificationSettingsResponse({
    this.poiRequired,
    this.poiAllowedDocuments,
    this.faceComparisonRequired,
    this.faceComparisonAllowedDocuments,
    this.poaRequired,
    this.allowPoiManualUploads,
    this.poaAllowedDocuments,
    this.countries,
    this.manualFields,
    this.finishScreenSettings,
    this.uiSettings,
  });

  factory VerificationSettingsResponse.fromJson(Map<String, dynamic> json) {
    return VerificationSettingsResponse(
      poiRequired: json['poi_required'] as bool?,
      poiAllowedDocuments: json['poi_allowed_documents'] != null
          ? List<String>.from(json['poi_allowed_documents'] as List)
          : null,
      faceComparisonRequired: json['face_comparison_required'] as bool?,
      faceComparisonAllowedDocuments: json['face_comparison_allowed_documents'] != null
          ? List<String>.from(json['face_comparison_allowed_documents'] as List)
          : null,
      poaRequired: json['poa_required'] as bool?,
      allowPoiManualUploads: json['allow_poi_manual_uploads'] as bool?,
      poaAllowedDocuments: json['poa_allowed_documents'] != null
          ? List<String>.from(json['poa_allowed_documents'] as List)
          : null,
      countries: json['countries'] != null
          ? List<String>.from(json['countries'] as List)
          : null,
          manualFields: json['manual_fields_settings'] != null
          ? ManualFieldsSettingsResponse.fromJson(
              json['manual_fields_settings'],
            )
          : null,
      finishScreenSettings: json['finish_screen_settings'] != null
          ? FinishScreenSettingsResponse.fromJson(
              json['finish_screen_settings'],
            )
          : null,
      uiSettings: json['ui_settings'] as String?,
    );
  }
}