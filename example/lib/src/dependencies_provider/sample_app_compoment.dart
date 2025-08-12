import '../data/repository/sample_app_repository.dart';
import 'model/sample_app_dependencies.dart';
import '../domain/mappers/new_verification_ui_mapper.dart';
import 'sample_app_module.dart';

abstract class SampleAppComponent {
  ISampleAppRepository get sampleAppRepository;
  NewVerificationUiMapper get newVerificationUiMapper;
}

class SampleAppComponentImpl implements SampleAppComponent {
  final SampleAppModule _module;

  SampleAppComponentImpl(SampleAppDependencies dependencies)
      : _module = SampleAppModuleImpl(dependencies);

  @override
  ISampleAppRepository get sampleAppRepository => _module.sampleAppRepository;

  @override
  NewVerificationUiMapper get newVerificationUiMapper => _module.newVerificationUiMapper;
}