class FinishScreenSettingsDomainModel {
  final bool enabled;
  final String? title;
  final String? redirectLink;
  final String? mainText;
  final String? redirectWarning;
  final String? cta;

  FinishScreenSettingsDomainModel({
    required this.enabled,
    this.title,
    this.redirectLink,
    this.mainText,
    this.redirectWarning,
    this.cta,
  });
}