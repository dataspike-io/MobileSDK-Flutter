class ProceedWithVerificationResponse {
  final String? id;
  final String? status;

  ProceedWithVerificationResponse({
    this.id,
    this.status,
  });

  factory ProceedWithVerificationResponse.fromJson(Map<String, dynamic> json) =>
      ProceedWithVerificationResponse(
        id: json['id'] as String?,
        status: json['status'] as String?,
      );
}