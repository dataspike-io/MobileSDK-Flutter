import '../models/new_verification_state.dart';
import '../../view/models/new_verification_ui_state.dart';

class NewVerificationUiMapper {
  NewVerificationUiState map(NewVerificationState state) {
    if (state is NewVerificationSuccess) {
      return NewVerificationUiSuccess(
        shortId: state.verificationUrlId,
      );
    } else if (state is NewVerificationError) {
      return NewVerificationUiError(
        error: state.error,
        details: state.validationError,
      );
    } else {
      throw Exception('Unknown NewVerificationState');
    }
  }
}
