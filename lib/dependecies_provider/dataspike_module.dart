import 'package:dataspikemobilesdk/main/models/dataspike_dependencies.dart';
import 'package:dataspikemobilesdk/data/api/dataspike_api_service.dart';
import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/domain/managers/dataspike_verification_manager.dart';
import 'package:dataspikemobilesdk/domain/mappers/verification_response_mapper.dart';

abstract class DataspikeModule {
  IDataspikeRepository get dataspikeRepository;
  VerificationManager get verificationManager;
  String get shortId;
}

class DataspikeModuleImpl implements DataspikeModule {
  final DataspikeDependencies dependencies;
  late final IDataspikeApiService _apiService;

  DataspikeModuleImpl(this.dependencies) {
    final baseUrl = dependencies.isDebug
        ? 'https://sandboxapi.dataspike.io/'
        : 'https://api.dataspike.io/';
    _apiService = DataspikeApiServiceImpl(
      baseUrl: baseUrl,
      apiToken: dependencies.dsApiToken,
    );
  }

  @override
  String get shortId => dependencies.shortId;

  @override
  IDataspikeRepository get dataspikeRepository => DataspikeRepositoryImpl(
        apiService: _apiService,
        shortId: shortId,
        verificationResponseMapper: VerificationResponseMapper(),
      );

  @override
  VerificationManager get verificationManager => VerificationManager();
}