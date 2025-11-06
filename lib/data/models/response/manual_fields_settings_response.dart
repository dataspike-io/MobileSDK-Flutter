import 'manual_field_response.dart';
import 'manual_custom_field_settings_response.dart';

class ManualFieldsSettingsResponse {
  final bool? enabled;

  final String? description;
  final ManualFieldResponse? fullName;
  final ManualFieldResponse? email;
  final ManualFieldResponse? phone;
  final ManualFieldResponse? country;
  final ManualFieldResponse? dob;
  final ManualFieldResponse? gender;
  final ManualFieldResponse? citizenship;
  final ManualFieldResponse? address;
  final ManualFieldResponse? certificateOfIncorporation;
  final ManualFieldResponse? ownershipDocument;

  final List<ManualCustomFieldResponse>? customFields;

  const ManualFieldsSettingsResponse({
    this.enabled,
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

  factory ManualFieldsSettingsResponse.fromJson(Map<String, dynamic>? json) {
    ManualFieldResponse? field(dynamic v) {
      if (v is Map<String, dynamic>) {
        return ManualFieldResponse.fromJson(v);
      }
      return null;
    }

    final customList =
        (json?['custom_fields'] as List<dynamic>?)
            ?.map(
              (e) => ManualCustomFieldResponse.fromJson(
                e is Map<String, dynamic> ? e : null,
              ),
            )
            .toList() ??
        const <ManualCustomFieldResponse>[];

    return ManualFieldsSettingsResponse(
      enabled: json?['enabled'] as bool?,
      description: json?['description'] as String?,
      fullName: field(json?['full_name']),
      email: field(json?['email']),
      phone: field(json?['phone']),
      country: field(json?['country']),
      dob: field(json?['dob']),
      gender: field(json?['gender']),
      citizenship: field(json?['citizenship']),
      address: field(json?['address']),
      certificateOfIncorporation: field(json?['certificate_of_incorporation']),
      ownershipDocument: field(json?['ownership_document']),
      customFields: customList,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'description': description,
    'full_name': fullName?.toJson(),
    'email': email?.toJson(),
    'phone': phone?.toJson(),
    'country': country?.toJson(),
    'dob': dob?.toJson(),
    'gender': gender?.toJson(),
    'citizenship': citizenship?.toJson(),
    'address': address?.toJson(),
    'certificate_of_incorporation': certificateOfIncorporation?.toJson(),
    'ownership_document': ownershipDocument?.toJson(),
    'custom_fields': customFields?.map((e) => e.toJson()).toList(),
  };
}
