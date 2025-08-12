import 'model/sample_app_dependencies.dart';
import '../data/api/sample_api_service.dart';
import '../data/repository/sample_app_repository.dart';
import '../domain/mappers/new_verification_response_mapper.dart';
import '../domain/mappers/new_verification_ui_mapper.dart';

abstract class SampleAppModule {
  ISampleAppRepository get sampleAppRepository;
  NewVerificationUiMapper get newVerificationUiMapper;
  String get shortId;
}

class SampleAppModuleImpl implements SampleAppModule {
  final SampleAppDependencies dependencies;
  late final ISampleAppApiService _apiService;

  SampleAppModuleImpl(this.dependencies) {
    final baseUrl = dependencies.isDebug
        ? 'https://sandboxapi.dataspike.io'
        : 'https://api.dataspike.io';
    _apiService = ISampleAppApiService(
      baseUrl: baseUrl,
      apiToken: dependencies.dsApiToken,
    );
  }

  @override
  String get shortId => dependencies.shortId;

  @override
  ISampleAppRepository get sampleAppRepository => SampleAppRepositoryImpl(
        apiService: _apiService,
        newVerificationResponseMapper: NewVerificationResponseMapper(),
      );

  @override
  NewVerificationUiMapper get newVerificationUiMapper => NewVerificationUiMapper();
}