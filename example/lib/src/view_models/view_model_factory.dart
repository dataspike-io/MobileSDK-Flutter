import 'input_view_model.dart';
import '../data/use_cases/create_verification_use_case.dart';
import '../dependencies_provider/sample_app_injector.dart';

class InputViewModelFactory {
  T create<T>() {
    if (T == InputViewModel) {
      return InputViewModel(
        createVerificationUseCase: CreateVerificationUseCase(
          sampleAppRepositoryProvider: () => SampleAppInjector.component.sampleAppRepository,
        ),
        newVerificationUiMapper: SampleAppInjector.component.newVerificationUiMapper,
      ) as T;
    } else {
      throw Exception('Unknown ViewModel Type');
    }
  }
}