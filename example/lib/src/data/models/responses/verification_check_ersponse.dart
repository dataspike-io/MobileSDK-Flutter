import 'check_response.dart';

class VerificationChecksResponse {
  final CheckResponse? faceComparison;
  final CheckResponse? liveness;
  final CheckResponse? documentMrz;
  final CheckResponse? poa;

  const VerificationChecksResponse({
    this.faceComparison,
    this.liveness,
    this.documentMrz,
    this.poa,
  });

  factory VerificationChecksResponse.fromJson(Map<String, dynamic> json) {
    return VerificationChecksResponse(
      faceComparison: json['face_comparison'] != null
          ? CheckResponse.fromJson(json['face_comparison'] as Map<String, dynamic>)
          : null,
      liveness: json['liveness'] != null
          ? CheckResponse.fromJson(json['liveness'] as Map<String, dynamic>)
          : null,
      documentMrz: json['document_mrz'] != null
          ? CheckResponse.fromJson(json['document_mrz'] as Map<String, dynamic>)
          : null,
      poa: json['poa'] != null
          ? CheckResponse.fromJson(json['poa'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'face_comparison': faceComparison?.toJson(),
    'liveness': liveness?.toJson(),
    'document_mrz': documentMrz?.toJson(),
    'poa': poa?.toJson(),
  };
}