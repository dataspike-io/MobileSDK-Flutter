import 'package:dataspikemobilesdk/data/models/response/dataspike_check_response.dart';

class DataspikeVerificationChecksResponse {
  final DataspikeCheckResponse? faceComparison;
  final DataspikeCheckResponse? liveness;
  final DataspikeCheckResponse? documentMrz;
  final DataspikeCheckResponse? poa;

  DataspikeVerificationChecksResponse({
    this.faceComparison,
    this.liveness,
    this.documentMrz,
    this.poa,
  });

  factory DataspikeVerificationChecksResponse.fromJson(Map<String, dynamic> json) {
    return DataspikeVerificationChecksResponse(
      faceComparison: json['face_comparison'] != null
          ? DataspikeCheckResponse.fromJson(json['face_comparison'])
          : null,
      liveness: json['liveness'] != null
          ? DataspikeCheckResponse.fromJson(json['liveness'])
          : null,
      documentMrz: json['document_mrz'] != null
          ? DataspikeCheckResponse.fromJson(json['document_mrz'])
          : null,
      poa: json['poa'] != null
          ? DataspikeCheckResponse.fromJson(json['poa'])
          : null,
    );
  }
}