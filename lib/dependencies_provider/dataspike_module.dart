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
  late final IDataspikeRepository _dataspikeRepository;
  late final VerificationManager _verificationManager;

  DataspikeModuleImpl(this.dependencies) {
    final baseUrl = dependencies.isDebug
        ? 'https://sandboxapi.dataspike.io/'
        : 'https://api.dataspike.io/';
    final apiService = DataspikeApiServiceImpl(
      baseUrl: baseUrl,
      apiToken: dependencies.dsApiToken,
    );
    _dataspikeRepository = DataspikeRepositoryImpl(
      apiService: apiService,
      shortId: dependencies.shortId,
      verificationResponseMapper: VerificationResponseMapper(),
    );
    _verificationManager = VerificationManager();
  }

  @override
  String get shortId => dependencies.shortId;

  @override
  IDataspikeRepository get dataspikeRepository => _dataspikeRepository;

  @override
  VerificationManager get verificationManager => _verificationManager;
}