class ManualCustomFieldOptionsDomainModel {
  final ManualCustomFieldOptionType type;
  final List<String> choices;
  final String? attachmentTypePreset; // e.g. image
  final List<String> allowedMimeTypes; // e.g. "image/jpeg" image
  final int? maxSize; // e.g. 8388608 image

  const ManualCustomFieldOptionsDomainModel({
    required this.type,
    this.choices = const [],
    this.attachmentTypePreset,
    this.allowedMimeTypes = const [],
    this.maxSize,
  });
}

enum ManualCustomFieldOptionType {
  select,
  file,
  text;

  static ManualCustomFieldOptionType fromRaw(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'select':
        return ManualCustomFieldOptionType.select;
      case 'file':
        return ManualCustomFieldOptionType.file;
      case 'text':
        return ManualCustomFieldOptionType.text;
      default:
        return ManualCustomFieldOptionType.text;
    }
  }

  String get raw {
    switch (this) {
      case ManualCustomFieldOptionType.select:
        return 'select';
      case ManualCustomFieldOptionType.file:
        return 'file';
      case ManualCustomFieldOptionType.text:
        return 'text';
    }
  }
}