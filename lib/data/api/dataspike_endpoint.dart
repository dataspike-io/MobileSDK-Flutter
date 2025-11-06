enum DataspikeEndpoint {
  getVerification,
  uploadImage,
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
    return {
      'ds-api-token': apiToken,
      'Content-Type': 'application/json',
    };
  }
}