class UploadImageResponseV2 {
  final List<String> documentIds;
  final String detectedDocumentType;
  final bool limitReached;

  const UploadImageResponseV2({
    required this.documentIds,
    required this.detectedDocumentType,
    required this.limitReached,
  });

  factory UploadImageResponseV2.fromJson(Map<String, dynamic> json) =>
      UploadImageResponseV2(
        documentIds: List<String>.from(json['document_ids']),
        detectedDocumentType: json['detected_document_type'] as String,
        limitReached: json['limit_reached'] as bool,
      );
}