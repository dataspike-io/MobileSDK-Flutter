import 'manual_custom_field_options_response.dart';

class ManualCustomFieldResponse {
  final String? label;
  final String? caption;
  final int? order;
  final ManualCustomFieldOptionsResponse options;

  const ManualCustomFieldResponse({
    this.label,
    this.caption,
    this.order,
    this.options = const ManualCustomFieldOptionsResponse(),
  });

  factory ManualCustomFieldResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ManualCustomFieldResponse();
    return ManualCustomFieldResponse(
      label: json['label'] as String?,
      caption: json['caption'] as String?,
      order: json['order'] as int?,
      options: ManualCustomFieldOptionsResponse.fromJson(
        json['options'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'caption': caption,
    'order': order,
    'options': options.toJson(),
  };
}
