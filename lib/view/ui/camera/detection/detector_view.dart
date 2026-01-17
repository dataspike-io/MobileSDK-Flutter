import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'camera_view.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'dart:typed_data';

class DetectorView extends StatefulWidget {
  const DetectorView({
    super.key,
    required this.onImage,
    required this.onShootCallback,
    this.status,
    this.customPaint,
    this.onCameraFeedReady,
  });

  final CustomPaint? customPaint;
  final Function(InputImage inputImage, double cropRatio) onImage;
  final Future<void> Function(
    Uint8List imageBytes,
    Size previewKeySize, 
    Size screenSize,
    Size previewSize
  ) onShootCallback;
  final Function()? onCameraFeedReady;
  final AvatarDetectionStatus? status;

  @override
  State<DetectorView> createState() => _DetectorViewState();
}

class _DetectorViewState extends State<DetectorView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CameraView(
      customPaint: widget.customPaint,
      onImage: widget.onImage,
      onCameraFeedReady: widget.onCameraFeedReady,
      onShootCallback: widget.onShootCallback,
      status: widget.status,
    );
  }
}
