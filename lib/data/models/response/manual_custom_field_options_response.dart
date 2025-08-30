class ManualCustomFieldOptionsResponse {
  final String? type; // select | file | text ...
  final List<String> choices;
  final String? attachmentTypePreset; // e.g. image
  final List<String> allowedMimeTypes;
  final int? maxSize; // bytes

  const ManualCustomFieldOptionsResponse({
    this.type,
    this.choices = const [],
    this.attachmentTypePreset,
    this.allowedMimeTypes = const [],
    this.maxSize,
  });

  factory ManualCustomFieldOptionsResponse.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ManualCustomFieldOptionsResponse();
    return ManualCustomFieldOptionsResponse(
      type: json['type'] as String?,
      choices: (json['choices'] as List?)?.whereType<String>().toList() ?? const [],
      attachmentTypePreset: json['attachment_type_preset'] as String?,
      allowedMimeTypes: (json['allowed_mime_types'] as List?)
              ?.whereType<String>()
              .toList() ??
          const [],
      maxSize: json['max_size'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'choices': choices,
        'attachment_type_preset': attachmentTypePreset,
        'allowed_mime_types': allowedMimeTypes,
        'max_size': maxSize,
      };
}