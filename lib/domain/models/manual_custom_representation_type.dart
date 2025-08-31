import 'manual_custom_field_option_type.dart';
import 'manual_custom_field_option_domain_model.dart';

abstract class ManualCustomFieldRepresentation {
  String get caption;
  int? get order;
  ManualCustomFieldOptionType get type;
  ManualCustomFieldOptionsDomainModel? get options;
}