import 'manual_custom_field_type.dart';
import 'manual_custom_field_option_domain_model.dart';

abstract class ManualCustomFieldRepresentation {
  String get caption;
  int get order;
  String? get value;
  String? get placeholder;
  ManualCustomFieldOptionsDomainModel get options;
  ManualCustomFieldType get fieldType;
}

class ManualCustomFieldRepresentationModel implements ManualCustomFieldRepresentation {
  @override
  final String caption;
  @override
  final int order;
  @override
  String? value;
  @override
  final String? placeholder;
  @override
  final ManualCustomFieldOptionsDomainModel options;
  @override
  final ManualCustomFieldType fieldType;

  ManualCustomFieldRepresentationModel({
    required this.caption,
    required this.order,
    this.value,
    this.placeholder,
    required this.options,
    required this.fieldType,
  });
}