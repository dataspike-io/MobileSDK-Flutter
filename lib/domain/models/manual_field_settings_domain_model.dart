import 'manual_field_domain_model.dart';
import 'manual_custom_field_domain_model.dart';

class ManualFieldsSettingsDomainModel {
  final bool enabled;

  final String? description;
  final ManualFieldDomainModel? fullName;
  final ManualFieldDomainModel? email;
  final ManualFieldDomainModel? phone;
  final ManualFieldDomainModel? country;
  final ManualFieldDomainModel? dob;
  final ManualFieldDomainModel? gender;
  final ManualFieldDomainModel? citizenship;
  final ManualFieldDomainModel? address;
  final ManualFieldDomainModel? certificateOfIncorporation;
  final ManualFieldDomainModel? ownershipDocument;

  final List<ManualCustomFieldDomainModel>? customFields;

  const ManualFieldsSettingsDomainModel({
    required this.enabled,
    this.description,
    this.fullName,
    this.email,
    this.phone,
    this.country,
    this.dob,
    this.gender,
    this.citizenship,
    this.address,
    this.certificateOfIncorporation,
    this.ownershipDocument,
    this.customFields,
  });
}
