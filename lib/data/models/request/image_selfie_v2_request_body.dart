class LivenessBatchFrameMeta {
  final String frameId;

  const LivenessBatchFrameMeta({required this.frameId});

  Map<String, dynamic> toJson() => {'frame_id': frameId};
}

class LivenessBatchMetadata {
  final List<LivenessBatchFrameMeta> frames;

  const LivenessBatchMetadata({required this.frames});

  Map<String, dynamic> toJson() => {
    'frames': frames.map((f) => f.toJson()).toList(),
  };
}

class LivenessBatchFrame {
  final String frameId; 
  final List<int> fileBytes;
  final String ext;
  final String fileName;

  const LivenessBatchFrame({
    required this.frameId,
    required this.fileBytes,
    required this.ext,
    required this.fileName,
  });
}