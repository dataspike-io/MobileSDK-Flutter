class NewVerificationErrorResponse {
  final List<String>? validationErrors;
  final String? error;

  const NewVerificationErrorResponse({
    this.validationErrors,
    this.error,
  });

  factory NewVerificationErrorResponse.fromJson(Map<String, dynamic> json) {
    return NewVerificationErrorResponse(
      validationErrors: (json['validation_errors'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'validation_errors': validationErrors,
    'error': error,
  };
}