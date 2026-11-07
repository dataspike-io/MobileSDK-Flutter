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

  test('headers include User-Agent and build version', () {
    final headers = DataspikeEndpoint.getVerification.headers('token');
    expect(headers['ds-api-token'], 'token');
    expect(headers['User-Agent'], startsWith('DataspikeFlutterSDK/$dataspikeSdkVersion ('));
    expect(headers['x-flutter-build-version'], dataspikeSdkVersion);
  });
}
