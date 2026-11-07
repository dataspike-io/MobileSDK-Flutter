import 'dataspike_error_response.dart';

class UploadImageErrorResponse {
  final String? message;
  final String? documentId;
  final List<DataspikeErrorResponse>? errors;

  UploadImageErrorResponse({
    this.message,
    this.documentId,
    this.errors,
  });

  factory UploadImageErrorResponse.fromJson(Map<String, dynamic> json) =>
      UploadImageErrorResponse(
        message: json['message'] as String?,
        documentId: json['document_id'] as String?,
        errors: (json['errors'] as List<dynamic>?)
            ?.map((e) => DataspikeErrorResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}