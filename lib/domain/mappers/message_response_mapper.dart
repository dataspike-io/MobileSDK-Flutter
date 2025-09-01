import 'package:dataspikemobilesdk/data/models/response/dataspike_http_error_response.dart';
import 'package:dataspikemobilesdk/data/models/response/dataspike_profile_fields_response.dart';
import 'package:dataspikemobilesdk/domain/models/states/message_state.dart';

class MessageResponseMapper {
  MessageState map({
    DataspikeProfileFieldsResponse? response,
    Object? error,
  }) {
    if (response != null) {
      return MessageStateSuccess(
        message: response.message ?? "Operation completed successfully",
      );
    } else if (error is DataspikeHttpErrorResponse) {
      return MessageStateError(
        error: error.error ?? "Unknown error occurred",
        details: error.details ?? "Try again later",
      );
    } else {
      return MessageStateError(
        error: "Unknown error occurred",
        details: "Try again later",
      );
    }
  }
}