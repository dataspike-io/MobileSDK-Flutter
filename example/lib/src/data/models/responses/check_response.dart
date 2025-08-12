import 'error_response.dart';

class CheckResponse {
  final String? status;
  final List<ErrorResponse>? errors;
  final List<String>? pendingDocuments;

  const CheckResponse({
    this.status,
    this.errors,
    this.pendingDocuments,
  });

  factory CheckResponse.fromJson(Map<String, dynamic> json) {
    return CheckResponse(
      status: json['status'] as String?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => ErrorResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      pendingDocuments: (json['pending_documents'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'errors': errors?.map((e) => e.toJson()).toList(),
    'pending_documents': pendingDocuments,
  };
}