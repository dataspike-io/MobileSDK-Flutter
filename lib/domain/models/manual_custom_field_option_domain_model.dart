import 'manual_custom_field_option_type.dart';

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
