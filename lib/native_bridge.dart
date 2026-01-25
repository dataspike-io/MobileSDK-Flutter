import 'dart:async';
import 'package:flutter/services.dart';

const MethodChannel _ch = MethodChannel('dataspikemobilesdk');

class DataspikeHostChannel {
  static bool _inited = false;

  static Future<void> ensureInitialized({
    required FutureOr<void> Function(Map<String, dynamic> args) onStartRequested,
  }) async {
    if (_inited) return;
    _inited = true;

    _ch.setMethodCallHandler((call) async {
      if (call.method == 'startDataspikeFlow') {
        final args = Map<String, dynamic>.from(call.arguments as Map? ?? {});
        await onStartRequested(args);
        return {"ok": true};
      }
      return null;
    });
  }

  static Future<void> sendCompleted(Map<String, dynamic> payload) async {
    await _ch.invokeMethod('onVerificationCompleted', payload);
  }
}
