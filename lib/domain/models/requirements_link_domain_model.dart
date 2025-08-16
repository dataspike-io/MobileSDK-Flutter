class RequirementsLinkDomainModel {
  String? poi;
  String? liveness;
  String? poa;

  RequirementsLinkDomainModel({
    this.poi,
    this.liveness,
    this.poa,
  });

  factory RequirementsLinkDomainModel.fromJson(Map<String, dynamic> json) =>
      RequirementsLinkDomainModel(
        poi: json['poi'] as String?,
        liveness: json['liveness'] as String?,
        poa: json['poa'] as String?,
      );
}