enum DataspikeEndpoint {
  getVerification,
  uploadImage,
  uploadImageV2,
  uploadManualDocument,
  setCountry,
  getCountries,
  proceedWithVerification,
  setProfileFields,
}

extension DataspikeEndpointPath on DataspikeEndpoint {
  String path({String? shortId}) {
    switch (this) {
      case DataspikeEndpoint.getVerification:
        return 'api/v3/sdk/${shortId ?? ''}';
      case DataspikeEndpoint.uploadImage:
        return 'api/v3/upload/sdk/${shortId ?? ''}';
      case DataspikeEndpoint.uploadImageV2:
        return 'api/v4/upload/sdk/${shortId ?? ''}/liveness-batch';
      case DataspikeEndpoint.uploadManualDocument:
        return 'api/v3/sdk/${shortId ?? ''}/upload';
      case DataspikeEndpoint.setCountry:
        return 'api/v3/sdk/${shortId ?? ''}/set_country';
      case DataspikeEndpoint.getCountries:
        return 'api/v3/public/dictionary/countries';
      case DataspikeEndpoint.proceedWithVerification:
        return 'api/v3/sdk/${shortId ?? ''}/proceed';
      case DataspikeEndpoint.setProfileFields:
        return 'api/v3/sdk/${shortId ?? ''}/fields';
    }
  }

  String method() {
    switch (this) {
      case DataspikeEndpoint.getVerification:
      case DataspikeEndpoint.getCountries:
        return 'GET';
      case DataspikeEndpoint.uploadImage:
      case DataspikeEndpoint.uploadImageV2:
      case DataspikeEndpoint.uploadManualDocument:
      case DataspikeEndpoint.setCountry:
      case DataspikeEndpoint.proceedWithVerification:
      case DataspikeEndpoint.setProfileFields:
        return 'POST';
    }
  }
}

extension DataspikeEndpointHeaders on DataspikeEndpoint {
  Map<String, String> headers(String apiToken) {
    switch (this) {
      case DataspikeEndpoint.uploadImageV2:
        return {'ds-api-token': apiToken};
      default:
        return {'ds-api-token': apiToken, 'Content-Type': 'application/json'};
    }
  }
}
