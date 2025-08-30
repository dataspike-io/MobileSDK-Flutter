import '../dataspike_verification_checks_domain_model.dart';
import '../verification_settings_domain_model.dart';
import '../finish_screen_settings_domain_model.dart';
import '../manual_field_settings_domain_model.dart';

abstract class VerificationState {
  const VerificationState();
}

class VerificationSuccess extends VerificationState {
  final String id;
  final String status;
  final DataspikeVerificationChecksDomainModel checks;
  final String verificationUrl;
  final String countryCode;
  final VerificationSettingsDomainModel settings;
  final String expiresAt;
  final ManualFieldsSettingsDomainModel manualFields;
  final FinishScreenSettingsDomainModel? finishScreenSettings;

  const VerificationSuccess({
    required this.id,
    required this.status,
    required this.checks,
    required this.verificationUrl,
    required this.countryCode,
    required this.settings,
    required this.expiresAt,
    required this.manualFields,
    this.finishScreenSettings,
  });
}

class VerificationError extends VerificationState {
  final String details;
  final String error;

  const VerificationError({
    required this.details,
    required this.error,
  });
}