class DataspikeHttpErrorResponse {
  final String? details;
  final String? error;

  DataspikeHttpErrorResponse({
    this.details,
    this.error,
  });

  factory DataspikeHttpErrorResponse.fromJson(Map<String, dynamic> json) =>
      DataspikeHttpErrorResponse(
        details: json['details'] as String?,
        error: json['error'] as String?,
      );
}