class DataspikeEmptyResponse {
  final String? empty;

  DataspikeEmptyResponse({this.empty});

  factory DataspikeEmptyResponse.fromJson(Map<String, dynamic> json) =>
      DataspikeEmptyResponse(
        empty: json['empty'] as String?,
      );
}