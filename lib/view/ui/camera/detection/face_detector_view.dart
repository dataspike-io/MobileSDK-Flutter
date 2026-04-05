import 'package:dataspikemobilesdk/face_detector/pipeline/facepipeline.dart';
import 'package:flutter/material.dart';
// import 'package:image/image.dart';
import 'detector_view.dart';
import 'package:dataspikemobilesdk/view/ui/camera/two_arcs_painter.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'dart:typed_data';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';
import 'package:image/image.dart' as img;
import 'package:dataspikemobilesdk/face_detector/models/face_analyst_result.dart';
import 'package:dataspikemobilesdk/face_detector/ml_processing/brightness_checker/brightness_checker.dart';

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
  FacePipeline? _facePipeline;

  @override
  void initState() {
    super.initState();
    _initPipeline();
  }

  Future<void> _initPipeline() async {
    _facePipeline = await FacePipeline.create();
  }

  bool _isProcessing = false;
  bool _canProcess = true;
  CustomPaint? _customPaint;
  AvatarDetectionStatus? _status;

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

  DateTime? _lastProcessed;
  Duration _throttleDuration = Duration(milliseconds: 500);

  Future<void> _processImage(img.Image image, double cropRatio) async {
    if (!_canProcess) return;
    if (_isProcessing) return;
    if (_facePipeline == null) return;

    final now = DateTime.now();
    if (_lastProcessed != null &&
        now.difference(_lastProcessed!) < _throttleDuration) {
      return;
    }

    _lastProcessed = now;
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
      final result = await _facePipeline?.analyze(image);

      if (result == null) {
        final painter = TwoArcsPainter(
          isTopArcHighlighted: false,
          isBottomArcHighlighted: false
        );
        _customPaint = CustomPaint(painter: painter);
        _status = null;
        _isProcessing = false;
        if (mounted) setState(() {});
        return;
      }

      final status = _evaluateHeadPosition(
        result: result,
        cropRatio: cropRatio,
        imageSize: Size(image.width.toDouble(), image.height.toDouble()),
      );

      _status = status;

      final painter = TwoArcsPainter(
        isTopArcHighlighted: status == AvatarDetectionStatus.tooHigh,
        isBottomArcHighlighted: status == AvatarDetectionStatus.tooLow,
      );
      _customPaint = CustomPaint(painter: painter);
      _isProcessing = false;

      if (mounted) setState(() {});
    } catch (e, stack) {
      print('CRASH: $e');
      print('STACK: $stack');
    } finally {
      _isProcessing = false;
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

    if (normalizedCenterY < topFraction) return AvatarDetectionStatus.tooHigh;
    if (normalizedCenterY > bottomFraction) return AvatarDetectionStatus.tooLow;

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

    return AvatarDetectionStatus.ok;
  }
}
