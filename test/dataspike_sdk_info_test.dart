import 'dart:io';

import 'package:dataspikemobilesdk/data/api/dataspike_endpoint.dart';
import 'package:dataspikemobilesdk/data/api/dataspike_sdk_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dataspikeSdkVersion matches pubspec.yaml version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(r'^version:\s*(\S+)', multiLine: true).firstMatch(pubspec);
    expect(match, isNotNull);
    expect(dataspikeSdkVersion, match!.group(1));
  });

  test('every endpoint sends the build version header', () {
    for (final endpoint in DataspikeEndpoint.values) {
      final headers = endpoint.headers('token');
      expect(headers['ds-api-token'], 'token');
      expect(headers['x-flutter-build-version'], dataspikeSdkVersion);
    }
  });

  test('uploadImageV2 has no JSON Content-Type', () {
    expect(DataspikeEndpoint.uploadImageV2.headers('t').containsKey('Content-Type'), isFalse);
    expect(DataspikeEndpoint.getVerification.headers('t')['Content-Type'], 'application/json');
  });
}
