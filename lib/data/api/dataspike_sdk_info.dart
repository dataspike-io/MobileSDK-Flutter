/// Version of the Dataspike Flutter SDK.
///
/// Must match `version:` in pubspec.yaml — bump both on every release.
/// Sent to the backend in the User-Agent and in [dataspikeBuildVersionHeader].
const String dataspikeSdkVersion = '1.0.0';

/// Header carrying the Flutter SDK build version (like `x-widget-version` for the web widget).
const String dataspikeBuildVersionHeader = 'x-flutter-build-version';
