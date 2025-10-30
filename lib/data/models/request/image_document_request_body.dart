class ImageDocumentRequestBody {
  final String encodedFileContent;
  final String documentType;

  ImageDocumentRequestBody({required this.encodedFileContent, required this.documentType});

  Map<String, dynamic> toJson() => {
    'encoded_file_content': encodedFileContent,
    'document_type': documentType,
  };
}