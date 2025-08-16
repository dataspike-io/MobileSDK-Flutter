import 'package:dataspikemobilesdk/main/models/dataspike_dependencies.dart';
import 'dataspike_module.dart';
import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/domain/managers/dataspike_verification_manager.dart';

abstract class DataspikeComponent {
  String get shortId;
  IDataspikeRepository get dataspikeRepository;
  VerificationManager get verificationManager;
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
}