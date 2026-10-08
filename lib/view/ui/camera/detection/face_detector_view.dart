// import 'package:dataspikemobilesdk/face_detector/pipeline/facepipeline.dart';
import 'package:flutter/material.dart';
import 'detector_view.dart';
import 'package:dataspikemobilesdk/view/ui/camera/two_arcs_painter.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'package:dataspikemobilesdk/face_detector/models/camera_frame_input.dart';
import 'package:dataspikemobilesdk/face_detector/models/captured_frame.dart';
import 'package:dataspikemobilesdk/face_detector/models/face_analyst_result.dart';
import 'package:dataspikemobilesdk/face_detector/face_pipeline_isolate.dart';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';
import 'ml_scores_overlay.dart';
import 'package:dataspikemobilesdk/domain/managers/isolate_image_processing.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({
    super.key,
    required this.onShootCallback,
    this.showMlScores = false,
    this.livenessDryRun = false,
  });

  /// Shows the raw ML scores panel on top of the preview (debug).
  final bool showMlScores;

  /// Debug: green state is only shown — no capture/upload, detection goes on.
  final bool livenessDryRun;

  final Future<void> Function(
    List<CapturedFrame> frames,
    Size previewKeySize,
    Size screenSize,
    Size previewSize,
  )
  onShootCallback;

  @override
  State<FaceDetectorView> createState() => FaceDetectorViewState();
}

class FaceDetectorViewState extends State<FaceDetectorView> {
  FacePipelineIsolate? _facePipeline;

  @override
  void initState() {
    super.initState();
    _initPipeline();
  }

  Future<void> _initPipeline() async {
    try {
      _facePipeline = await FacePipelineIsolate.create();
    } catch (_) {
      // Leave _facePipeline null; _processImage's guard keeps skipping
      // frames rather than crashing the screen.
    }
  }

  bool _isProcessing = false;
  bool _canProcess = true;
  CustomPaint? _customPaint;
  AvatarDetectionStatus _status = AvatarDetectionStatus.notStarted;

  bool _initialTimerAppeared = false;

  final ValueNotifier<MlScoresSnapshot?> _mlScores = ValueNotifier(null);

  // In dry-run mode the green (ok) state never captures, so it must not
  // freeze detection either.
  bool get _isStatusLocked =>
      _status.isAutoHideDisabled &&
      !(widget.livenessDryRun && _status == AvatarDetectionStatus.ok);
  int _analyzedFrames = 0;

