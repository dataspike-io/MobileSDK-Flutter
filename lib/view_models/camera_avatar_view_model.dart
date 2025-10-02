import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/data/use_cases/uploading_image_use_case.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';
import 'package:dataspikemobilesdk/domain/managers/isolate_image_processing.dart';
import 'package:flutter/foundation.dart';

class CameraAvatarViewModel extends ChangeNotifier {
  Duration? timerDuration;

  CameraController? ctrl;
  late Future<void> init;
  CameraDescription? frontCam;
  final UploadImageUseCase _setUseCase;

  VoidCallback? onProceed;
  VoidCallback? showLoader;
  VoidCallback? hideLoader;
  void Function(String title, String message, bool withInstruction)? showError;

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
    void Function(String title, String message, bool withInstruction)? showError,
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

  Future<void> shootAndCrop(GlobalKey previewKey, Size screenSize) async {
    if (!(ctrl?.value.isInitialized ?? false)) return;

    showLoader?.call();
    notifyListeners();
    await Permission.photos.request();

    try {
      final file = await ctrl!.takePicture();
      final bytes = await file.readAsBytes();

      final rb = previewKey.currentContext!.findRenderObject() as RenderBox;
      final containerW = rb.size.width;
      final containerH = rb.size.height;

      final ps = ctrl!.value.previewSize!;
      final previewW = ps.width;
      final previewH = ps.height;

      final processed = await compute<AvatarCropParams, Uint8List>(
        processAvatarShotInIsolate,
        AvatarCropParams(
          imageBytes: bytes,
          containerW: containerW,
          containerH: containerH,
          previewW: previewW,
          previewH: previewH,
          sideInsetPct: sideInsetPct,
          topApexPct: topApexPct,
          bottomApexFromBottomPct: bottomApexFromBottomPct,
          strokeWidth: strokeWidth,
        ),
      );

      final result = await _setUseCase.call(
        documentType: 'liveness_photo',
        imageBytes: processed,
        fileName: 'selfie.jpg',
      );

      hideLoader?.call();
      notifyListeners();

      if (result is UploadImageSuccess) {
        onProceed?.call();
      } else if (result is UploadImageError) {
        showError?.call(result.title, result.message, result.withInstruction);
      }
    } catch (e) {
      hideLoader?.call();
      notifyListeners();
      showError?.call('Processing error', 'Failed to process the image.', false);
    }
  }
}
