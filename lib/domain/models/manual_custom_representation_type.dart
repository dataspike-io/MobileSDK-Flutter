import 'manual_custom_field_type.dart';
import 'manual_custom_field_option_domain_model.dart';
import 'package:file_picker/file_picker.dart';
import 'manual_custom_field_option_type.dart';

abstract class ManualCustomFieldRepresentation {
  String get label;
  int get order;
  String? get value;
  String? get caption;
  String? get validation;
  String? get placeholder;
  ManualCustomFieldOptionsDomainModel get options;
  ManualCustomFieldType get fieldType;
  bool get isValid;
  bool get isValidData;
  PlatformFile? get file;
}

class ManualCustomFieldRepresentationModel
    implements ManualCustomFieldRepresentation {
  @override
  final String label;
  @override
  final int order;
  @override
  String? value;
  @override
  String? caption;
  @override
  String? validation;
  @override
  String? placeholder;
  @override
  final ManualCustomFieldOptionsDomainModel options;
  @override
  final ManualCustomFieldType fieldType;
  @override
  PlatformFile? file;

  ManualCustomFieldRepresentationModel({
    required this.label,
    required this.order,
    this.value,
    this.caption,
    this.validation,
    this.placeholder,
    required this.options,
    required this.fieldType,
    this.file,
  });

  @override
  bool get isValid {
    if (validation == null || validation!.isEmpty) {
      return true;
    }

    final v = value?.trim() ?? '';

    final reg = RegExp(validation!);
    final ok = reg.hasMatch(v);
    return ok;
  }

  @override
  bool get isValidData {
    if (options.type == ManualCustomFieldOptionType.file) {
      if (file?.size != null) {
        return file!.size <= (options.maxSize ?? 8388608);
      } else {
        return false;
      }
    }

    return true;
  }
}
