import 'package:flutter/material.dart';
import 'main/models/dataspike_dependencies.dart';
import 'main/manager/dataspike_manager.dart';
import 'main/models/verification_completion.dart';

class Dataspikemobilesdk {
  Future<void> startDataspikeFlow({
    required BuildContext context,
    required DataspikeDependencies dependencies,
    required VerificationCompletedCallback callback,
  }) async {
    DataspikeManager.startDataspikeFlow(
      dependencies: dependencies,
      callback: callback,
      context: context,
    );
  }
}
