import 'package:flutter_test/flutter_test.dart';
import 'package:dataspikemobilesdk/dataspikemobilesdk.dart';
import 'package:dataspikemobilesdk/dataspikemobilesdk_platform_interface.dart';
import 'package:dataspikemobilesdk/dataspikemobilesdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDataspikemobilesdkPlatform
    with MockPlatformInterfaceMixin
    implements DataspikemobilesdkPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final DataspikemobilesdkPlatform initialPlatform = DataspikemobilesdkPlatform.instance;

  test('$MethodChannelDataspikemobilesdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDataspikemobilesdk>());
  });

  test('getPlatformVersion', () async {
    Dataspikemobilesdk dataspikemobilesdkPlugin = Dataspikemobilesdk();
    MockDataspikemobilesdkPlatform fakePlatform = MockDataspikemobilesdkPlatform();
    DataspikemobilesdkPlatform.instance = fakePlatform;

    expect(await dataspikemobilesdkPlugin.getPlatformVersion(), '42');
  });
}
