class DataspikeCheckDomainModel {
  final bool poiIsRequired;
  final bool livenessIsRequired;
  final bool poaIsRequired;
  final bool personalDataRequired;

  const DataspikeCheckDomainModel({
    required this.poiIsRequired,
    required this.livenessIsRequired,
    required this.poaIsRequired,
    required this.personalDataRequired,
  });
}