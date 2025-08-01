
import 'dataspikemobilesdk_platform_interface.dart';

class Dataspikemobilesdk {
  Future<String?> getPlatformVersion() {
    return DataspikemobilesdkPlatform.instance.getPlatformVersion();
  }
}
