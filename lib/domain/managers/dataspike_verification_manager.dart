import 'package:dataspikemobilesdk/domain/models/country_domain_model.dart';
import '../models/verification_settings_domain_model.dart';
import '../models/dataspike_check_domain_model.dart';
import 'package:intl/intl.dart';
import '../models/finish_screen_settings_domain_model.dart';

class VerificationManager {
  DataspikeCheckDomainModel checks = const DataspikeCheckDomainModel(
    poiIsRequired: false,
    livenessIsRequired: false,
    poaIsRequired: false,
    allowPoiManualUploads: false,
    personalDataRequired: false,
    manualFields: null,
  );

  String _expiresAt = '';
  String _status = '';
  String verificationUrl = '';
  FinishScreenSettingsDomainModel? finishScreenSettings;
  List<CountryDomainModel> countries = [];
  String get status => _status;

  void setChecksAndExpiration(
    VerificationSettingsDomainModel settings,
    List<CountryDomainModel> countries,
    String status,
    String expiresAt,
    String verificationUrl,
  ) {
    checks = DataspikeCheckDomainModel(
      poiIsRequired: settings.poiRequired,
      livenessIsRequired: settings.faceComparisonRequired,
      poaIsRequired: settings.poaRequired,
      allowPoiManualUploads: settings.allowPoiManualUploads,
      personalDataRequired: settings.manualFields.enabled,
      manualFields: settings.manualFields,
    );
    _status = status;
    _expiresAt = expiresAt;
    this.countries = countries;
    this.verificationUrl = verificationUrl;
    finishScreenSettings = settings.finishScreenSettings;
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