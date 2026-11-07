// import 'package:dataspikemobilesdk/face_detector/pipeline/facepipeline.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'detector_view.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/camera/two_arcs_painter.dart';
import 'package:dataspikemobilesdk/domain/managers/liveness_error_tracker.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'package:dataspikemobilesdk/face_detector/models/camera_frame_input.dart';
import 'package:dataspikemobilesdk/face_detector/models/captured_frame.dart';
import 'package:dataspikemobilesdk/face_detector/models/face_analyst_result.dart';
import 'package:dataspikemobilesdk/face_detector/face_pipeline_isolate.dart';
import 'package:dataspikemobilesdk/face_detector/pipeline/facepipeline.dart';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';
import 'ml_scores_overlay.dart';
import 'package:dataspikemobilesdk/domain/managers/isolate_image_processing.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({
    super.key,
    required this.onShootCallback,
    this.showMlScores = false,
    this.livenessDryRun = false,
    this.showCapturedFrameScores = false,
  });

  /// Shows the raw ML scores panel on top of the preview (debug).
  final bool showMlScores;

  /// Debug: nothing is uploaded. Unless [showCapturedFrameScores], green is
  /// only shown — no capture — and detection goes on.
  final bool livenessDryRun;

  /// Debug: the captured photos are scored and shown instead of the result.
  final bool showCapturedFrameScores;

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
  // Tier 2 hint stays on screen for 3-4 seconds.
  static const _hintDuration = Duration(milliseconds: 3500);

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

  // Photos are taken on green unless it is a plain dry run (nothing to
  // score or send).
  bool get _captureOnOk =>
      !widget.livenessDryRun || widget.showCapturedFrameScores;

  // When green captures nothing it must not freeze detection either.
  bool get _isStatusLocked =>
      _status.isAutoHideDisabled &&
      !(!_captureOnOk && _status == AvatarDetectionStatus.ok);
  int _analyzedFrames = 0;

  // Progressive error handling (see "Error handling logic in Liveness"):
  // Tier 1 is a red oval, Tier 2 a timed hint pill, Tier 3 an interruption
  // that stops the analysis until the user taps "Try again".
  final _errorTracker = LivenessErrorTracker();
  Timer? _hintTimer;
  AvatarDetectionStatus? _hintStatus;
  AvatarDetectionStatus? _lastError;
  bool _isInterrupted = false;

  // Frames are not analyzed while the user must tap "Try again" or while a
  // status that must not be auto-hidden is on screen.
  bool get _isAnalysisPaused => _isInterrupted || _isStatusLocked;

  @override
  void dispose() {
    _canProcess = false;
    _hintTimer?.cancel();
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
      onRetry: _onRetry,
      status: _status,
      captureOnOk: _captureOnOk,
      validateCaptureFrame: _validateCapturePhoto,
      onCaptureFailed: removeStatus,
      scoresOverlay: widget.showMlScores
          ? MlScoresOverlay(scores: _mlScores)
          : null,
      isInterrupted: _isInterrupted,
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

  // "Try again" starts the grace period again; its countdown is driven by
  // CameraView, which calls _onTimerReady once it is over.
  void _onRetry() {
    _resetErrorState();
    _customPaint = null;
    _status = AvatarDetectionStatus.initialTimer;
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
    if (_isAnalysisPaused) {
      return;
    }

    if (!_initialTimerAppeared) {
      _initialTimerAppeared = true;
      _setStateIfChanged(null, AvatarDetectionStatus.initialTimer);
      return;
    }

    _isProcessing = true;

    try {
      final stopwatch = Stopwatch()..start();
      final result = await _facePipeline?.analyze(
        frame,
        avatarRect: avatarRect,
      );
      stopwatch.stop();

      // The screen may have moved on while this frame was being analyzed
      // (interruption, retry, backend result): drop the stale result.
      if (!_canProcess || _isAnalysisPaused) {
        return;
      }

      // No face at all is the same error as a face that is not in frame.
      // Box coordinates are relative to the avatar crop, so is the area.
      final status = result == null
          ? AvatarDetectionStatus.lookStraight
          : _evaluateHeadPosition(
              result: result,
              imageSize: Size(
                avatarRect.w.toDouble(),
                avatarRect.h.toDouble(),
              ),
            );
      _publishScores(result, avatarRect, stopwatch, status);

      _handleFrameStatus(status);
    } catch (_, _) {
    } finally {
      _isProcessing = false;
    }
  }

  // A photo goes into the liveness batch only if it passes the per-photo
  // check; each one is judged on its own (no smoothing, no blur streak).
  Future<bool> _validateCapturePhoto(
    CameraFrameInput frame,
    AvatarCropRect? avatarRect,
  ) async {
    final pipeline = _facePipeline;
    if (pipeline == null) return false;
    try {
      await pipeline.resetState();
      final result = await pipeline.analyze(frame, avatarRect: avatarRect);
      return result != null && FacePipeline.isGoodLivenessPhoto(result);
    } catch (_) {
      return false;
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

  void _handleFrameStatus(AvatarDetectionStatus status) {
    final outcome = _errorTracker.onFrame(status.errorGroup);

    // A clean frame: counters are already reset, a visible hint goes away
    // (the capture is about to start).
    if (outcome == null) {
      _lastError = null;
      _cancelHint();

      final painter = TwoArcsPainter(
        isTopArcHighlighted: status.isTopArcHighlighted,
        isBottomArcHighlighted: status.isBottomArcHighlighted,
        highlightColor: status.arcColor,
        isArrowsEnabled: status.isArrowsEnabled,
      );
      _setStateIfChanged(CustomPaint(painter: painter), status);
      return;
    }

    _lastError = status;

    if (outcome == LivenessFrameOutcome.showHint) {
      _startHint(status);
    } else if (outcome == LivenessFrameOutcome.interrupt &&
        _hintTimer == null) {
      _interrupt(status);
      return;
    }
    // While a hint is still visible the interruption waits for it to hide
    // (see _onHintExpired).

    _setStateIfChanged(
      _errorPaint(status),
      _hintStatus ?? AvatarDetectionStatus.undetected,
    );
  }

  // The oval stays red for as long as the current frame has an error,
  // whichever tier is active.
  CustomPaint _errorPaint(AvatarDetectionStatus error) {
    return CustomPaint(
      painter: TwoArcsPainter(
        isTopArcHighlighted: true,
        isBottomArcHighlighted: true,
        highlightColor: AppColors.lightRed,
        isArrowsEnabled: error.isArrowsEnabled,
      ),
    );
  }

  void _startHint(AvatarDetectionStatus error) {
    _hintStatus = error;
    _hintTimer?.cancel();
    _hintTimer = Timer(_hintDuration, _onHintExpired);
  }

  void _cancelHint() {
    _hintTimer?.cancel();
    _hintTimer = null;
    _hintStatus = null;
  }

  void _onHintExpired() {
    final expired = _hintStatus;
    _hintTimer = null;
    _hintStatus = null;
    if (!mounted || _isInterrupted) return;

    final error = _lastError;
    if (error != null && _errorTracker.isInterruptionDue) {
      _interrupt(error);
    } else if (_status == expired) {
      // The error may well still be there: the oval keeps its red paint.
      _status = AvatarDetectionStatus.undetected;
      setState(() {});
    }
  }

  void _interrupt(AvatarDetectionStatus error) {
    _cancelHint();
    _isInterrupted = true;
    _status = error;
    _customPaint = _errorPaint(error);
    if (mounted) setState(() {});
  }

  void _resetErrorState() {
    _cancelHint();
    _errorTracker.reset();
    _lastError = null;
    _isInterrupted = false;
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
    _resetErrorState();
    _status = newStatus;
    _customPaint = null;
    if (mounted) setState(() {});
  }

  void setSuccessStatus() {
    _resetErrorState();
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
    _resetErrorState();
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
