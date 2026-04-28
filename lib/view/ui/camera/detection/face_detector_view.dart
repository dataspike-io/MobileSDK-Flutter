import 'package:dataspikemobilesdk/face_detector/pipeline/facepipeline.dart';
import 'package:flutter/material.dart';
import 'detector_view.dart';
import 'package:dataspikemobilesdk/view/ui/camera/two_arcs_painter.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'dart:typed_data';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';
import 'package:image/image.dart' as img;
import 'package:dataspikemobilesdk/face_detector/models/face_analyst_result.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/brightness_checker/brightness_checker.dart';
import 'package:dataspikemobilesdk/face_detector/face_pipeline_isolate.dart';

class FaceDetectorView extends StatefulWidget {
  const FaceDetectorView({super.key, required this.onShootCallback});

  final Future<void> Function(
    Uint8List imageBytes,
    Size previewKeySize,
    Size screenSize,
    Size previewSize,
  )
  onShootCallback;

  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
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
      status: _status,
    );
  }

  Future<void> _onShootCallback(
    Uint8List imageBytes,
    Size previewKeySize,
    Size screenSize,
    Size previewSize,
  ) async {
    widget.onShootCallback(imageBytes, previewKeySize, screenSize, previewSize);
  }

  Future<void> _processImage(img.Image image, double cropRatio) async {
    if (!_canProcess) return;
    if (_isProcessing) return;
    if (_facePipeline == null) return;

    _isProcessing = true;

    final brightness = BrightnessChecker.check(image);
    final isTooDark = BrightnessChecker.isTooDark(brightness);
    final isTooBright = BrightnessChecker.isTooBright(brightness);

    if (isTooBright) {
      _status = AvatarDetectionStatus.tooBright;
      _isProcessing = false;
      if (mounted) setState(() {});
      return;
    }

    if (isTooDark) {
      _status = AvatarDetectionStatus.tooDark;
      _isProcessing = false;
      if (mounted) setState(() {});
      return;
    }

    try {
      final result = await _facePipeline?.analyze(image, cropRatio: cropRatio);

      if (result == null) {
        if (_customPaint != null) {
          _customPaint = CustomPaint(painter: TwoArcsPainter());
        }
        _status = AvatarDetectionStatus.undetected;
        if (mounted) setState(() {});
        return;
      }

      final status = _evaluateHeadPosition(
        result: result,
        cropRatio: cropRatio,
        imageSize: Size(image.width.toDouble(), image.height.toDouble()),
      );

      final isTopArcHighlighted =
          status == AvatarDetectionStatus.tooHigh ||
          status == AvatarDetectionStatus.success;
      final isBottomArcHighlighted =
          status == AvatarDetectionStatus.tooLow ||
          status == AvatarDetectionStatus.success;

      final painter = TwoArcsPainter(
        isTopArcHighlighted: isTopArcHighlighted,
        isBottomArcHighlighted: isBottomArcHighlighted,
        highlightColor: status.arcColor,
        isShownSecondaryArcLayer: status == AvatarDetectionStatus.ok,
        isArrowsEnabled: status == AvatarDetectionStatus.tooFar,
      );

      final paint = CustomPaint(painter: painter);

      _setStateIfChanged(paint, status);
    } catch (e, stack) {
      // print('CRASH: $e');
      // print('STACK: $stack');
    } finally {
      _isProcessing = false;
    }
  }

  void _setStateIfChanged(
    CustomPaint? newPaint,
    AvatarDetectionStatus newStatus,
  ) {
    if (newStatus != _status || newPaint?.painter != _customPaint?.painter) {
      _status = newStatus;
      _customPaint = newPaint;
      if (mounted) setState(() {});
    }
  }

  AvatarDetectionStatus _evaluateHeadPosition({
    required FaceAnalysisResult result,
    required Size imageSize,
    required double cropRatio,
    double topFraction = 0.33,
    double bottomFraction = 0.56,
    double minFaceAreaFraction = 0.1,
  }) {
    final box = result.boundingBox;
    final bottomApexFromBottomPct =
        CameraConstants.avatarBottomApexFromBottomPct;
    final topApexPct = CameraConstants.avatarTopApexPct;
    final apexDiff = bottomApexFromBottomPct - topApexPct;

    final double normalizedCenterY;

    if (imageSize.aspectRatio < 1) {
      normalizedCenterY = box.centerY / imageSize.height - apexDiff;
    } else {
      normalizedCenterY = box.centerY / imageSize.height - cropRatio - apexDiff;
    }

    // if (normalizedCenterY < topFraction) return AvatarDetectionStatus.tooHigh;
    // if (normalizedCenterY > bottomFraction) return AvatarDetectionStatus.tooLow;
    if (!result.isChinVisible) return AvatarDetectionStatus.chinIsNotVisible;
    if (!result.isForeheadVisible)
      return AvatarDetectionStatus.foreheadisNotVidible;

    final faceArea = box.width * box.height;
    final frameArea = imageSize.width * imageSize.height;
    if (frameArea > 0 && (faceArea / frameArea) < minFaceAreaFraction) {
      return AvatarDetectionStatus.tooFar;
    }
    
    if (!result.isHeadPoseAcceptable) {
      return AvatarDetectionStatus.lookStraight;
    }

    final eyeStatus = result.eyeStatus;
    if (eyeStatus['leftEyeClosed']! || eyeStatus['rightEyeClosed']!) {
      return AvatarDetectionStatus.closedEyes;
    }

    if (result.isBlurry) {
      return AvatarDetectionStatus.lowQuality;
    }

    return AvatarDetectionStatus.ok;
  }
}
