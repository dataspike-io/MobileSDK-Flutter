import 'dart:io';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dataspikemobilesdk/view/ui/camera/avatar_instruction_pill.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';
import 'package:dataspikemobilesdk/view/ui/camera/face_oval_outside_clipper.dart';
import 'package:dataspikemobilesdk/view/ui/camera/default_face_corner_painter.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

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
    List<Uint8List> imageBytesList,
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
  DateTime? _lastFrameTime;
  Completer<CameraImage>? _captureCompleter;

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
    final camHeight = screenSize.height * 0.8;

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
                                      filter: ui.ImageFilter.blur(
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
                          bottom: 30,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: AvatarInstructionPill(
                              status: widget.status,
                              firstAction: () {
                                if (widget.status.isButtonEnabled) {
                                  Navigator.of(context).pop();
                                }
                              },
                              secondAction: () {
                                if (widget.status.isAdditionalButtonEnabled) {
                                  Navigator.of(
                                    context,
                                    rootNavigator: true,
                                  ).pop();
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
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

  @override
  void didUpdateWidget(covariant CameraView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.status == AvatarDetectionStatus.ok &&
        oldWidget.status != AvatarDetectionStatus.ok) {
      _triggerCapture(MediaQuery.of(context).size);
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
    if (_captureCompleter != null && !_captureCompleter!.isCompleted) {
      _captureCompleter!.complete(image);
      return;
    }

    final now = DateTime.now();
    if (_lastFrameTime != null &&
        now.difference(_lastFrameTime!) < const Duration(milliseconds: 900)) {
      return;
    }
    _lastFrameTime = now;

    if (_containerAR == null) return;

    final imgImage = _convertCameraImage(image);
    if (imgImage == null) return;

    final ps = _controller!.value.previewSize!;
    final previewAR = ps.height / ps.width;
    final coverScale = previewAR / _containerAR!;
    final fraction = 1 - coverScale;

    widget.onImage(imgImage, fraction);
  }

  img.Image? _convertCameraImage(CameraImage image) {
    if (Platform.isAndroid) {
      return _convertYUV420Preview(image);
    } else if (Platform.isIOS) {
      return _convertBGRA(image);
    }
    return null;
  }

  img.Image _convertYUV420Preview(CameraImage image, {int step = 2}) {
    final dstW = image.width ~/ step;
    final dstH = image.height ~/ step;
    final yPlane = image.planes[0].bytes;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;
    final yRowStride = image.planes[0].bytesPerRow;
    final uvRowStride = image.planes[1].bytesPerRow;
    final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

    final rgba = Uint8List(dstW * dstH * 4);
    for (int dy = 0; dy < dstH; dy++) {
      final sy = dy * step;
      for (int dx = 0; dx < dstW; dx++) {
        final sx = dx * step;
        final yValue = yPlane[sy * yRowStride + sx] & 0xFF;
        final uvIndex = (sy ~/ 2) * uvRowStride + (sx ~/ 2) * uvPixelStride;
        final u = (uPlane[uvIndex] & 0xFF) - 128;
        final v = (vPlane[uvIndex] & 0xFF) - 128;
        final r = (yValue + 1.402 * v).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * u - 0.714136 * v).clamp(0, 255).toInt();
        final b = (yValue + 1.772 * u).clamp(0, 255).toInt();
        final idx = (dy * dstW + dx) * 4;
        rgba[idx] = r;
        rgba[idx + 1] = g;
        rgba[idx + 2] = b;
        rgba[idx + 3] = 255;
      }
    }

    final rgbImage = img.Image.fromBytes(
      width: dstW,
      height: dstH,
      bytes: rgba.buffer,
      order: img.ChannelOrder.rgba,
    );
    return img.copyRotate(rgbImage, angle: -90);
  }

  img.Image _convertBGRA(CameraImage image, {int step = 2}) {
    if (step == 1) {
      return img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: image.planes[0].bytes.buffer,
        order: img.ChannelOrder.bgra,
      );
    }

    final srcBytes = image.planes[0].bytes;
    final srcRowBytes = image.planes[0].bytesPerRow;
    final dstW = image.width ~/ step;
    final dstH = image.height ~/ step;

    final out = Uint8List(dstW * dstH * 4);
    for (int dy = 0; dy < dstH; dy++) {
      final srcRowOffset = (dy * step) * srcRowBytes;
      for (int dx = 0; dx < dstW; dx++) {
        final srcIdx = srcRowOffset + (dx * step) * 4;
        final dstIdx = (dy * dstW + dx) * 4;
        out[dstIdx] = srcBytes[srcIdx];
        out[dstIdx + 1] = srcBytes[srcIdx + 1];
        out[dstIdx + 2] = srcBytes[srcIdx + 2];
        out[dstIdx + 3] = srcBytes[srcIdx + 3];
      }
    }

    return img.Image.fromBytes(
      width: dstW,
      height: dstH,
      bytes: out.buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  Future<void> _triggerCapture(Size screenSize) async {
    List<Uint8List> bytesList;

    if (Platform.isIOS) {
      final frames = <_RgbaFrameData>[];

      for (int i = 0; i < 4; i++) {
        _captureCompleter = Completer<CameraImage>();
        final image = await _captureCompleter!.future;
        _captureCompleter = null;

        final completer = Completer<ui.Image>();
        ui.decodeImageFromPixels(
          image.planes[0].bytes,
          image.width,
          image.height,
          ui.PixelFormat.bgra8888,
          completer.complete,
          rowBytes: image.planes[0].bytesPerRow,
        );
        final uiImage = await completer.future;
        final byteData = await uiImage.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        uiImage.dispose();

        if (byteData != null) {
          frames.add(
            _RgbaFrameData(
              rgbaBytes: byteData.buffer.asUint8List(),
              width: image.width,
              height: image.height,
            ),
          );
        }
      }

      bytesList = await compute(
        _encodeJpegBatchIsolate,
        _JpegEncodeBatchPayload(frames: frames, quality: 90),
      );
    } else {
      final frames = <_YuvFrameData>[];

      for (int i = 0; i < 4; i++) {
        _captureCompleter = Completer<CameraImage>();
        final image = await _captureCompleter!.future;
        _captureCompleter = null;

        frames.add(
          _YuvFrameData(
            yPlane: image.planes[0].bytes,
            uPlane: image.planes[1].bytes,
            vPlane: image.planes[2].bytes,
            width: image.width,
            height: image.height,
            yRowStride: image.planes[0].bytesPerRow,
            uvRowStride: image.planes[1].bytesPerRow,
            uvPixelStride: image.planes[1].bytesPerPixel ?? 1,
          ),
        );
      }

      bytesList = await compute(
        _convertAndEncodeYuvBatchIsolate,
        _YuvCaptureBatchPayload(frames: frames, quality: 80),
      );
    }

    if (bytesList.isEmpty) return;

    final renderBox =
        _previewKey.currentContext?.findRenderObject() as RenderBox?;
    final previewKeySize = renderBox?.size ?? Size.zero;
    final previewSize = _controller!.value.previewSize!;

    await widget.onShootCallback(
      bytesList,
      previewKeySize,
      screenSize,
      previewSize,
    );
  }
}

class _RgbaFrameData {
  final Uint8List rgbaBytes;
  final int width, height;
  _RgbaFrameData({
    required this.rgbaBytes,
    required this.width,
    required this.height,
  });
}

class _JpegEncodeBatchPayload {
  final List<_RgbaFrameData> frames;
  final int quality;
  _JpegEncodeBatchPayload({required this.frames, required this.quality});
}

List<Uint8List> _encodeJpegBatchIsolate(_JpegEncodeBatchPayload batch) {
  return batch.frames.map((f) {
    final imgImage = img.Image.fromBytes(
      width: f.width,
      height: f.height,
      bytes: f.rgbaBytes.buffer,
      order: img.ChannelOrder.rgba,
    );
    return Uint8List.fromList(img.encodeJpg(imgImage, quality: batch.quality));
  }).toList();
}

class _YuvFrameData {
  final Uint8List yPlane, uPlane, vPlane;
  final int width, height, yRowStride, uvRowStride, uvPixelStride;
  _YuvFrameData({
    required this.yPlane,
    required this.uPlane,
    required this.vPlane,
    required this.width,
    required this.height,
    required this.yRowStride,
    required this.uvRowStride,
    required this.uvPixelStride,
  });
}

class _YuvCaptureBatchPayload {
  final List<_YuvFrameData> frames;
  final int quality;
  _YuvCaptureBatchPayload({required this.frames, required this.quality});
}

List<Uint8List> _convertAndEncodeYuvBatchIsolate(
  _YuvCaptureBatchPayload batch,
) {
  return batch.frames.map((p) {
    final rgba = Uint8List(p.width * p.height * 4);
    for (int y = 0; y < p.height; y++) {
      for (int x = 0; x < p.width; x++) {
        final yValue = p.yPlane[y * p.yRowStride + x] & 0xFF;
        final uvIndex = (y ~/ 2) * p.uvRowStride + (x ~/ 2) * p.uvPixelStride;
        final u = (p.uPlane[uvIndex] & 0xFF) - 128;
        final v = (p.vPlane[uvIndex] & 0xFF) - 128;
        final r = (yValue + 1.402 * v).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * u - 0.714136 * v).clamp(0, 255).toInt();
        final b = (yValue + 1.772 * u).clamp(0, 255).toInt();
        final idx = (y * p.width + x) * 4;
        rgba[idx] = r;
        rgba[idx + 1] = g;
        rgba[idx + 2] = b;
        rgba[idx + 3] = 255;
      }
    }
    final rgbImage = img.Image.fromBytes(
      width: p.width,
      height: p.height,
      bytes: rgba.buffer,
      order: img.ChannelOrder.rgba,
    );
    final rotated = img.copyRotate(rgbImage, angle: -90);
    return Uint8List.fromList(img.encodeJpg(rotated, quality: batch.quality));
  }).toList();
}
