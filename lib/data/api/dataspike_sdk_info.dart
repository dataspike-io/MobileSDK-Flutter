import 'dart:io';

/// Version of the Dataspike Flutter SDK.
///
/// Must match `version:` in pubspec.yaml — bump both on every release.
/// Sent to the backend as the Flutter build version.
const String dataspikeSdkVersion = '1.0.0';

class DataspikeSdkInfo {
  DataspikeSdkInfo._();

  static const String buildVersionHeader = 'x-flutter-build-version';

  /// `iOS`, `Android` or the raw `Platform.operatingSystem` value.
  static String get platform {
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    return Platform.operatingSystem;
  }

  /// Dart version without the channel/build suffix, e.g. `3.8.1`.
  static String get dartVersion => Platform.version.split(' ').first;

  /// Example: `DataspikeFlutterSDK/1.0.0 (iOS) Dart/3.8.1`.
  static final String userAgent =
      'DataspikeFlutterSDK/$dataspikeSdkVersion ($platform) Dart/$dartVersion';
}
