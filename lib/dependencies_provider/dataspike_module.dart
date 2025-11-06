import 'package:dataspikemobilesdk/main/models/dataspike_dependencies.dart';
import 'package:dataspikemobilesdk/data/api/dataspike_api_service.dart';
import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/domain/managers/dataspike_verification_manager.dart';
import 'package:dataspikemobilesdk/domain/mappers/verification_response_mapper.dart';
import 'package:dataspikemobilesdk/domain/mappers/upload_image_response_mapper.dart';
import 'package:dataspikemobilesdk/domain/mappers/countries_response_mapper.dart';
import 'package:dataspikemobilesdk/domain/mappers/empty_response_mapper.dart';
import 'package:dataspikemobilesdk/domain/mappers/proceed_with_verification_response_mapper.dart';
import 'package:dataspikemobilesdk/domain/mappers/upload_manual_file_response_mapper.dart';
import 'package:dataspikemobilesdk/domain/mappers/message_response_mapper.dart';
import 'package:dataspikemobilesdk/domain/managers/dataspike_personal_data_fields_manager.dart';
import 'package:dataspikemobilesdk/domain/managers/permission_service.dart';

abstract class DataspikeModule {
  IDataspikeRepository get dataspikeRepository;
  VerificationManager get verificationManager;
  PersonalDataManager get personalDataManager;
  PermissionService get permissionService;
  String get shortId;
}

class DataspikeModuleImpl implements DataspikeModule {
  final DataspikeDependencies dependencies;
  late final IDataspikeRepository _dataspikeRepository;
  late final VerificationManager _verificationManager;
  late final PersonalDataManager _personalDataManager;
  late final PermissionService _permissionService;

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
      uploadImageResponseMapper: UploadImageResponseMapper(),
      uploadManualFileResponseMapper: UploadManualFileResponseMapper(),
      countriesResponseMapper: CountriesResponseMapper(),
      emptyResponseMapper: EmptyResponseMapper(),
      proceedWithVerificationResponseMapper: ProceedWithVerificationResponseMapper(),
      messageResponseMapper: MessageResponseMapper(),
    );
    _verificationManager = VerificationManager();
    _personalDataManager = PersonalDataManager();
    _permissionService = PermissionService();
    _permissionService.requestCameraStatus();
  }

  @override
  String get shortId => dependencies.shortId;

  @override
  IDataspikeRepository get dataspikeRepository => _dataspikeRepository;

  @override
  VerificationManager get verificationManager => _verificationManager;

  @override
  PersonalDataManager get personalDataManager => _personalDataManager;

  @override
  PermissionService get permissionService => _permissionService;
}