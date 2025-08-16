import 'package:dataspikemobilesdk/dependencies_provider/dataspike_component.dart';
import 'package:dataspikemobilesdk/main/models/dataspike_dependencies.dart';

class DataspikeInjector {
  static DataspikeComponent? _component;

  static DataspikeComponent get component {
    if (_component == null) {
      throw Exception("You need to initialize DataspikeComponent");
    }
    return _component!;
  }

  static void setComponent(DataspikeDependencies dependencies) {
    _component = DataspikeComponentImpl(dependencies);
  }
}