  @override
  void dispose() {
    _canProcess = false;
    _facePipeline?.dispose();
    _mlScores.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      customPaint: _customPaint,
      onImage: _processImage,
      onShootCallback: _onShootCallback,
      onTimerReady: _onTimerReady,
      onRetry: _setUndetectedState,
      status: _status,
      livenessDryRun: widget.livenessDryRun,
      scoresOverlay: widget.showMlScores
          ? MlScoresOverlay(scores: _mlScores)
          : null,
    );
  }

  Future<void> _onTimerReady() async {
    _setUndetectedState();
  }

  Future<void> _setUndetectedState() async {
    if (_customPaint != null) {
      _customPaint = CustomPaint(painter: TwoArcsPainter());
    }
    _status = AvatarDetectionStatus.undetected;
    if (mounted) setState(() {});
  }

  Future<void> _onShootCallback(
    List<CapturedFrame> frames,
    Size previewKeySize,
    Size screenSize,
    Size previewSize,
  ) async {
    widget.onShootCallback(
      frames,
      previewKeySize,
      screenSize,
      previewSize,
    );
  }

  Future<void> _processImage(
    CameraFrameInput frame,
    AvatarCropRect avatarRect,
  ) async {
    if (!_canProcess) return;
    if (_isProcessing) return;
    if (_facePipeline == null) return;
    if (_isStatusLocked) {
      return;
    }

    if (!_initialTimerAppeared) {
      _initialTimerAppeared = true;
      _setStateIfChanged(null, AvatarDetectionStatus.initialTimer);
    }

    _isProcessing = true;

    try {
      final stopwatch = Stopwatch()..start();
      final result = await _facePipeline?.analyze(
        frame,
        avatarRect: avatarRect,
      );
      stopwatch.stop();

      if (result == null) {
        _publishScores(null, avatarRect, stopwatch, _status);
        // Don't let a single "no face" frame kick us out of a status that
        // must not be auto-hidden (e.g. the initial countdown, or a
        // just-reached "ok"/success moment) — only CameraView's own timer
        // (via _onTimerReady) is allowed to end the countdown.
        if (!_isStatusLocked) {
          _setUndetectedState();
        }
        return;
      }

      // Box coordinates are relative to the avatar crop, so is the area.
      final status = _evaluateHeadPosition(
        result: result,
        imageSize: Size(avatarRect.w.toDouble(), avatarRect.h.toDouble()),
      );
      _publishScores(result, avatarRect, stopwatch, status);

      final isTopArcHighlighted = status.isTopArcHighlighted;
      final isBottomArcHighlighted = status.isBottomArcHighlighted;

      final painter = TwoArcsPainter(
        isTopArcHighlighted: isTopArcHighlighted,
        isBottomArcHighlighted: isBottomArcHighlighted,
        highlightColor: status.arcColor,
        isArrowsEnabled: status.isArrowsEnabled,
      );

      final paint = CustomPaint(painter: painter);

      _setStateIfChanged(paint, status);
    } catch (_, _) {
    } finally {
      _isProcessing = false;
    }
  }

  void _publishScores(
    FaceAnalysisResult? result,
    AvatarCropRect avatarRect,
    Stopwatch stopwatch,
    AvatarDetectionStatus status,
  ) {
    if (!widget.showMlScores) return;
    final box = result?.boundingBox;
    _mlScores.value = MlScoresSnapshot(
      frameNumber: ++_analyzedFrames,
      updatedAt: DateTime.now(),
      processingMs: stopwatch.elapsedMicroseconds / 1000,
      result: result,
      faceAreaFraction: box == null
          ? null
          : box.width * box.height / (avatarRect.w * avatarRect.h),
      status: status,
    );
  }

  void _setStateIfChanged(
    CustomPaint? newPaint,
    AvatarDetectionStatus newStatus,
  ) {
    if (_isStatusLocked) {
      return;
    }

    if (newStatus != _status || newPaint?.painter != _customPaint?.painter) {
      _status = newStatus;
      _customPaint = newPaint;
      if (mounted) setState(() {});
    }
  }

  void setExternalError(AvatarDetectionStatus newStatus) {
    _status = newStatus;
    _customPaint = null;
    if (mounted) setState(() {});
  }

  void setSuccessStatus() {
    _status = AvatarDetectionStatus.success;

    final painter = TwoArcsPainter(
      isTopArcHighlighted: true,
      isBottomArcHighlighted: true,
      highlightColor: _status.arcColor,
      isArrowsEnabled: false,
    );

    final paint = CustomPaint(painter: painter);
    _customPaint = paint;
    if (mounted) setState(() {});
  }

  void removeStatus() {
    _status = AvatarDetectionStatus.notStarted;
    _customPaint = null;
    if (mounted) setState(() {});
  }

  AvatarDetectionStatus _evaluateHeadPosition({
    required FaceAnalysisResult result,
    required Size imageSize,
    double minFaceAreaFraction = CameraConstants.minFaceAreaFraction,
  }) {
    final box = result.boundingBox;

    if (result.isTooBright) {
      return AvatarDetectionStatus.tooBright;
    }

    if (result.isTooDark) {
      return AvatarDetectionStatus.tooDark;
    }

    if (result.isBlurry) {
      return AvatarDetectionStatus.lowQuality;
    }

    if (!result.isChinVisible) {
      return AvatarDetectionStatus.chinIsNotVisible;
    }
    if (!result.isForeheadVisible) {
      return AvatarDetectionStatus.foreheadisNotVidible;
    }

    final faceArea = box.width * box.height;
    final frameArea = imageSize.width * imageSize.height;
    if (frameArea > 0 && (faceArea / frameArea) < minFaceAreaFraction) {
      return AvatarDetectionStatus.tooFar;
    }

    if (!result.isHeadPoseAcceptable) {
      return AvatarDetectionStatus.lookStraight;
    }

    final eyeStatus = result.eyeStatus;
    // Average of both eyes, as on the server; a single narrow eye is not
    // enough (it rejected ~19% of valid selfies in the ML test set).
    if (eyeStatus['bothEyesClosed']!) {
      return AvatarDetectionStatus.closedEyes;
    }

    return AvatarDetectionStatus.ok;
  }
}
