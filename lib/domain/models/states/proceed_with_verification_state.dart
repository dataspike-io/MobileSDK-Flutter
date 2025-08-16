abstract class ProceedWithVerificationState {}

class ProceedWithVerificationStateSuccess extends ProceedWithVerificationState {
  final String id;
  final String status;

  ProceedWithVerificationStateSuccess({
    required this.id,
    required this.status,
  });
}

class ProceedWithVerificationStateError extends ProceedWithVerificationState {
  final String error;
  final List<String> pendingDocuments;
  final String message;

  ProceedWithVerificationStateError({
    required this.error,
    required this.pendingDocuments,
    required this.message,
  });
}