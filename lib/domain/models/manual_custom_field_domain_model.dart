import 'manual_custom_field_option_domain_model.dart';

class ManualCustomFieldDomainModel {
  final String? label;
  final String? caption;
  final int? order;
  final ManualCustomFieldOptionsDomainModel? options;

  const ManualCustomFieldDomainModel({
    required this.label,
    required this.caption,
    this.order,
    this.options,
  });
}
