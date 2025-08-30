class ManualFieldDomainModel {
  final bool enabled;
  final String caption;
  final int? order;

  const ManualFieldDomainModel({
    required this.enabled,
    required this.caption,
    this.order,
  });
}
