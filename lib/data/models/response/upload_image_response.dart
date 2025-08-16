import 'dataspike_error_response.dart';

class UploadImageResponse {
  final String? documentId;
  final String? detectedDocumentType;
  final String? detectedDocumentSide;
  final bool? detectedTwoSideDocument;
  final String? detectedCountry;
  final List<DataspikeErrorResponse>? errors;

  UploadImageResponse({
    this.documentId,
    this.detectedDocumentType,
    this.detectedDocumentSide,
    this.detectedTwoSideDocument,
    this.detectedCountry,
    this.errors,
  });

  factory UploadImageResponse.fromJson(Map<String, dynamic> json) =>
      UploadImageResponse(
        documentId: json['document_id'] as String?,
        detectedDocumentType: json['detected_document_type'] as String?,
        detectedDocumentSide: json['detected_document_side'] as String?,
        detectedTwoSideDocument: json['detected_two_side_document'] as bool?,
        detectedCountry: json['detected_country'] as String?,
        errors: (json['errors'] as List<dynamic>?)
            ?.map((e) => DataspikeErrorResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}