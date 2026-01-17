import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'dataspikemobilesdk_method_channel.dart';

abstract class DataspikemobilesdkPlatform extends PlatformInterface {
  /// Constructs a DataspikemobilesdkPlatform.
  DataspikemobilesdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static DataspikemobilesdkPlatform _instance = MethodChannelDataspikemobilesdk();

  /// The default instance of [DataspikemobilesdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelDataspikemobilesdk].
  static DataspikemobilesdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DataspikemobilesdkPlatform] when
  /// they register themselves.
  static set instance(DataspikemobilesdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}
