class VerificationSettingsDomainModel {
  final bool poiRequired;
  final List<String> poiAllowedDocuments;
  final bool faceComparisonRequired;
  final List<String> faceComparisonAllowedDocuments;
  final bool poaRequired;
  final List<String> poaAllowedDocuments;
  final List<String> countries;
  // final UiConfigModel uiConfig;

  const VerificationSettingsDomainModel({
    required this.poiRequired,
    required this.poiAllowedDocuments,
    required this.faceComparisonRequired,
    required this.faceComparisonAllowedDocuments,
    required this.poaRequired,
    required this.poaAllowedDocuments,
    required this.countries,
    // required this.uiConfig,
  });
}