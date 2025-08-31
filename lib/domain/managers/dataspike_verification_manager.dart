import '../models/verification_settings_domain_model.dart';
import '../models/dataspike_check_domain_model.dart';
import 'package:intl/intl.dart';
import '../models/manual_field_settings_domain_model.dart';

class VerificationManager {
  DataspikeCheckDomainModel checks = const DataspikeCheckDomainModel(
    poiIsRequired: false,
    livenessIsRequired: false,
    poaIsRequired: false,
    personalDataRequired: false,
    manualFields: null
  );

  String _expiresAt = '';
  String _status = '';

  String get status => _status;

  void setChecksAndExpiration(
    VerificationSettingsDomainModel settings,
    String status,
    String expiresAt,
  ) {
    checks = DataspikeCheckDomainModel(
      poiIsRequired: settings.poiRequired,
      livenessIsRequired: settings.faceComparisonRequired,
      poaIsRequired: settings.poaRequired,
      personalDataRequired: settings.manualFields.enabled,
      manualFields: settings.manualFields,
    );
    _status = status;
    _expiresAt = expiresAt;
  }

  int get millisecondsUntilVerificationExpired {
    try {
      final dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
      final parsedDate = dateFormat.parseUtc(_expiresAt);
      return parsedDate.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
    } catch (e) {
      return 0;
    }
  }
}