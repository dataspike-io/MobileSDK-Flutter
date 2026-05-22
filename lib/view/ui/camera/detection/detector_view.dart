import 'package:flutter/material.dart';
import 'camera_view.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class DetectorView extends StatefulWidget {
  const DetectorView({
    super.key,
    required this.onImage,
    required this.onShootCallback,
    required this.status,
    this.customPaint,
    this.onCameraFeedReady,
  });

  final CustomPaint? customPaint;
  final Function(img.Image inputImage, double cropRatio) onImage;
  final Future<void> Function(
    List<Uint8List> imageBytesList,
    Size previewKeySize, 
    Size screenSize,
    Size previewSize
  ) onShootCallback;
  final Function()? onCameraFeedReady;
  final AvatarDetectionStatus status;

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
