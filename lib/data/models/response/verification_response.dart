import 'package:dataspikemobilesdk/data/models/response/dataspike_verification_check_response.dart';
import 'package:dataspikemobilesdk/data/models/response/verification_settings_response.dart';

class VerificationResponse {
  final String? id;
  final String? status;
  final DataspikeVerificationChecksResponse? checks;
  final String? verificationUrl;
  final String? countryCode;
  final VerificationSettingsResponse? settings;
  final String? expiresAt;

  VerificationResponse({
    this.id,
    this.status,
    this.checks,
    this.verificationUrl,
    this.countryCode,
    this.settings,
    this.expiresAt,
  });

  // Пример парсинга из JSON
  factory VerificationResponse.fromJson(Map<String, dynamic> json) {
    return VerificationResponse(
      id: json['id'] as String?,
      status: json['status'] as String?,
      checks: json['checks'] != null
          ? DataspikeVerificationChecksResponse.fromJson(json['checks'])
          : null,
      verificationUrl: json['verification_url'] as String?,
      countryCode: json['country_code'] as String?,
      settings: json['settings'] != null
          ? VerificationSettingsResponse.fromJson(json['settings'])
          : null,
      expiresAt: json['expires_at'] as String?,
    );
  }
}