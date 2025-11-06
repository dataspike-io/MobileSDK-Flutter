import 'manual_field_settings_domain_model.dart';

class DataspikeCheckDomainModel {
  final bool poiIsRequired;
  final bool livenessIsRequired;
  final bool poaIsRequired;
  final bool allowPoiManualUploads;
  final bool personalDataRequired;
  final ManualFieldsSettingsDomainModel? manualFields;

  const DataspikeCheckDomainModel({
    required this.poiIsRequired,
    required this.livenessIsRequired,
    required this.poaIsRequired,
    required this.allowPoiManualUploads,
    required this.personalDataRequired,
    required this.manualFields,
  });
}