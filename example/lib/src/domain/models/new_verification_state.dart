import 'verification_check_domain_model.dart';

abstract class NewVerificationState {}

class NewVerificationSuccess extends NewVerificationState {
  final String id;
  final String status;
  final VerificationChecksDomainModel checks;
  final String createdAt;
  final bool isSandbox;
  final String verificationUrl;
  final String verificationUrlId;
  final String expiresAt;

  NewVerificationSuccess({
    required this.id,
    required this.status,
    required this.checks,
    required this.createdAt,
    required this.isSandbox,
    required this.verificationUrl,
    required this.verificationUrlId,
    required this.expiresAt,
  });
}

class NewVerificationError extends NewVerificationState {
  final String validationError;
  final String error;

  NewVerificationError({
    required this.validationError,
    required this.error,
  });
}