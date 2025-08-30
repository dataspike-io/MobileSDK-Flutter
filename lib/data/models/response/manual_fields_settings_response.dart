import 'manual_field_response.dart';
import 'manual_custom_field_settings_response.dart';

class ManualFieldsSettingsResponse {
  final bool? enabled;

  final ManualFieldResponse? fullName;
  final ManualFieldResponse? email;
  final ManualFieldResponse? phone;
  final ManualFieldResponse? country;
  final ManualFieldResponse? dob;
  final ManualFieldResponse? gender;
  final ManualFieldResponse? citizenship;
  final ManualFieldResponse? address;
  
  final List<ManualCustomFieldResponse>? customFields;

  const ManualFieldsSettingsResponse({
    this.enabled,
    this.fullName,
    this.email,
    this.phone,
    this.country,
    this.dob,
    this.gender,
    this.citizenship,
    this.address,
    this.customFields,
  });

  factory ManualFieldsSettingsResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ManualFieldsSettingsResponse();
    }
    ManualFieldResponse? _field(dynamic v) =>
        v is Map<String, dynamic> ? ManualFieldResponse.fromJson(v) : null;

    final customList = (json['custom_fields'] as List<dynamic>?)
            ?.map((e) => ManualCustomFieldResponse.fromJson(
                  e is Map<String, dynamic> ? e : null,
                ))
            .toList() ??
        const <ManualCustomFieldResponse>[];

    return ManualFieldsSettingsResponse(
      enabled: json['enabled'] as bool?,
      fullName: _field(json['full_name']),
      email: _field(json['email']),
      phone: _field(json['phone']),
      country: _field(json['country']),
      dob: _field(json['dob']),
      gender: _field(json['gender']),
      citizenship: _field(json['citizenship']),
      address: _field(json['address']),
      customFields: customList,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'full_name': fullName?.toJson(),
    'email': email?.toJson(),
    'phone': phone?.toJson(),
    'country': country?.toJson(),
    'dob': dob?.toJson(),
    'gender': gender?.toJson(),
    'citizenship': citizenship?.toJson(),
    'address': address?.toJson(),
    'custom_fields': customFields?.map((e) => e.toJson()).toList(),
  };
}
