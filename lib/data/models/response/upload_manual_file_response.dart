class UploadManualFileResponse {
  final String? message;

  UploadManualFileResponse({this.message});

  factory UploadManualFileResponse.fromJson(Map<String, dynamic> json) =>
      UploadManualFileResponse(message: json['message'] as String?);
}
