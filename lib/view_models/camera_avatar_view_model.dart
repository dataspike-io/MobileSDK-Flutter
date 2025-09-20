import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/data/use_cases/uploading_image_use_case.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';

class CameraAvatarViewModel extends ChangeNotifier {
  Duration? timerDuration;

  CameraController? ctrl;
  late Future<void> init;
  CameraDescription? frontCam;
  final UploadImageUseCase _setUseCase;

  VoidCallback? onProceed;
  VoidCallback? showLoader;
  VoidCallback? hideLoader;
  void Function(String title, String message)? showError;

  static const double sideInsetPct = 0.10;
  static const double topApexPct = 0.10;
  static const double bottomApexFromBottomPct = 0.20;
  static const double topRisePx = 120;
  static const double bottomRisePx = 120;
  static const double ctrlXpx = 80;
  static const double strokeWidth = 3;

  void attachCallbacks({
    VoidCallback? onProceed,
    VoidCallback? showLoader,
    VoidCallback? hideLoader,
    void Function(String title, String message)? showError,
  }) {
    this.onProceed = onProceed;
    this.showLoader = showLoader;
    this.hideLoader = hideLoader;
    this.showError = showError;
  }

  CameraAvatarViewModel({required UploadImageUseCase setUseCase})
    : _setUseCase = setUseCase {
    init = _setup();
    setVerificationTimer();
  }

  Future<void> _setup() async {
    final cams = await availableCameras();
    for (final c in cams) {
      if (c.lensDirection == CameraLensDirection.front && frontCam == null) {
        frontCam = c;
      }
    }
    final initial = frontCam ?? cams.first;
    ctrl = CameraController(initial, ResolutionPreset.max, enableAudio: false);
    await ctrl!.initialize();
    await ctrl!.lockCaptureOrientation(DeviceOrientation.portraitUp);

    try {
      await ctrl!.setFlashMode(FlashMode.off);
    } catch (e) {
      debugPrint('Flash off not supported: $e');
    }
  }

  void setVerificationTimer() {
    final verificationManager = DataspikeInjector.component.verificationManager;
    final millisecondsUntilVerificationExpired =
        verificationManager.millisecondsUntilVerificationExpired;
    timerDuration = Duration(
      milliseconds: millisecondsUntilVerificationExpired,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    ctrl?.dispose();
    super.dispose();
  }

  Rect _computeCropRect(Size size) {
    final w = size.width;
    final h = size.height;
    
    final margin = strokeWidth / 2 + 0.5;

    final leftX = (w * sideInsetPct).clamp(margin, w - margin);
    final rightX = (w * (1 - sideInsetPct)).clamp(margin, w - margin);

    final topApexY = (h * topApexPct) + margin;
    final bottomApexY = (h * (1 - bottomApexFromBottomPct)) - margin;

    return Rect.fromLTRB(leftX, topApexY, rightX, bottomApexY);
  }

  Future<void> shootAndCrop(GlobalKey previewKey, Size screenSize) async {
    if (!(ctrl?.value.isInitialized ?? false)) return;

    showLoader?.call();
    notifyListeners();
    await Permission.photos.request();

    final file = await ctrl!.takePicture();
    final bytes = await file.readAsBytes();
    img.Image? original = img.decodeImage(bytes);
    if (original == null) {
      hideLoader?.call();
      notifyListeners();
      return;
    }
    original = img.bakeOrientation(original);

    final imgW = original.width.toDouble();
    final imgH = original.height.toDouble();

    final rb = previewKey.currentContext!.findRenderObject() as RenderBox;
    final containerW = rb.size.width;
    final containerH = rb.size.height;

    final ps = ctrl!.value.previewSize!;
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

    final result = await _setUseCase.call(
      documentType: 'liveness_photo',
      imageBytes: out,
      fileName: 'selfie.jpg',
    );

    hideLoader?.call();
    notifyListeners();

    if (result is UploadImageError) {
      showError?.call(result.title, result.message);
    } else {
      onProceed?.call();
    }
  }
}
