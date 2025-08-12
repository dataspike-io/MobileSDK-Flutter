import 'check_domain_model.dart';

class VerificationChecksDomainModel {
  final CheckDomainModel faceComparison;
  final CheckDomainModel liveness;
  final CheckDomainModel documentMrz;
  final CheckDomainModel poa;

  const VerificationChecksDomainModel({
    required this.faceComparison,
    required this.liveness,
    required this.documentMrz,
    required this.poa,
  });
}