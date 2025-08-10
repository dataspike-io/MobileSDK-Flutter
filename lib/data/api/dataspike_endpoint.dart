enum DataspikeEndpoint {
  getVerification,
  uploadImage,
  setCountry,
  getCountries,
  proceedWithVerification,
}

extension DataspikeEndpointPath on DataspikeEndpoint {
  String path({String? shortId}) {
    switch (this) {
      case DataspikeEndpoint.getVerification:
        return 'api/v3/sdk/${shortId ?? ''}';
      case DataspikeEndpoint.uploadImage:
        return 'api/v3/upload/sdk/${shortId ?? ''}';
      case DataspikeEndpoint.setCountry:
        return 'api/v3/sdk/${shortId ?? ''}/set_country';
      case DataspikeEndpoint.getCountries:
        return 'api/v3/public/dictionary/countries';
      case DataspikeEndpoint.proceedWithVerification:
        return 'api/v3/sdk/${shortId ?? ''}/proceed';
    }
  }
}

extension DataspikeEndpointHeaders on DataspikeEndpoint {
  Map<String, String> headers(String apiToken) {
    return {
      'ds-api-token': '$apiToken',
      'Content-Type': 'application/json',
    };
  }
}