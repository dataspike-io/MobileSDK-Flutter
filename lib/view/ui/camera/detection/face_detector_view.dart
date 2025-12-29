import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'detector_view.dart';
import 'package:dataspikemobilesdk/view/ui/camera/two_arcs_painter.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'dart:typed_data';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';

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
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
      enableLandmarks: true,
      minFaceSize: 0.3,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  AvatarDetectionStatus? _status;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
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

  Future<void> _processImage(InputImage inputImage, double cropRatio) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;

    final faces = await _faceDetector.processImage(inputImage);

    AvatarDetectionStatus? status;

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      status = _evaluateHeadPosition(
        faces: faces,
        cropRatio: cropRatio,
        imageSize: inputImage.metadata!.size,
      );
      _status = status;

      final painter = TwoArcsPainter(
        isTopArcHighlighted: status == AvatarDetectionStatus.tooHigh,
        isBottomArcHighlighted: status == AvatarDetectionStatus.tooLow,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _customPaint = CustomPaint(painter: TwoArcsPainter());
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  AvatarDetectionStatus _evaluateHeadPosition({
    required List<Face> faces,
    required Size imageSize,
    required double cropRatio,
    double topFraction = 0.33, // old values 0.33
    double bottomFraction = 0.56, // old values 0.66
    double minFaceAreaFraction = 0.1,
    double closedEyesProbabilityThreshold = 0.1,
    double yRotationThreshold = 20, // |Y| > → the face turned away on y AXES
    double xRotationThreshold = 20, // |X| > → the face turned away on x AXES
  }) {
    if (faces.isEmpty || imageSize.height == 0 || imageSize.width == 0) {
      return AvatarDetectionStatus.notVisible;
    }

    final Face primary = faces.reduce((a, b) {
      final aArea = a.boundingBox.width * a.boundingBox.height;
      final bArea = b.boundingBox.width * b.boundingBox.height;
      return aArea >= bArea ? a : b;
    });

    final bottomApexFromBottomPct = CameraConstants.avatarBottomApexFromBottomPct;
    final topApexPct = CameraConstants.avatarTopApexPct;
    final apexDiff = bottomApexFromBottomPct - topApexPct;

    final rect = primary.boundingBox;
    final double normalizedCenterY;

    if (imageSize.aspectRatio < 1) {
      normalizedCenterY = rect.center.dy / (imageSize.height) - apexDiff;
    } else {
      normalizedCenterY = (rect.center.dy / (imageSize.height)) - cropRatio - apexDiff;
    }

    if (primary.leftEyeOpenProbability != null &&
        primary.rightEyeOpenProbability != null) {
      final leftEyeClosed =
          primary.leftEyeOpenProbability! < closedEyesProbabilityThreshold;
      final rightEyeClosed =
          primary.rightEyeOpenProbability! < closedEyesProbabilityThreshold;

      if (leftEyeClosed || rightEyeClosed) {
        return AvatarDetectionStatus.closedEyes;
      }
    }

    final yaw = primary.headEulerAngleY;
    final pitch = primary.headEulerAngleX;
    if ((yaw != null && yaw.abs() > yRotationThreshold) ||
        (pitch != null && pitch.abs() > xRotationThreshold)) {
      return AvatarDetectionStatus.lookStraight;
    }

    if (normalizedCenterY < topFraction) return AvatarDetectionStatus.tooHigh;
    if (normalizedCenterY > bottomFraction) return AvatarDetectionStatus.tooLow;

    final faceArea = rect.width * rect.height;
    final frameArea = imageSize.width * imageSize.height;

    if (frameArea > 0 && (faceArea / frameArea) < minFaceAreaFraction) {
      return AvatarDetectionStatus.tooFar;
    }

    return AvatarDetectionStatus.ok;
  }
}
