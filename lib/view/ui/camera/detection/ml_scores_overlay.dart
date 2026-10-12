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

/// Dark rounded box with the monospace style shared by the ML score panels.
class MlScoresPanel extends StatelessWidget {
  const MlScoresPanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
          color: MlScoresDetails.text,
        ),
        child: child,
      ),
    );
  }
}

/// Debug panel with the raw on-device ML scores of the latest analyzed frame
/// and the thresholds they are checked against. Enabled with
/// `DataspikeDependencies.showMlScores`; red values fail their check.
class MlScoresOverlay extends StatelessWidget {
  const MlScoresOverlay({super.key, required this.scores});

  final ValueListenable<MlScoresSnapshot?> scores;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ValueListenableBuilder<MlScoresSnapshot?>(
        valueListenable: scores,
        builder: (context, s, _) {
          return MlScoresPanel(
            child: s == null
                ? const Text('ML scores: waiting for first frame…')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _header(s),
                      MlScoresDetails(
                        result: s.result,
                        faceAreaFraction: s.faceAreaFraction,
                        showBlurStreak: true,
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _header(MlScoresSnapshot s) {
    final t = s.updatedAt;
    String two(int v) => v.toString().padLeft(2, '0');
    final time =
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}.'
        '${(t.millisecond ~/ 100)}';
    return MlScoresDetails.row([
      MlScoresDetails.value('#${s.frameNumber}'),
      MlScoresDetails.label('  $time  '),
      MlScoresDetails.value('${s.processingMs.toStringAsFixed(0)} ms'),
      MlScoresDetails.label('  status '),
      MlScoresDetails.value(s.status.name),
    ]);
  }
}

/// Score lines for one analyzed image: each value next to its threshold,
/// green when it passes and red when it fails. Expects to sit inside an
/// [MlScoresPanel] (or another monospace DefaultTextStyle).
class MlScoresDetails extends StatelessWidget {
  const MlScoresDetails({
    super.key,
    required this.result,
    required this.faceAreaFraction,
    this.showBlurStreak = false,
  });

  /// Null when no face passed the detector / landmarks presence check.
  final FaceAnalysisResult? result;
  final double? faceAreaFraction;

  /// Live preview only: the blurry-frames streak is meaningless for a
  /// single photo.
  final bool showBlurStreak;

  static const ok = Color(0xFF7CFC8A);
  static const bad = Color(0xFFFF6B6B);
  static const muted = Color(0xFFB0B0B0);
  static const text = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: _lines(),
    );
  }

  List<Widget> _lines() {
    final r = result;
    if (r == null) {
      return [
        row([
          error(
            'no face (detector or landmarks < '
            '${FacePipeline.facePresenceThreshold})',
          ),
        ]),
      ];
    }

    final pose = r.headPose;
    final avgEar = (r.leftEar + r.rightEar) / 2;
    final area = faceAreaFraction ?? 0;

    return [
      row([
        label('face  det '),
        value(_f(r.detectionScore, 2)),
        label('  lm '),
        check(
          _f(r.facePresenceScore, 2),
          r.facePresenceScore >= FacePipeline.facePresenceThreshold,
        ),
        label('  area '),
        check(_f(area, 2), area >= CameraConstants.minFaceAreaFraction),
        label(' ≥${CameraConstants.minFaceAreaFraction}'),
      ]),
      row([
        label('blur  '),
        check(_f(r.blurScore, 3), r.blurScore <= FacePipeline.blurThreshold),
        label(' ≤${FacePipeline.blurThreshold}'),
        if (showBlurStreak) ...[
          label('  streak '),
          check(
            '${r.blurryFrames}/${FacePipeline.blurryFramesToFlag}',
            !r.isBlurry,
          ),
        ],
      ]),
      row([
        label('light '),
        check(_f(r.brightRatio, 2), !r.isTooBright),
        label(' ≤${BrightnessChecker.highIlluminationThreshold}  dark '),
        check(_f(r.darkRatio, 2), !r.isTooDark),
        label(' ≤${BrightnessChecker.lowIlluminationThreshold}'),
      ]),
      row(
        pose == null
            ? [label('pose  '), error('not estimated')]
            : [
                label('pose  p '),
                check(
                  _f(pose['pitch']!, 1),
                  pose['pitch']!.abs() < HeadPoseEstimator.maxPitch,
                ),
                label(' y '),
                check(
                  _f(pose['yaw']!, 1),
                  pose['yaw']!.abs() < HeadPoseEstimator.maxYaw,
                ),
                label(' r '),
                check(
                  _f(pose['roll']!, 1),
                  pose['roll']!.abs() < HeadPoseEstimator.maxRoll,
                ),
                label(
                  '  <${HeadPoseEstimator.maxPitch.toStringAsFixed(0)}/'
                  '${HeadPoseEstimator.maxYaw.toStringAsFixed(0)}/'
                  '${HeadPoseEstimator.maxRoll.toStringAsFixed(0)}°',
                ),
              ],
      ),
      row([
        label('eyes  L '),
        value(_f(r.leftEar, 3)),
        label(' R '),
        value(_f(r.rightEar, 3)),
        label(' avg '),
        check(
          _f(avgEar, 3),
          avgEar >= FaceLandmarksPostprocessor.earThreshold,
        ),
        label(' ≥${FaceLandmarksPostprocessor.earThreshold}'),
      ]),
      row([
        label('chin '),
        check(r.isChinVisible ? 'yes' : 'no', r.isChinVisible),
        label('  forehead '),
        check(r.isForeheadVisible ? 'yes' : 'no', r.isForeheadVisible),
      ]),
    ];
  }

  static String _f(double v, int digits) => v.toStringAsFixed(digits);

  static Widget row(List<InlineSpan> spans) =>
      Text.rich(TextSpan(children: spans));

  static TextSpan label(String s) =>
      TextSpan(text: s, style: const TextStyle(color: muted));
  static TextSpan value(String s) => TextSpan(text: s);
  static TextSpan check(String s, bool passed) =>
      TextSpan(text: s, style: TextStyle(color: passed ? ok : bad));
  static TextSpan error(String s) =>
      TextSpan(text: s, style: const TextStyle(color: bad));
}
