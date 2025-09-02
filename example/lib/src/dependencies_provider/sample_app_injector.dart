import 'sample_app_compoment.dart';
import 'model/sample_app_dependencies.dart';

class SampleAppInjector {
  static SampleAppComponent? _component;

  static SampleAppComponent get component {
    if (_component == null) {
      throw Exception("You need to initialize SampleAppComponent");
    }
    return _component!;
  }

  static void setComponent(SampleAppDependencies dependencies) {
    _component = SampleAppComponentImpl(dependencies);
  }
}