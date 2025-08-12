abstract class NewVerificationUiState {}

class NewVerificationUiSuccess extends NewVerificationUiState {
  final String shortId;

  NewVerificationUiSuccess({
    required this.shortId,
  });
}

class NewVerificationUiError extends NewVerificationUiState {
  final String error;
  final String details;

  NewVerificationUiError({
    required this.error,
    required this.details,
  });
}