import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dataspikemobilesdk/view/ui/camera/avatar_instruction_pill.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:dataspikemobilesdk/view/ui/continue_circle_button.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
    required this.customPaint,
    required this.onImage,
    required this.onShootCallback,
    this.status,
    this.onCameraFeedReady,
  });

  final CustomPaint? customPaint;
  final Function(InputImage inputImage, double cropRatio) onImage;
  final Future<void> Function(
    Uint8List imageBytes,
    Size previewKeySize,
    Size screenSize,
    Size previewSize,
  )
  onShootCallback;
  final VoidCallback? onCameraFeedReady;
  final AvatarDetectionStatus? status;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double? _containerAR;

  @override
  void initState() {
    super.initState();

    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == CameraLensDirection.front) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _liveFeedBody(context);
  }

  Widget _liveFeedBody(BuildContext context) {
    final previewKey = GlobalKey();
    final screenSize = MediaQuery.of(context).size;

    final camWidth = screenSize.width;
    final camHeight = screenSize.height * 0.65;

    if (_cameras.isEmpty) return Container();
    if (_controller == null) return Container();
    if (_controller?.value.isInitialized == false) return Container();

    return LayoutBuilder(
      builder: (context, c) {
        _containerAR = camWidth / camHeight;

        final ps = _controller!.value.previewSize!;
        final previewAR = ps.height / ps.width;
        final coverScale = previewAR / _containerAR!;
        final coverScaleRation = coverScale >= 1 ? coverScale : 1 / coverScale;

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Center(
              child: SizedBox(
                key: previewKey,
                width: camWidth,
                height: camHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.scale(
                        scale: coverScaleRation,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: previewAR,
                            child: CameraPreview(
                              _controller!,
                              child: widget.customPaint,
                            ),
                          ),
                        ),
                      ),

                      if (widget.status != null)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: AvatarInstructionPill(
                              status: widget.status!,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            CircularContinueButton(
              onPressed: () => _shootImage(
                previewKey.currentContext?.size ?? Size.zero,
                screenSize,
              ),
            ),
          ],
        );
      },
    );
  }

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller?.lockCaptureOrientation(DeviceOrientation.portraitUp);
      _controller?.setFlashMode(FlashMode.off);
      _controller?.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
      });
      setState(() {});
    });
  }

  Future _shootImage(Size previewKeySize, Size screenSize) async {
    if (_controller != null && _controller!.value.isInitialized) {
      final previewSize = _controller!.value.previewSize!;
      final file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();

      await widget.onShootCallback(
        bytes,
        previewKeySize,
        screenSize,
        previewSize,
      );
    }
  }

  Future _stopLiveFeed() async {
    if (_controller == null) return;
    if (!(_controller?.value.isInitialized ?? false)) return;

    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;

    final ps = _controller!.value.previewSize!;
    final previewAR = ps.height / ps.width;
    final coverScale = previewAR / _containerAR!;
    final fraction = 1 - coverScale;

    widget.onImage(inputImage, fraction);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }
}
