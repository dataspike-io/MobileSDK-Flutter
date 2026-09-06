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
import 'package:dataspikemobilesdk/face_detector/models/camera_frame_input.dart';
import 'package:dataspikemobilesdk/face_detector/models/captured_frame.dart';
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
    this.onTimerReady,
  });

  final CustomPaint? customPaint;
  final Function(CameraFrameInput frame, double cropRatio) onImage;
  final Future<void> Function(
    List<CapturedFrame> frames,
    Size previewKeySize,
    Size screenSize,
    Size previewSize,
  )
  onShootCallback;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onTimerReady;
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

  Timer? _countdownTimer;
  int _countdownValue = 5;

  Timer? _successDotsTimer;
  bool _showSuccessDots = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    if (widget.status == AvatarDetectionStatus.initialTimer) {
      _startCountdown();
    }
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
    _cancelCountdown();
    _successDotsTimer?.cancel();
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
                          : CustomPaint(
                              painter: DefaultFaceCornersPainter(
                                countdownValue:
                                    widget.status ==
                                        AvatarDetectionStatus.initialTimer
                                    ? _countdownValue
                                    : null,
                              ),
                            ),
                      if (widget.status.isVisible || _showSuccessDots)
                        Positioned(
                          bottom: 30,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: _showSuccessDots
                                ? const _SuccessDotsLoader()
                                : AvatarInstructionPill(
                                    status: widget.status,
                                    firstAction: () {
                                      if (widget.status.isButtonEnabled) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                    secondAction: () {
                                      if (widget
                                          .status
                                          .isAdditionalButtonEnabled) {
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
      _startSuccessDotsTimer();
    } else if (widget.status != AvatarDetectionStatus.ok &&
        oldWidget.status == AvatarDetectionStatus.ok) {
      _successDotsTimer?.cancel();
      if (_showSuccessDots) {
        setState(() => _showSuccessDots = false);
      }
    }

    if (widget.status == AvatarDetectionStatus.initialTimer &&
        oldWidget.status != AvatarDetectionStatus.initialTimer) {
      _startCountdown();
    } else if (widget.status != AvatarDetectionStatus.initialTimer &&
        oldWidget.status == AvatarDetectionStatus.initialTimer) {
      _cancelCountdown();
    }
  }

  void _startSuccessDotsTimer() {
    _successDotsTimer?.cancel();
    _successDotsTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _showSuccessDots = true);
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownValue = 5;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _countdownValue--);
      if (_countdownValue <= 0) {
        timer.cancel();
        _countdownTimer = null;
        if (widget.onTimerReady != null) {
          widget.onTimerReady!();
        }
      }
    });
  }

  void _cancelCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
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

    final frame = _buildFrameInput(image);
    if (frame == null) return;

    final ps = _controller!.value.previewSize!;
    final previewAR = ps.height / ps.width;
    final coverScale = previewAR / _containerAR!;
    final fraction = 1 - coverScale;

    widget.onImage(frame, fraction);
  }

  // Both platforms hand off raw, unconverted camera bytes and let the
  // pipeline isolate do the per-pixel conversion (YUV->RGB + rotate on
  // Android, BGRA downsample+copy on iOS), so the UI isolate never does
  // that work, however cheap it might be on a given platform.
  CameraFrameInput? _buildFrameInput(CameraImage image) {
    if (Platform.isAndroid) {
      return CameraFrameInput.yuv420Rotated90(
        yPlane: image.planes[0].bytes,
        uPlane: image.planes[1].bytes,
        vPlane: image.planes[2].bytes,
        sensorWidth: image.width,
        sensorHeight: image.height,
        yRowStride: image.planes[0].bytesPerRow,
        uvRowStride: image.planes[1].bytesPerRow,
        uvPixelStride: image.planes[1].bytesPerPixel ?? 1,
        step: 2,
      );
    } else if (Platform.isIOS) {
      return CameraFrameInput.bgraRaw(
        bgraBytes: image.planes[0].bytes,
        sensorWidth: image.width,
        sensorHeight: image.height,
        bgraRowStride: image.planes[0].bytesPerRow,
        step: 2,
      );
    }
    return null;
  }

  // Captures 4 frames and hands off their raw (already correctly
  // oriented) RGBA pixels, deliberately *not* JPEG-encoded — the crop
  // step (processAvatarShotInIsolate) does the one-and-only JPEG encode
  // after cropping, instead of an encode here that just gets decoded
  // and thrown away moments later.
  Future<void> _triggerCapture(Size screenSize) async {
    List<CapturedFrame> frames;

    if (Platform.isIOS) {
      final captured = <CapturedFrame>[];

      for (int i = 0; i < 4; i++) {
        _captureCompleter = Completer<CameraImage>();
        final image = await _captureCompleter!.future;
        _captureCompleter = null;

        // ui.decodeImageFromPixels needs the Flutter engine's raster
        // context, so it has to run here rather than in a background
        // isolate — but it's a fast, hardware-accelerated decode, not a
        // per-pixel Dart loop, so that's cheap.
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
          captured.add(
            CapturedFrame(
              rgbaBytes: byteData.buffer.asUint8List(),
              width: image.width,
              height: image.height,
            ),
          );
        }
      }

      frames = captured;
    } else {
      final yuvFrames = <_YuvFrameData>[];

      for (int i = 0; i < 4; i++) {
        _captureCompleter = Completer<CameraImage>();
        final image = await _captureCompleter!.future;
        _captureCompleter = null;

        yuvFrames.add(
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

      frames = await compute(_convertYuvBatchIsolate, yuvFrames);
    }

    if (frames.isEmpty) return;

    final renderBox =
        _previewKey.currentContext?.findRenderObject() as RenderBox?;
    final previewKeySize = renderBox?.size ?? Size.zero;
    final previewSize = _controller!.value.previewSize!;

    await widget.onShootCallback(
      frames,
      previewKeySize,
      screenSize,
      previewSize,
    );
  }
}

