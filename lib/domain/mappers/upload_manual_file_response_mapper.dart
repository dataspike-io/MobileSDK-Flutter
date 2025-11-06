import 'package:dataspikemobilesdk/data/models/response/upload_manual_file_response.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_manual_file_state.dart';

class UploadManualFileResponseMapper {
  UploadManualFileState map({
    UploadManualFileResponse? response,
    Object? error,
  }) {
    if (response != null) {
      return UploadManualFileStateSuccess(
        message: response.message ?? "",
      );
    } else if (error is UploadManualFileResponse) {
      return UploadManualFileStateError(
        message: error.message ?? "Unknown error occurred",
      );
    } else {
      return UploadManualFileStateError(
        message: "Unknown error occurred",
      );
    }
  }
}