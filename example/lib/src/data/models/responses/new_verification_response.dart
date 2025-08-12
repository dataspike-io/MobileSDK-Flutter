import 'verification_check_ersponse.dart';

class NewVerificationResponse {
  final String? id;
  final String? status;
  final VerificationChecksResponse? checks;
  final String? createdAt;
  final bool? isSandbox;
  final String? verificationUrl;
  final String? verificationUrlId;
  final String? expiresAt;

  const NewVerificationResponse({
    this.id,
    this.status,
    this.checks,
    this.createdAt,
    this.isSandbox,
    this.verificationUrl,
    this.verificationUrlId,
    this.expiresAt,
  });

  factory NewVerificationResponse.fromJson(Map<String, dynamic> json) {
    return NewVerificationResponse(
      id: json['id'] as String?,
      status: json['status'] as String?,
      checks: json['checks'] != null
          ? VerificationChecksResponse.fromJson(json['checks'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
      isSandbox: json['is_sandbox'] as bool?,
      verificationUrl: json['verification_url'] as String?,
      verificationUrlId: json['verification_url_id'] as String?,
      expiresAt: json['expires_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'checks': checks?.toJson(),
    'created_at': createdAt,
    'is_sandbox': isSandbox,
    'verification_url': verificationUrl,
    'verification_url_id': verificationUrlId,
    'expires_at': expiresAt,
  };
}