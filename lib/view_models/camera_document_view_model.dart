import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/data/use_cases/uploading_image_use_case.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';
import 'package:dataspikemobilesdk/view/ui/camera/side_toggle_pill.dart';

class CameraDocumentViewModel extends ChangeNotifier {
  Duration? timerDuration;

  DocumentSide side = DocumentSide.front;

  final UploadImageUseCase _setUseCase;

  CameraController? ctrl;
  late Future<void> init;
  CameraDescription? backCam;
  CameraDescription? frontCam;
  bool _useFront = false;

  CameraDocumentViewModel({required UploadImageUseCase setUseCase})
    : _setUseCase = setUseCase {
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

    await Permission.photos.request();

    final file = await ctrl!.takePicture();
    final bytes = await file.readAsBytes();

    img.Image? original = img.decodeImage(bytes);
    if (original == null) return;

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
    final out = img.encodeJpg(cropped);

    final result = await _setUseCase.call(
      documentType: 'poi',
      imageBytes: out,
      fileName: 'document.jpg'
    );

    if (result is! UploadImageSuccess) {
      throw Exception();
    } 
  }

  Future<void> pickAndUploadDocument() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final Uint8List raw = await picked.readAsBytes();

    await _setUseCase.call(
      documentType: 'poi',
      imageBytes: raw,
      fileName: 'document.jpg'
    );
  }
}
