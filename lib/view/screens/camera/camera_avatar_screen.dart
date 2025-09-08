import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:dataspikemobilesdk/view/ui/camera/two_arcs_painter.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/loader.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/view_models/camera_avatar_view_model.dart';

class LiveAvatarCamera extends StatefulWidget {
  final ValueChanged<Uint8List> onCropped;

  const LiveAvatarCamera({super.key, required this.onCropped});

  @override
  State<LiveAvatarCamera> createState() => _LiveAvatarCameraState();
}

class _LiveAvatarCameraState extends State<LiveAvatarCamera> {
  CameraController? _ctrl;
  late Future<void> _init;
  CameraDescription? _frontCam;

  static const double _sideInsetPct = 0.10;
  static const double _topApexPct = 0.10;
  static const double _bottomApexFromBottomPct = 0.20;
  static const double _topRisePx = 120;
  static const double _bottomRisePx = 120;
  static const double _ctrlXpx = 80;
  static const double _strokeWidth = 3;

  late final CameraAvatarViewModel viewModel;

  Rect _computeCropRect(Size size) {
    final w = size.width;
    final h = size.height;
    final margin = _strokeWidth / 2 + 0.5;

    final leftX = (w * _sideInsetPct).clamp(margin, w - margin);
    final rightX = (w * (1 - _sideInsetPct)).clamp(margin, w - margin);

    final topApexY = (h * _topApexPct) + margin;
    final bottomApexY = (h * (1 - _bottomApexFromBottomPct)) - margin;

    return Rect.fromLTRB(leftX, topApexY, rightX, bottomApexY);
  }

  @override
  void initState() {
    super.initState();
    viewModel = DataspikeViewModelFactory().create<CameraAvatarViewModel>();
    _init = _setup();
    viewModel.setVerificationTimer();
  }

  Future<void> _setup() async {
    final cams = await availableCameras();
    for (final c in cams) {
      if (c.lensDirection == CameraLensDirection.front && _frontCam == null) {
        _frontCam = c;
      }
    }
    final initial = _frontCam ?? cams.first;
    _ctrl = CameraController(initial, ResolutionPreset.max, enableAudio: false);
    await _ctrl!.initialize();
    await _ctrl!.lockCaptureOrientation(DeviceOrientation.portraitUp);

    try {
      await _ctrl!.setFlashMode(FlashMode.off);
    } catch (e) {
      debugPrint('Flash off not supported: $e');
    }
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  Future<void> _shootAndCrop(GlobalKey previewKey) async {
    if (!(_ctrl?.value.isInitialized ?? false)) return;
    await Permission.photos.request();

    final file = await _ctrl!.takePicture();
    final bytes = await file.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) return;
    original = img.bakeOrientation(original);

    final imgW = original.width.toDouble();
    final imgH = original.height.toDouble();

    final rb = previewKey.currentContext!.findRenderObject() as RenderBox;
    final containerW = rb.size.width;
    final containerH = rb.size.height;

    final ps = _ctrl!.value.previewSize!;
    final previewAR = ps.height / ps.width;
    final containerAR = containerW / containerH;
    final coverScale = previewAR / containerAR;

    double childW, childH;
    if (containerAR > previewAR) {
      childH = containerH;
      childW = childH * previewAR;
    } else {
      childW = containerW;
      childH = childW / previewAR;
    }
    final displayW = childW * coverScale;
    final displayH = childH * coverScale;
    final offsetX = (containerW - displayW) / 2.0;
    final offsetY = (containerH - displayH) / 2.0;

    final cropRectInWidget = _computeCropRect(Size(containerW, containerH));

    final scale = displayW / imgW;

    int x = (((cropRectInWidget.left - offsetX) / scale).round()).clamp(
      0,
      imgW.toInt() - 1,
    );
    int y = (((cropRectInWidget.top - offsetY) / scale).round()).clamp(
      0,
      imgH.toInt() - 1,
    );
    int w = ((cropRectInWidget.width / scale).round()).clamp(
      1,
      imgW.toInt() - x,
    );
    int h = ((cropRectInWidget.height / scale).round()).clamp(
      1,
      imgH.toInt() - y,
    );

    final cropped = img.copyCrop(original, x: x, y: y, width: w, height: h);
    final out = img.encodeJpg(cropped, quality: 100);
    await ImageGallerySaverPlus.saveImage(Uint8List.fromList(out));
    widget.onCropped(Uint8List.fromList(out));
  }

  @override
  Widget build(BuildContext context) {
    final previewKey = GlobalKey();
    final screenSize = MediaQuery.of(context).size;

    final camWidth = screenSize.width;
    final camHeight = screenSize.height * 0.65;

    final timer = viewModel.timerDuration;

    return FutureBuilder(
      future: _init,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: const Center(child: Loader()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                TopBar(timer: timer),
                Center(
                  child: SizedBox(
                    key: previewKey,
                    width: camWidth,
                    height: camHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: LayoutBuilder(
                        builder: (context, c) {
                          final ps = _ctrl!.value.previewSize!;
                          final previewAR = ps.height / ps.width;
                          final containerAR = c.maxWidth / c.maxHeight;
                          final coverScale = previewAR / containerAR;

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Transform.scale(
                                scale: coverScale,
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: previewAR,
                                    child: CameraPreview(_ctrl!),
                                  ),
                                ),
                              ),

                              CustomPaint(
                                size: Size(c.maxWidth, c.maxHeight),
                                painter: TwoArcsPainter(
                                  color: Colors.white,
                                  strokeWidth: _strokeWidth,
                                  sideInsetPct: _sideInsetPct,
                                  topApexPct: _topApexPct,
                                  bottomApexFromBottomPct:
                                      _bottomApexFromBottomPct,
                                  topRisePx: _topRisePx,
                                  bottomRisePx: _bottomRisePx,
                                  ctrlXpx: _ctrlXpx,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ContinueButton(
                      text: 'Take a photo',
                      onPressed: () => _shootAndCrop(previewKey),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
