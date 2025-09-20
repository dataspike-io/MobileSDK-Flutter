import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/data/use_cases/uploading_image_use_case.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';
import 'package:dataspikemobilesdk/view/ui/camera/side_toggle_pill.dart';
import 'package:dataspikemobilesdk/domain/models/document_type.dart';
import 'package:dataspikemobilesdk/domain/managers/isolate_image_processing.dart';

class CameraDocumentViewModel extends ChangeNotifier {
  Duration? timerDuration;

  DocumentSide side = DocumentSide.front;

  final UploadImageUseCase _setUseCase;
  final DocumentType documentType;

  CameraController? ctrl;
  late Future<void> init;
  CameraDescription? backCam;
  CameraDescription? frontCam;
  bool _useFront = false;

  VoidCallback? onProceed;
  VoidCallback? showLoader;
  VoidCallback? hideLoader;
  void Function(String title, String message)? showError;

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

  CameraDocumentViewModel({
    required UploadImageUseCase setUseCase,
    required DocumentType docType,
  }) : _setUseCase = setUseCase,
       documentType = docType {
    init = _setup();
    setVerificationTimer();
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

  String get hint {
    switch (documentType) {
      case DocumentType.identity:
        return side == DocumentSide.front
          ? 'Please make a photo of front side of ID'
          : ''; //'Please make a photo of back side of ID',
      case DocumentType.address:
        return 'Please make a photo of residence proof';
    }
  }

  Future<void> _setup() async {
    final cams = await availableCameras();
    for (final c in cams) {
      if (c.lensDirection == CameraLensDirection.back && backCam == null) {
        backCam = c;
      }
      if (c.lensDirection == CameraLensDirection.front && frontCam == null) {
        frontCam = c;
      }
    }
    final initial = backCam ?? frontCam ?? cams.first;
    ctrl = CameraController(initial, ResolutionPreset.max, enableAudio: false);
    await ctrl!.initialize();
    await ctrl!.lockCaptureOrientation(DeviceOrientation.portraitUp);
    notifyListeners();
  }

  Future<void> toggleCamera() async {
    if (frontCam == null && backCam == null) return;
    if (ctrl == null || !(ctrl!.value.isInitialized)) return;
    final newDesc = _useFront
        ? (backCam ?? ctrl!.description)
        : (frontCam ?? ctrl!.description);
    if (newDesc == ctrl!.description) return;
    _useFront = !_useFront;
    await ctrl?.dispose();
    ctrl = CameraController(newDesc, ResolutionPreset.max, enableAudio: false);
    try {
      await ctrl!.initialize();
      await ctrl!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      await ctrl!.setFlashMode(FlashMode.off);
      notifyListeners();
    } catch (e) {
      debugPrint('Camera switch error: $e');
    }
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

      final processed = await compute<CameraCropParams, Uint8List>(
        processCameraShotInIsolate,
        CameraCropParams(
          imageBytes: bytes,
          containerW: containerW,
          containerH: containerH,
          previewW: previewW,
          previewH: previewH,
          screenW: screenSize.width,
          screenH: screenSize.height,
        ),
      );

      final result = await _setUseCase.call(
        documentType: documentType.value,
        imageBytes: processed,
        fileName: 'document.jpg',
      );

      hideLoader?.call();
      notifyListeners();

      if (result is UploadImageSuccess) {
        if (result.detectedTwoSideDocument && side == DocumentSide.front) {
          side = DocumentSide.back;
          notifyListeners();
        } else {
          onProceed?.call();
        }
      } else if (result is UploadImageError) {
        showError?.call(result.title, result.message);
      }
    } catch (e) {
      hideLoader?.call();
      notifyListeners();
      showError?.call('Processing error', 'Failed to process the image.');
    }
  }

  Future<void> pickAndUploadDocument() async {
    final picker = ImagePicker();
    showLoader?.call();
    notifyListeners();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      hideLoader?.call();
      notifyListeners();
      return;
    }
    final Uint8List raw = await picked.readAsBytes();

    final result = await _setUseCase.call(
      documentType: documentType.value,
      imageBytes: raw,
      fileName: 'document.jpg',
    );

    hideLoader?.call();
    notifyListeners();

    if (result is UploadImageSuccess) {
      if (result.detectedTwoSideDocument && side == DocumentSide.front) {
        side = DocumentSide.back;
        notifyListeners();
      } else {
        onProceed?.call();
      }
    } else if (result is UploadImageError) {
      showError?.call(result.title, result.message);
    }
  }
}