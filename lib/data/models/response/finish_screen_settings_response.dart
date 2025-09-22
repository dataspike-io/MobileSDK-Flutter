class FinishScreenSettingsResponse {
  final bool? enabled;
  final String? title;
  final String? redirectLink;
  final String? mainText;
  final String? redirectWarning;
  final String? cta;

  FinishScreenSettingsResponse({
    this.enabled,
    this.title,
    this.redirectLink,
    this.mainText,
    this.redirectWarning,
    this.cta,
  });

  factory FinishScreenSettingsResponse.fromJson(Map<String, dynamic> json) =>
      FinishScreenSettingsResponse(
        enabled: json['enabled'] as bool?,
        title: json['title'] as String?,
        redirectLink: json['redirect_link'] as String?,
        mainText: json['main_text'] as String?,
        redirectWarning: json['redirect_warning'] as String?,
        cta: json['cta'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'title': title,
        'redirect_link': redirectLink,
        'main_text': mainText,
        'redirect_warning': redirectWarning,
        'cta': cta,
      };
}