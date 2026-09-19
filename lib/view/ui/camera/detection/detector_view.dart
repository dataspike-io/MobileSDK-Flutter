import 'package:flutter/material.dart';
import 'camera_view.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'package:dataspikemobilesdk/face_detector/models/camera_frame_input.dart';
import 'package:dataspikemobilesdk/face_detector/models/captured_frame.dart';

class DetectorView extends StatefulWidget {
  const DetectorView({
    super.key,
    required this.onImage,
    required this.onShootCallback,
    required this.status,
    this.customPaint,
    this.onCameraFeedReady,
    this.onTimerReady,
    this.onRetry,
  });

  final CustomPaint? customPaint;
  final Function(CameraFrameInput frame, double cropRatio) onImage;
  final Future<void> Function(
    List<CapturedFrame> frames,
    Size previewKeySize,
    Size screenSize,
    Size previewSize
  ) onShootCallback;
  final Function()? onCameraFeedReady;
  final Function()? onTimerReady;
  final VoidCallback? onRetry;
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
      onTimerReady: widget.onTimerReady,
      onRetry: widget.onRetry,
      status: widget.status,
    );
  }
}
