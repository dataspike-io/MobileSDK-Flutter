import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dataspikemobilesdk/view/ui/camera/avatar_instruction_pill.dart';
import 'package:dataspikemobilesdk/view/ui/continue_circle_button.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'package:dataspikemobilesdk/view/ui/camera/face_oval_outside_clipper.dart';
import 'package:dataspikemobilesdk/view/ui/camera/default_face_corner_painter.dart';

import 'package:image/image.dart' as img;
import 'dart:ui';

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
    this.customPaint,
    required this.onImage,
    required this.onShootCallback,
    required this.status,
    this.onCameraFeedReady,
  });

  final CustomPaint? customPaint;
  final Function(img.Image inputImage, double cropRatio) onImage;
  final Future<void> Function(
    Uint8List imageBytes,
    Size previewKeySize,
    Size screenSize,
    Size previewSize,
  )
  onShootCallback;
  final VoidCallback? onCameraFeedReady;
  final AvatarDetectionStatus status;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  double? _containerAR;
  final _previewKey = GlobalKey();

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
                key: _previewKey,
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
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CameraPreview(_controller!),

                                if (widget.customPaint != null)
                                  ClipPath(
                                    clipper: FaceOvalOutsideClipper(),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 6,
                                        sigmaY: 6,
                                      ),
                                      child: Container(
                                        color: AppColors.blackBlur,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      widget.customPaint != null
                          ? Transform.scale(
                              scale: coverScaleRation,
                              child: Center(
                                child: AspectRatio(
                                  aspectRatio: previewAR,
                                  child: widget.customPaint!,
                                ),
                              ),
                            )
                          : CustomPaint(painter: DefaultFaceCornersPainter()),

                      if (widget.status.isVisible)
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: AvatarInstructionPill(
                              status: widget.status,
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
                _previewKey.currentContext?.size ?? Size.zero,
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
          ? ImageFormatGroup.yuv420
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
    if (_containerAR == null) return;

    final imgImage = _convertCameraImage(image);
    if (imgImage == null) return;

    // final imgImage = _convertCameraImage(image);
    // if (imgImage == null) return;

    final ps = _controller!.value.previewSize!;
    final previewAR = ps.height / ps.width;
    final coverScale = previewAR / _containerAR!;
    final fraction = 1 - coverScale;

    widget.onImage(imgImage, fraction);
  }

  img.Image? _convertCameraImage(CameraImage image) {
    if (Platform.isAndroid) {
      // NV21 → img.Image
      return _convertYUV420(image);
    } else if (Platform.isIOS) {
      // BGRA8888 → img.Image
      return _convertBGRA(image);
    }
    return null;
  }

  img.Image _convertBGRA(CameraImage image) {
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  img.Image _convertYUV420(CameraImage image) {
    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    final rgbImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yValue = yPlane[y * width + x] & 0xFF;
        final uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);
        final u = (uPlane[uvIndex] & 0xFF) - 128;
        final v = (vPlane[uvIndex] & 0xFF) - 128;

        final r = (yValue + 1.402 * v).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * u - 0.714136 * v).clamp(0, 255).toInt();
        final b = (yValue + 1.772 * u).clamp(0, 255).toInt();

        rgbImage.setPixelRgb(x, y, r, g, b);
      }
    }

    return img.copyRotate(rgbImage, angle: 90);
  }

  // CHECK LATER WHICH IS FASTER
  // img.Image _convertYUV420(CameraImage image) {
  // final width = image.width;
  // final height = image.height;
  // final yPlane = image.planes[0].bytes;
  // final uPlane = image.planes[1].bytes;
  // final vPlane = image.planes[2].bytes;
  // final uvRowStride = image.planes[1].bytesPerRow;
  // final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

  // // Create RGBA buffer directly
  // final rgba = Uint8List(width * height * 4);

  // for (int y = 0; y < height; y++) {
  //   for (int x = 0; x < width; x++) {
  //     final yValue = yPlane[y * image.planes[0].bytesPerRow + x] & 0xFF;
  //     final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
  //     final u = (uPlane[uvIndex] & 0xFF) - 128;
  //     final v = (vPlane[uvIndex] & 0xFF) - 128;

  //     final r = (yValue + 1.402 * v).clamp(0, 255).toInt();
  //     final g = (yValue - 0.344136 * u - 0.714136 * v).clamp(0, 255).toInt();
  //     final b = (yValue + 1.772 * u).clamp(0, 255).toInt();

  //     final idx = (y * width + x) * 4;
  //     rgba[idx] = r;
  //     rgba[idx + 1] = g;
  //     rgba[idx + 2] = b;
  //     rgba[idx + 3] = 255;
  //   }
  // }

  //   final rgbImage = img.Image.fromBytes(
  //     width: width,
  //     height: height,
  //     bytes: rgba.buffer,
  //     order: img.ChannelOrder.rgba,
  //   );

  //   return img.copyRotate(rgbImage, angle: 90);
  // }
}
