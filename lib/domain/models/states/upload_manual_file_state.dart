abstract class UploadManualFileState {}

class UploadManualFileStateSuccess extends UploadManualFileState {
  final String message;

  UploadManualFileStateSuccess({required this.message});
}

class UploadManualFileStateError extends UploadManualFileState {
  final String message;

  UploadManualFileStateError({required this.message});
}
