import 'dataspike_checks_domain_model.dart';

class DataspikeVerificationChecksDomainModel {
  final DataspikeChecksDomainModel faceComparison;
  final DataspikeChecksDomainModel liveness;
  final DataspikeChecksDomainModel documentMrz;
  final DataspikeChecksDomainModel poa;

  const DataspikeVerificationChecksDomainModel({
    required this.faceComparison,
    required this.liveness,
    required this.documentMrz,
    required this.poa,
  });
}