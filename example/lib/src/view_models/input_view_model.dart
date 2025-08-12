import 'package:flutter/foundation.dart';
import '../dependencies_provider/sample_app_injector.dart';
import '../dependencies_provider/model/sample_app_dependencies.dart';
import '../domain/mappers/new_verification_ui_mapper.dart';
import '../data/use_cases/create_verification_use_case.dart';
import '../view/models/new_verification_ui_state.dart';

class InputViewModel extends ChangeNotifier {
  SampleAppDependencies dependencies = SampleAppDependencies.dependencies;

  final CreateVerificationUseCase createVerificationUseCase;
  final NewVerificationUiMapper newVerificationUiMapper;

  InputViewModel({
    required this.createVerificationUseCase,
    required this.newVerificationUiMapper,
  });

  final List<VoidCallback> _listeners = [];
  NewVerificationUiState? _verificationState;

  NewVerificationUiState? get verificationState => _verificationState;

  Future<void> createVerification() async {
    SampleAppInjector.setComponent(dependencies);

    if (dependencies.shortId.isEmpty) {
      final state = newVerificationUiMapper.map(
        await createVerificationUseCase.call(),
      );
      _verificationState = state;
      notifyListeners();
    } else {
      _verificationState = NewVerificationUiSuccess(shortId: dependencies.shortId);
      notifyListeners();
    }
  }

  void onApiTokenChanged(String token) {
    dependencies = SampleAppDependencies(
      isDebug: dependencies.isDebug,
      dsApiToken: token,
      shortId: dependencies.shortId,
    );
  }

  void onIsDebugChanged(bool checked) {
    dependencies = SampleAppDependencies(
      isDebug: checked,
      dsApiToken: dependencies.dsApiToken,
      shortId: dependencies.shortId,
    );
  }

  void onShortIdChanged(String shortId) {
    dependencies = SampleAppDependencies(
      isDebug: dependencies.isDebug,
      dsApiToken: dependencies.dsApiToken,
      shortId: shortId,
    );
  }
}