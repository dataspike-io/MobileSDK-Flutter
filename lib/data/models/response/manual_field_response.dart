class ManualFieldResponse {
  final bool? enabled;
  final String? caption;
  final int? order;

  const ManualFieldResponse({this.enabled, this.caption, this.order});

  factory ManualFieldResponse.fromJson(Map<String, dynamic> json) {
    return ManualFieldResponse(
      enabled: json['enabled'] as bool?,
      caption: json['caption'] as String?,
      order: json['order'] as int?
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'caption': caption,
    'order': order,
  };
}
