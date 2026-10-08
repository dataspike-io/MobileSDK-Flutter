import 'package:dataspikemobilesdk/domain/managers/permission_service.dart';
import 'package:dataspikemobilesdk/main/models/dataspike_dependencies.dart';
import 'dataspike_module.dart';
import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/domain/managers/dataspike_verification_manager.dart';
import 'package:dataspikemobilesdk/domain/managers/dataspike_personal_data_fields_manager.dart';

abstract class DataspikeComponent {
  String get shortId;
  IDataspikeRepository get dataspikeRepository;
  VerificationManager get verificationManager;
  PersonalDataManager get personalDataManager;
  PermissionService get permissionService;
  bool get showMlScores;
  bool get livenessOnly;
  bool get livenessDryRun;
}

class DataspikeComponentImpl implements DataspikeComponent {
  final DataspikeModule _module;

  DataspikeComponentImpl(DataspikeDependencies dependencies)
      : _module = DataspikeModuleImpl(dependencies);

  @override
  String get shortId => _module.shortId;

  @override
  IDataspikeRepository get dataspikeRepository => _module.dataspikeRepository;

  @override
  VerificationManager get verificationManager => _module.verificationManager;

  @override
  PersonalDataManager get personalDataManager => _module.personalDataManager;

  @override
  PermissionService get permissionService => _module.permissionService;

  @override
  bool get showMlScores => _module.showMlScores;

  @override
  bool get livenessOnly => _module.livenessOnly;

  @override
  bool get livenessDryRun => _module.livenessDryRun;
}