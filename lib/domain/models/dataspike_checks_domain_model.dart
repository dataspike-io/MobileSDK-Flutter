import 'dataspike_error_domain_model.dart';

class DataspikeChecksDomainModel {
  final String status;
  final List<DataspikeErrorDomainModel> errors;
  final List<String> pendingDocuments;

  const DataspikeChecksDomainModel({
    required this.status,
    required this.errors,
    required this.pendingDocuments,
  });
}