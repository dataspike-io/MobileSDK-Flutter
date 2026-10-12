import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:dataspikemobilesdk/face_detector/face_pipeline_isolate.dart';
import 'package:dataspikemobilesdk/face_detector/models/camera_frame_input.dart';
import 'package:dataspikemobilesdk/face_detector/models/face_analyst_result.dart';

/// On-device ML scores of one captured liveness photo.
class CapturedFrameScore {
  /// The exact JPEG that is (or would be) uploaded.
  final Uint8List jpeg;
  final int width;
  final int height;

  /// Null when no face passed the detector / landmarks presence check.
  final FaceAnalysisResult? result;

  const CapturedFrameScore({
    required this.jpeg,
    required this.width,
    required this.height,
    required this.result,
  });

  double? get faceAreaFraction {
    final box = result?.boundingBox;
    if (box == null || width == 0 || height == 0) return null;
    return box.width * box.height / (width * height);
  }
}

/// Debug: scores the uploaded liveness photos with the on-device pipeline,
/// each one on its own — no pose smoothing, no blurry-streak rule — and the
/// whole photo as the frame, since it already is the avatar-mask crop.
class CapturedFramesScorer {
  static Future<List<CapturedFrameScore>> score(List<Uint8List> jpegs) async {
    final images = await compute(_decodeAll, jpegs);
    final pipeline = await FacePipelineIsolate.create();
    try {
      final scores = <CapturedFrameScore>[];
      for (int i = 0; i < jpegs.length; i++) {
        final image = images[i];
        FaceAnalysisResult? result;
        if (image != null) {
          await pipeline.resetState();
          result = await pipeline.analyze(CameraFrameInput.decoded(image));
        }
        scores.add(
          CapturedFrameScore(
            jpeg: jpegs[i],
            width: image?.width ?? 0,
            height: image?.height ?? 0,
            result: result,
          ),
        );
      }
      return scores;
    } finally {
      pipeline.dispose();
    }
  }

  static List<img.Image?> _decodeAll(List<Uint8List> jpegs) =>
      jpegs.map(img.decodeJpg).toList();
}
