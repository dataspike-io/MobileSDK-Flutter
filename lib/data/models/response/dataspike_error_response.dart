class DataspikeErrorResponse {
  final int? code;
  final String? message;

  DataspikeErrorResponse({
    this.code,
    this.message,
  });

  factory DataspikeErrorResponse.fromJson(Map<String, dynamic> json) {
    return DataspikeErrorResponse(
      code: json['code'] as int?,
      message: json['message'] as String?,
    );
  }
}