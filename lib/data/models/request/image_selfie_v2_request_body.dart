/// On-device model versions reported per frame for analytics, so the
/// backend can track when the liveness models change. Values are the model
/// paths as published on the CDN (same identifiers as the web SDK).
class LivenessBatchModelVersions {
  static const String iqaBlurModel =
      'models/v3/iqa_mobilenetv3small100_sigmoid.tflite';
  static const String mediapipeModel =
      'models/v4/face_landmarks_detector.tflite';
  static const Map<String, String> otherModels = {
    'face_detector': 'models/v4/face_detector.tflite',
  };

  static Map<String, dynamic> toJson() => {
    'iqa_blur_model': iqaBlurModel,
    'mediapipe_model': mediapipeModel,
    'other_models': otherModels,
  };
}

class LivenessBatchFrameMeta {
  final String frameId;

  const LivenessBatchFrameMeta({required this.frameId});

  Map<String, dynamic> toJson() => {
    'frame_id': frameId,
    'model_versions': LivenessBatchModelVersions.toJson(),
  };
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