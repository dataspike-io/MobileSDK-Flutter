class ErrorResponse {
  final int? code;
  final String? message;

  const ErrorResponse({
    this.code,
    this.message,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      code: json['code'] as int?,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
  };
}