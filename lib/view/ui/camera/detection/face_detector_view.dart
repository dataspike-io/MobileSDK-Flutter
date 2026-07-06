// import 'package:dataspikemobilesdk/face_detector/pipeline/facepipeline.dart';
import 'package:flutter/material.dart';
import 'detector_view.dart';
import 'package:dataspikemobilesdk/view/ui/camera/two_arcs_painter.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:dataspikemobilesdk/face_detector/models/face_analyst_result.dart';
import 'package:dataspikemobilesdk/face_detector/face_pipeline_isolate.dart';
import 'package:flutter/services.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({super.key, required this.onShootCallback});

  final Future<void> Function(
    List<Uint8List> imageBytesList,
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
    _facePipeline = await FacePipelineIsolate.create();
  }

  bool _isProcessing = false;
  bool _canProcess = true;
  CustomPaint? _customPaint;
  AvatarDetectionStatus _status = AvatarDetectionStatus.notStarted;

  bool _initialTimerAppeared = false;

  @override
  void dispose() {
    _canProcess = false;
    _facePipeline?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetectorView(
      customPaint: _customPaint,
      onImage: _processImage,
      onShootCallback: _onShootCallback,
      onTimerReady: _onTimerReady,
      status: _status,
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
    List<Uint8List> imageBytesList,
    Size previewKeySize,
    Size screenSize,
    Size previewSize,
  ) async {
    widget.onShootCallback(
      imageBytesList,
      previewKeySize,
      screenSize,
      previewSize,
    );
  }

  Future<void> _processImage(img.Image image, double cropRatio) async {
    if (!_canProcess) return;
    if (_isProcessing) return;
    if (_facePipeline == null) return;
    if (_status.isAutoHideDisabled) {
      return;
    }

    if (!_initialTimerAppeared) {
      _initialTimerAppeared = true;
      _setStateIfChanged(null, AvatarDetectionStatus.initialTimer);
    }

    _isProcessing = true;

    try {
      final result = await _facePipeline?.analyze(image, cropRatio: cropRatio);

      if (result == null) {
        _setUndetectedState();
        return;
      }

      final status = _evaluateHeadPosition(
        result: result,
        cropRatio: cropRatio,
        imageSize: Size(image.width.toDouble(), image.height.toDouble()),
      );

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

  void _setStateIfChanged(
    CustomPaint? newPaint,
    AvatarDetectionStatus newStatus,
  ) {
    if (_status.isAutoHideDisabled) {
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
    required double cropRatio,
    double minFaceAreaFraction = 0.1,
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
    if (eyeStatus['leftEyeClosed']! ||
        eyeStatus['rightEyeClosed']! ||
        eyeStatus['bothEyesClosed']!) {
      return AvatarDetectionStatus.closedEyes;
    }

    return AvatarDetectionStatus.ok;
  }
}
