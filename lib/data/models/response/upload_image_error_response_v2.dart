import 'dataspike_error_response.dart';

class UploadImageErrorResponseV2 {
  final String? message;
  final List<UploadImageErrorFrameResultV2>? framesResults;
  final List<DataspikeErrorResponse>? errors;

  UploadImageErrorResponseV2({
    this.message,
    this.framesResults,
    this.errors,
  });

  factory UploadImageErrorResponseV2.fromJson(Map<String, dynamic> json) =>
      UploadImageErrorResponseV2(
        message: json['message'] as String?,
        framesResults: (json['frames_results'] as List<dynamic>?)
            ?.map((e) => UploadImageErrorFrameResultV2.fromJson(e as Map<String, dynamic>))
            .toList(),
        errors: (json['errors'] as List<dynamic>?)
            ?.map((e) => DataspikeErrorResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class UploadImageErrorFrameResultV2 {
  final String? documentId;
  final List<DataspikeErrorResponse>? errors;

  UploadImageErrorFrameResultV2({
    this.documentId,
    this.errors,
  });

  factory UploadImageErrorFrameResultV2.fromJson(Map<String, dynamic> json) =>
      UploadImageErrorFrameResultV2(
        documentId: json['document_id'] as String?,
        errors: (json['errors'] as List<dynamic>?)
            ?.map((e) => DataspikeErrorResponse.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}