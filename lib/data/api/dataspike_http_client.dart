import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const String _sdkName = 'DataspikeFlutterSDK';
const String _sdkVersion = '0.0.1';

/// http.Client that adds a browser-like User-Agent with the device model and OS version.
///
/// Android: Mozilla/5.0 (Linux; Android 14; samsung SM-S918B) DataspikeFlutterSDK/0.0.1
/// iOS:     Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X; iPhone16,1) DataspikeFlutterSDK/0.0.1
class DataspikeHttpClient extends http.BaseClient {
  final http.Client _inner;

  DataspikeHttpClient([http.Client? inner]) : _inner = inner ?? http.Client();

  static Future<String>? _userAgent;

  static Future<String> userAgent() => _userAgent ??= _buildUserAgent();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers['User-Agent'] = await userAgent();
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();

  static Future<String> _buildUserAgent() async {
    const sdk = '$_sdkName/$_sdkVersion';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return 'Mozilla/5.0 (Linux; Android ${info.version.release}; '
            '${info.manufacturer} ${info.model}) $sdk';
      }
      if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        final device = info.model.toLowerCase().contains('ipad') ? 'iPad' : 'iPhone';
        final os = info.systemVersion.replaceAll('.', '_');
        return 'Mozilla/5.0 ($device; CPU $device OS $os like Mac OS X; '
            '${info.utsname.machine}) $sdk';
      }
    } catch (e) {
      debugPrint('DataspikeHttpClient user agent error: $e');
    }
    return 'Mozilla/5.0 (${Platform.operatingSystem} ${Platform.operatingSystemVersion}) $sdk';
  }
}
