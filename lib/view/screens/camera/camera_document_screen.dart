import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/view_models/camera_document_view_model.dart';
import 'package:dataspikemobilesdk/view/ui/camera/grey_corner_painter.dart';
import 'package:dataspikemobilesdk/view/ui/camera/dim_overlay_painter.dart';

class LiveCropCamera extends StatefulWidget {
  final ValueChanged<Uint8List> onCropped;

  const LiveCropCamera({super.key, required this.onCropped});

  @override
  State<LiveCropCamera> createState() => _LiveCropCameraState();
}

class _LiveCropCameraState extends State<LiveCropCamera> {
  CameraController? _ctrl;
  late Future<void> _init;
  CameraDescription? _backCam;
  CameraDescription? _frontCam;
  bool _useFront = false;

  late final CameraDocumentViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = DataspikeViewModelFactory().create<CameraDocumentViewModel>();
    _init = _setup();
    viewModel.setVerificationTimer();
  }

  Future<void> _setup() async {
    final cams = await availableCameras();
    for (final c in cams) {
      if (c.lensDirection == CameraLensDirection.back && _backCam == null) {
        _backCam = c;
      }
      if (c.lensDirection == CameraLensDirection.front && _frontCam == null) {
        _frontCam = c;
      }
    }
    final initial = _backCam ?? _frontCam ?? cams.first;
    _ctrl = CameraController(initial, ResolutionPreset.max, enableAudio: false);
    await _ctrl!.initialize();
    await _ctrl!.lockCaptureOrientation(DeviceOrientation.portraitUp);
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

    final screenSize = MediaQuery.of(context).size;
    final cropW = screenSize.width * 0.85;
    final cropH = screenSize.height * 0.3;
    final cropLeftInWidget = (containerW - cropW) / 2.0;
    final cropTopInWidget = (containerH - cropH) / 2.0;

    final scale = displayW / imgW;

    int x = (((cropLeftInWidget - offsetX) / scale).round()).clamp(
      0,
      imgW.toInt() - 1,
    );
    int y = (((cropTopInWidget - offsetY) / scale).round()).clamp(
      0,
      imgH.toInt() - 1,
    );
    int w = ((cropW / scale).round()).clamp(1, imgW.toInt() - x);
    int h = ((cropH / scale).round()).clamp(1, imgH.toInt() - y);

    final cropped = img.copyCrop(original, x: x, y: y, width: w, height: h);
    final out = img.encodeJpg(cropped, quality: 100);

    await ImageGallerySaverPlus.saveImage(Uint8List.fromList(out));
    widget.onCropped(Uint8List.fromList(out));
  }

  Future<void> _pickAndUploadDocument() async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final Uint8List raw = await picked.readAsBytes();

      widget.onCropped(raw);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
    }
  }

  Future<void> _toggleCamera() async {
    if (_frontCam == null && _backCam == null) return;
    final newDesc = _useFront
        ? (_backCam ?? _ctrl!.description)
        : (_frontCam ?? _ctrl!.description);
    if (newDesc == _ctrl!.description) return; // nothing to change
    _useFront = !_useFront;
    await _ctrl?.dispose();
    _ctrl = CameraController(newDesc, ResolutionPreset.max, enableAudio: false);
    try {
      await _ctrl!.initialize();
      await _ctrl!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      await _ctrl!.setFlashMode(FlashMode.off);
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Camera switch error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewKey = GlobalKey();
    final screenSize = MediaQuery.of(context).size;

    final cropWidth = screenSize.width * 0.85;
    final cropHeight = screenSize.height * 0.3;

    final camWidth = screenSize.width;
    final camHeight = screenSize.height * 0.65;

    final timer = viewModel.timerDuration;

    return FutureBuilder(
      future: _init,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: AppColors.white,
          body: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                TopBar(timer: timer),
                const SizedBox(height: 10),
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

                              Positioned.fill(
                                child: CustomPaint(
                                  painter: DimOverlayPainter(
                                    holeRect: Rect.fromCenter(
                                      center: Offset(
                                        c.maxWidth / 2,
                                        c.maxHeight / 2,
                                      ),
                                      width: cropWidth,
                                      height: cropHeight,
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: CustomPaint(
                                  size: Size(cropWidth, cropHeight),
                                  painter: GreyCornersPainter(
                                    rect: Rect.fromLTWH(
                                      0,
                                      0,
                                      cropWidth,
                                      cropHeight,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 16,
                                child: (_frontCam != null || _backCam != null)
                                    ? Builder(
                                        builder: (context) {
                                          final canSwitch =
                                              _frontCam != null &&
                                              _backCam != null;
                                          return Opacity(
                                            opacity: canSwitch ? 1 : 0.4,
                                            child: Material(
                                              color: AppColors.black,
                                              shape: const CircleBorder(),
                                              child: IconButton(
                                                icon: const Icon(
                                                  Icons.cameraswitch,
                                                  color: AppColors.white,
                                                ),
                                                onPressed: canSwitch
                                                    ? _toggleCamera
                                                    : null,
                                                tooltip: _useFront
                                                    ? 'Switch to back camera'
                                                    : 'Switch to front camera',
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              Positioned(
                                top: 100,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    'Please make a photo of front-side of ID',
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 14,
                                      decoration: TextDecoration.none,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
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
                SizedBox(
                  height: 60.0,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: TextButton(
                      onPressed: _pickAndUploadDocument,
                      child: Text(
                        'Upload document',
                        style: TextStyle(
                          color: AppColors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Figtree',
                          package: 'dataspikemobilesdk',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
