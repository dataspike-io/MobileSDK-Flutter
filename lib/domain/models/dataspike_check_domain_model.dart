import 'package:dataspikemobilesdk/domain/models/country_domain_model.dart';
import 'manual_field_settings_domain_model.dart';

class DataspikeCheckDomainModel {
  final bool poiIsRequired;
  final bool livenessIsRequired;
  final bool poaIsRequired;
  final bool personalDataRequired;
  final List<CountryDomainModel> countries;
  final ManualFieldsSettingsDomainModel? manualFields;
  final String verificationUrl;

  const DataspikeCheckDomainModel({
    required this.poiIsRequired,
    required this.livenessIsRequired,
    required this.poaIsRequired,
    required this.personalDataRequired,
    required this.countries,
    required this.manualFields,
    required this.verificationUrl,
  });
}