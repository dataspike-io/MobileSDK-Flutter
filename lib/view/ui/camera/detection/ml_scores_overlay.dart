import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'package:dataspikemobilesdk/face_detector/models/face_analyst_result.dart';
import 'package:dataspikemobilesdk/face_detector/pipeline/facepipeline.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/brightness_checker/brightness_checker.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_landmarks_detector/postprocessing/face_landmarks_postprocessor.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/face_landmarks_detector/postprocessing/head_pose_estimator.dart';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';

/// One analyzed camera frame, as shown by [MlScoresOverlay].
class MlScoresSnapshot {
  final int frameNumber;
  final DateTime updatedAt;
  final double processingMs;

  /// Null when no face passed the detector / landmarks presence check.
  final FaceAnalysisResult? result;
  final double? faceAreaFraction;
  final AvatarDetectionStatus status;

  const MlScoresSnapshot({
    required this.frameNumber,
    required this.updatedAt,
    required this.processingMs,
    required this.result,
    required this.faceAreaFraction,
    required this.status,
  });
}

/// Debug panel with the raw on-device ML scores of the latest analyzed frame
/// and the thresholds they are checked against. Enabled with
/// `DataspikeDependencies.showMlScores`; red values fail their check.
class MlScoresOverlay extends StatelessWidget {
  const MlScoresOverlay({super.key, required this.scores});

  final ValueListenable<MlScoresSnapshot?> scores;

  static const _ok = Color(0xFF7CFC8A);
  static const _bad = Color(0xFFFF6B6B);
  static const _label = Color(0xFFB0B0B0);
  static const _text = Colors.white;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<MlScoresSnapshot?>(
        valueListenable: scores,
        builder: (context, s, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'monospace',
                fontFamilyFallback: ['Menlo', 'Courier'],
                fontSize: 10.5,
                height: 1.35,
                color: _text,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: s == null
                    ? [const Text('ML scores: waiting for first frame…')]
                    : _lines(s),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _lines(MlScoresSnapshot s) {
    final r = s.result;
    final t = s.updatedAt;
    String two(int v) => v.toString().padLeft(2, '0');
    final time =
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.'
        '${(t.millisecond ~/ 100)}';

    final header = _row([
      _v('#${s.frameNumber}'),
      _l('  $time  '),
      _v('${s.processingMs.toStringAsFixed(0)} ms'),
      _l('  status '),
      _v(s.status.name),
    ]);
    if (r == null) {
      return [header, _row([_err('no face (detector or landmarks < ${FacePipeline.facePresenceThreshold})')])];
    }

    final pose = r.headPose;
    final avgEar = (r.leftEar + r.rightEar) / 2;
    final area = s.faceAreaFraction ?? 0;

    return [
      header,
      _row([
        _l('face  det '),
        _v(_f(r.detectionScore, 2)),
        _l('  lm '),
        _c(
          _f(r.facePresenceScore, 2),
          r.facePresenceScore >= FacePipeline.facePresenceThreshold,
        ),
        _l('  area '),
        _c(_f(area, 2), area >= CameraConstants.minFaceAreaFraction),
        _l(' ≥${CameraConstants.minFaceAreaFraction}'),
      ]),
      _row([
        _l('blur  '),
        _c(_f(r.blurScore, 3), r.blurScore <= FacePipeline.blurThreshold),
        _l(' ≤${FacePipeline.blurThreshold}  streak '),
        _c(
          '${r.blurryFrames}/${FacePipeline.blurryFramesToFlag}',
          !r.isBlurry,
        ),
      ]),
      _row([
        _l('light '),
        _c(_f(r.brightRatio, 2), !r.isTooBright),
        _l(' ≤${BrightnessChecker.highIlluminationThreshold}  dark '),
        _c(_f(r.darkRatio, 2), !r.isTooDark),
        _l(' ≤${BrightnessChecker.lowIlluminationThreshold}'),
      ]),
      _row(
        pose == null
            ? [_l('pose  '), _err('not estimated')]
            : [
                _l('pose  p '),
                _c(
                  _f(pose['pitch']!, 1),
                  pose['pitch']!.abs() < HeadPoseEstimator.maxPitch,
                ),
                _l(' y '),
                _c(
                  _f(pose['yaw']!, 1),
                  pose['yaw']!.abs() < HeadPoseEstimator.maxYaw,
                ),
                _l(' r '),
                _c(
                  _f(pose['roll']!, 1),
                  pose['roll']!.abs() < HeadPoseEstimator.maxRoll,
                ),
                _l(
                  '  <${HeadPoseEstimator.maxPitch.toStringAsFixed(0)}/'
                  '${HeadPoseEstimator.maxYaw.toStringAsFixed(0)}/'
                  '${HeadPoseEstimator.maxRoll.toStringAsFixed(0)}°',
                ),
              ],
      ),
      _row([
        _l('eyes  L '),
        _v(_f(r.leftEar, 3)),
        _l(' R '),
        _v(_f(r.rightEar, 3)),
        _l(' avg '),
        _c(_f(avgEar, 3), avgEar >= FaceLandmarksPostprocessor.earThreshold),
        _l(' ≥${FaceLandmarksPostprocessor.earThreshold}'),
      ]),
      _row([
        _l('chin '),
        _c(r.isChinVisible ? 'yes' : 'no', r.isChinVisible),
        _l('  forehead '),
        _c(r.isForeheadVisible ? 'yes' : 'no', r.isForeheadVisible),
      ]),
    ];
  }

  static String _f(double v, int digits) => v.toStringAsFixed(digits);

  static Widget _row(List<InlineSpan> spans) =>
      Text.rich(TextSpan(children: spans));

  static TextSpan _l(String s) =>
      TextSpan(text: s, style: const TextStyle(color: _label));
  static TextSpan _v(String s) => TextSpan(text: s);
  static TextSpan _c(String s, bool ok) =>
      TextSpan(text: s, style: TextStyle(color: ok ? _ok : _bad));
  static TextSpan _err(String s) =>
      TextSpan(text: s, style: const TextStyle(color: _bad));
}
