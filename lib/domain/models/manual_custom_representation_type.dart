import 'manual_custom_field_type.dart';
import 'manual_custom_field_option_domain_model.dart';

abstract class ManualCustomFieldRepresentation {
  String get caption;
  int get order;
  String? get value;
  String? get validation;
  String? get placeholder;
  ManualCustomFieldOptionsDomainModel get options;
  ManualCustomFieldType get fieldType;
  bool get isValid;
}

class ManualCustomFieldRepresentationModel implements ManualCustomFieldRepresentation {
  @override
  final String caption;
  @override
  final int order;
  @override
  String? value;
  @override
  String? validation;
  @override
  String? placeholder;
  @override
  final ManualCustomFieldOptionsDomainModel options;
  @override
  final ManualCustomFieldType fieldType;

  ManualCustomFieldRepresentationModel({
    required this.caption,
    required this.order,
    this.value,
    this.validation,
    this.placeholder,
    required this.options,
    required this.fieldType,
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
}