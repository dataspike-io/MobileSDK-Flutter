/// Server errors for one stored liveness frame.
class DataspikeFrameErrorsDomainModel {
  final String? documentId;
  final List<DataspikeErrorDomainModel> errors;

  const DataspikeFrameErrorsDomainModel({
    required this.documentId,
    required this.errors,
  });
}

class DataspikeErrorDomainModel {
  final int code;
  final String message;

  const DataspikeErrorDomainModel({
    required this.code,
    required this.message,
  });
}