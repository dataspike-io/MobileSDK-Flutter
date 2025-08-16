import 'package:dataspikemobilesdk/data/models/response/dataspike_empty_response.dart';
import 'package:dataspikemobilesdk/data/models/response/dataspike_http_error_response.dart';
import 'package:dataspikemobilesdk/domain/models/states/empty_state.dart';

class EmptyResponseMapper {
  EmptyState map({
    DataspikeEmptyResponse? response,
    Object? error,
  }) {
    if (response != null) {
      return EmptyStateSuccess();
    } else if (error is DataspikeHttpErrorResponse) {
      return EmptyStateError(
        error: error.error ?? "Unknown error occurred",
        details: error.details ?? "Try again later",
      );
    } else {
      return EmptyStateError(
        error: "Unknown error occurred",
        details: "Try again later",
      );
    }
  }
}