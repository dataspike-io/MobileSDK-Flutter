import 'document_mrz_data_response.dart';
import 'dataspike_error_response.dart';

class DocumentMrzResponse {
  final DocumentMrzDataResponse? data;
  final String? status;
  final List<String>? pendingDocuments;
  final List<DataspikeErrorResponse>? errors;

  DocumentMrzResponse({
    this.data,
    this.status,
    this.pendingDocuments,
    this.errors,
  });

  factory DocumentMrzResponse.fromJson(Map<String, dynamic> json) =>
      DocumentMrzResponse(
        data: json['data'] != null
            ? DocumentMrzDataResponse.fromJson(json['data'])
            : null,
        status: json['status'] as String?,
        pendingDocuments: (json['pending_documents'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        errors: (json['errors'] as List<dynamic>?)
            ?.map((e) => DataspikeErrorResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}