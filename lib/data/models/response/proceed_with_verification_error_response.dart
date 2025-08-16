class ProceedWithVerificationErrorResponse {
  final String? error;
  final List<String>? pendingDocuments;
  final String? message;

  ProceedWithVerificationErrorResponse({
    this.error,
    this.pendingDocuments,
    this.message,
  });

  factory ProceedWithVerificationErrorResponse.fromJson(Map<String, dynamic> json) =>
      ProceedWithVerificationErrorResponse(
        error: json['error'] as String?,
        pendingDocuments: (json['pending_documents'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        message: json['message'] as String?,
      );
}