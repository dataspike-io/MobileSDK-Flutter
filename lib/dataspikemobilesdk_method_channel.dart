import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dataspikemobilesdk_platform_interface.dart';

/// An implementation of [DataspikemobilesdkPlatform] that uses method channels.
class MethodChannelDataspikemobilesdk extends DataspikemobilesdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('dataspikemobilesdk');
}
