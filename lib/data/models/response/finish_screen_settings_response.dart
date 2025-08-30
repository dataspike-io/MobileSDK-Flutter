class FinishScreenSettingsResponse {
  final bool? enabled;

  FinishScreenSettingsResponse({this.enabled});

  factory FinishScreenSettingsResponse.fromJson(Map<String, dynamic> json) =>
      FinishScreenSettingsResponse(enabled: json['enabled'] as bool?);

  Map<String, dynamic> toJson() => {'enabled': enabled};
}