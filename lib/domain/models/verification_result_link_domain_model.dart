class VerificationResultLinkDomainModel {
  String? verificationSuccessful;
  String? verificationExpired;
  String? verificationFailed;

  VerificationResultLinkDomainModel({
    this.verificationSuccessful,
    this.verificationExpired,
    this.verificationFailed,
  });

  factory VerificationResultLinkDomainModel.fromJson(Map<String, dynamic> json) =>
      VerificationResultLinkDomainModel(
        verificationSuccessful: json['verification_successful'] as String?,
        verificationExpired: json['verification_expired'] as String?,
        verificationFailed: json['verification_failed'] as String?,
      );
}