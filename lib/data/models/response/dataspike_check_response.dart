import 'package:dataspikemobilesdk/data/models/response/dataspike_error_response.dart';

class DataspikeCheckResponse {
  final String? status;
  final List<DataspikeErrorResponse>? errors;
  final List<String>? pendingDocuments;

  DataspikeCheckResponse({
    this.status,
    this.errors,
    this.pendingDocuments,
  });

  factory DataspikeCheckResponse.fromJson(Map<String, dynamic> json) {
    return DataspikeCheckResponse(
      status: json['status'] as String?,
      errors: json['errors'] != null
          ? (json['errors'] as List)
              .map((e) => DataspikeErrorResponse.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      pendingDocuments: json['pending_documents'] != null
          ? List<String>.from(json['pending_documents'] as List)
          : null,
    );
  }
}