class _SuccessDotsLoader extends StatefulWidget {
  const _SuccessDotsLoader();

  @override
  State<_SuccessDotsLoader> createState() => _SuccessDotsLoaderState();
}

class _SuccessDotsLoaderState extends State<_SuccessDotsLoader>
    with TickerProviderStateMixin {
  static const _dotCount = 3;
  static const _pulseDuration = Duration(milliseconds: 500);
  static const _stagger = Duration(milliseconds: 200);

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _fades;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _dotCount,
      (_) => AnimationController(vsync: this, duration: _pulseDuration),
    );
    _fades = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeInOut))
        .toList();

    for (var i = 0; i < _dotCount; i++) {
      Future.delayed(_stagger * i, () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_dotCount, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: FadeTransition(
            opacity: _fades[i],
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
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

// Converts + rotates in a single pass instead of building an unrotated
// RGBA buffer and then running a separate copyRotate(-90) pass over it —
// each source pixel is written directly to its final rotated position.
// The destination mapping (dstX = y, dstY = (width-1) - x) is exactly
// what copyRotate(angle: -90) produces (verified byte-for-byte against
// it on synthetic data before landing this). No JPEG encode here: that
// happens exactly once, after cropping, in processAvatarShotInIsolate.
List<CapturedFrame> _convertYuvBatchIsolate(List<_YuvFrameData> frames) {
  return frames.map((p) {
    final dstW = p.height;
    final dstH = p.width;
    final wm1 = p.width - 1;
    final rgba = Uint8List(dstW * dstH * 4);
    for (int y = 0; y < p.height; y++) {
      for (int x = 0; x < p.width; x++) {
        final yValue = p.yPlane[y * p.yRowStride + x] & 0xFF;
        final uvIndex = (y ~/ 2) * p.uvRowStride + (x ~/ 2) * p.uvPixelStride;
        final u = (p.uPlane[uvIndex] & 0xFF) - 128;
        final v = (p.vPlane[uvIndex] & 0xFF) - 128;
        final r = (yValue + 1.402 * v).clamp(0, 255).toInt();
        final g = (yValue - 0.344136 * u - 0.714136 * v).clamp(0, 255).toInt();
        final b = (yValue + 1.772 * u).clamp(0, 255).toInt();
        final dstX = y;
        final dstY = wm1 - x;
        final idx = (dstY * dstW + dstX) * 4;
        rgba[idx] = r;
        rgba[idx + 1] = g;
        rgba[idx + 2] = b;
        rgba[idx + 3] = 255;
      }
    }
    return CapturedFrame(rgbaBytes: rgba, width: dstW, height: dstH);
  }).toList();
}