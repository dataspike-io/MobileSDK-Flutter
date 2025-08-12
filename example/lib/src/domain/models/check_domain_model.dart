import 'error_domain_model.dart';

class CheckDomainModel {
  final String status;
  final List<ErrorDomainModel> errors;
  final List<String> pendingDocuments;

  const CheckDomainModel({
    required this.status,
    required this.errors,
    required this.pendingDocuments,
  });
}