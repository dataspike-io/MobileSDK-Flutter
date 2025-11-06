import 'manual_field_settings_domain_model.dart';
import 'finish_screen_settings_domain_model.dart';

class VerificationSettingsDomainModel {
  final bool poiRequired;
  final List<String> poiAllowedDocuments;
  final bool faceComparisonRequired;
  final List<String> faceComparisonAllowedDocuments;
  final bool poaRequired;
  final bool allowPoiManualUploads;
  final List<String> poaAllowedDocuments;
  final List<String> countries;
  final ManualFieldsSettingsDomainModel manualFields;
  final FinishScreenSettingsDomainModel? finishScreenSettings;

  // final UiConfigModel uiConfig;

  const VerificationSettingsDomainModel({
    required this.poiRequired,
    required this.poiAllowedDocuments,
    required this.faceComparisonRequired,
    required this.faceComparisonAllowedDocuments,
    required this.poaRequired,
    required this.allowPoiManualUploads,
    required this.poaAllowedDocuments,
    required this.countries,
    required this.manualFields,
    this.finishScreenSettings,
    // required this.uiConfig,
  });
}