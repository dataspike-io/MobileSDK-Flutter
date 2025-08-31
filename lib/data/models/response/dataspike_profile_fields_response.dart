class DataspikeProfileFieldsResponse {
  final String? message;

  DataspikeProfileFieldsResponse({
    this.message,
  });

  factory DataspikeProfileFieldsResponse.fromJson(Map<String, dynamic> json) =>
      DataspikeProfileFieldsResponse(
        message: json['message'] as String?,
      );
}