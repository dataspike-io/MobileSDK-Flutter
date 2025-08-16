import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/dependencies_provider/dataspike_injector.dart';
import '../models/dataspike_verifications_status.dart';
import '../models/verification_completion.dart';
import '../models/dataspike_dependencies.dart';
import '../coordinator/coordinator.dart';

class DataspikeManager {
  static VerificationCompletedCallback? _verificationCompletedCallback;

  static void startDataspikeFlow({
    required DataspikeDependencies dependencies,
    required VerificationCompletedCallback callback,
    required BuildContext context,
  }) {
    DataspikeInjector.setComponent(dependencies);
    _verificationCompletedCallback = callback;

    DataspikeCoordinator.startFlow(context);
  }

  static void passVerificationCompletedResult(DataspikeVerificationStatus status) {
    _verificationCompletedCallback?.call(status);
    _verificationCompletedCallback = null;
  }
}