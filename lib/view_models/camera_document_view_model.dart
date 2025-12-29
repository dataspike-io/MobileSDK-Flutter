import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/data/use_cases/uploading_image_use_case.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';
import 'package:dataspikemobilesdk/domain/models/document_type.dart';
import 'package:dataspikemobilesdk/domain/managers/isolate_image_processing.dart';
import 'package:dataspikemobilesdk/data/models/request/image_document_request_body.dart';
import 'dart:io' show File;
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:dataspikemobilesdk/view/ui/error/error_image_bottom_sheet.dart';
import 'package:dataspikemobilesdk/data/models/errors/common_errors.dart';
import 'package:dataspikemobilesdk/domain/models/document_side.dart';

class CameraDocumentViewModel extends ChangeNotifier {
  DocumentSide side = DocumentSide.front;

  final UploadImageUseCase _setUseCase;
  final DocumentType documentType;

  CameraController? ctrl;
  late Future<void> init;
  CameraDescription? backCam;
  CameraDescription? frontCam;
  bool _useFront = false;
  final bool _allowPoiManualUploads;

  bool _isFirstSideUploaded = false;

  VoidCallback? onProceed;
  VoidCallback? showLoader;
  VoidCallback? hideLoader;
  VoidCallback? showChooserSheet;
  void Function(ErrorImageBottomSheetType type)? showCommonError;
  void Function(String title, String message, bool withInstruction)? showError;

  void attachCallbacks({
    VoidCallback? onProceed,
    VoidCallback? showLoader,
    VoidCallback? hideLoader,
    VoidCallback? showChooserSheet,
    void Function(ErrorImageBottomSheetType type)? showCommonError,
    void Function(String title, String message, bool withInstruction)?
    showError,
  }) {
    this.onProceed = onProceed;
    this.showLoader = showLoader;
    this.hideLoader = hideLoader;
    this.showChooserSheet = showChooserSheet;
    this.showCommonError = showCommonError;
    this.showError = showError;
  }

  CameraDocumentViewModel({
    required UploadImageUseCase setUseCase,
    required bool allowPoiManualUploads,
    required DocumentType docType,
  }) : _setUseCase = setUseCase,
       _allowPoiManualUploads = allowPoiManualUploads,
       documentType = docType {
    init = _setup();
  }

  @override
  void dispose() {
    ctrl?.dispose();
    ctrl = null;
    super.dispose();
  }

  bool get isUploadButtonVisible {
    switch (documentType) {
      case DocumentType.identity:
        return _allowPoiManualUploads;
      case DocumentType.address:
        return true;
    }
  }

  String get hint {
    switch (side) {
      case DocumentSide.front:
        return 'Take photo of front side';
      case DocumentSide.back:
        return 'Take photo of back side';
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
    await ctrl!.setFlashMode(FlashMode.off);
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
          isVertical: documentType == DocumentType.address,
        ),
      );

      final result = await _setUseCase.uploadImage(
        documentType: documentType.value,
        imageBytes: processed,
        ext: 'jpg',
        fileName: 'document.jpg',
      );

      hideLoader?.call();
      notifyListeners();

      if (result is UploadImageSuccess) {
        if (result.detectedTwoSideDocument && !_isFirstSideUploaded) {
          side = result.isFront ? DocumentSide.back : DocumentSide.front;
          _isFirstSideUploaded = true;
          notifyListeners();
        } else {
          onProceed?.call();
        }
      } else if (result is UploadImageError) {
        showError?.call(result.title, result.message, result.withInstruction);
      }
    } on NoInternetException {
      hideLoader?.call();
      notifyListeners();
      showCommonError?.call(ErrorImageBottomSheetType.noInternet);
    } catch (e) {
      hideLoader?.call();
      notifyListeners();
      showError?.call(
        'Processing error',
        'Failed to process the image.',
        false,
      );
    }
  }

  Future<void> pickButtonTap() async {
    switch (documentType) {
      case DocumentType.identity:
        await pickAndUploadImage();
        break;
      case DocumentType.address:
        showChooserSheet?.call();
        break;
    }
  }

  Future<void> pickAndUploadImage() async {
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

    final Uint8List processed = await compute<GalleryProcessParams, Uint8List>(
      processGalleryImageInIsolate,
      GalleryProcessParams(imageBytes: raw),
    );

    try {
      final result = await _setUseCase.uploadImage(
        documentType: documentType.value,
        imageBytes: processed,
        ext: 'jpg',
        fileName: 'document.jpg',
      );

      hideLoader?.call();
      notifyListeners();

      if (result is UploadImageSuccess) {
        if (result.detectedTwoSideDocument && !_isFirstSideUploaded) {
          side = result.isFront ? DocumentSide.back : DocumentSide.front;
          _isFirstSideUploaded = true;
          notifyListeners();
        } else {
          onProceed?.call();
        }
      } else if (result is UploadImageError) {
        showError?.call(result.title, result.message, result.withInstruction);
      }
    } on NoInternetException {
      hideLoader?.call();
      notifyListeners();
      showCommonError?.call(ErrorImageBottomSheetType.noInternet);
    } catch (e) {
      hideLoader?.call();
      notifyListeners();
      showError?.call(
        'Processing error',
        'Failed to process the image.',
        false,
      );
    }
  }

  Future<void> pickAndUploadDocument() async {
    showLoader?.call();
    notifyListeners();

    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: documentType == DocumentType.address
          ? ['jpg', 'jpeg', 'png', 'heic', 'pdf']
          : ['jpg', 'jpeg', 'png', 'heic'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      hideLoader?.call();
      notifyListeners();
      return;
    }

    final PlatformFile f = result.files.first;
    final String ext = (f.extension ?? '').toLowerCase();

    final Uint8List bytes = f.bytes ?? await File(f.path!).readAsBytes();

    const imgExts = {'jpg', 'jpeg', 'png', 'heic'};
    final bool isImage = imgExts.contains(ext);

    Uint8List uploadBytes = bytes;

    if (isImage) {
      uploadBytes = await compute<GalleryProcessParams, Uint8List>(
        processGalleryImageInIsolate,
        GalleryProcessParams(imageBytes: bytes),
      );
    }

    try {
      final result = isImage
          ? await _setUseCase.uploadImage(
              documentType: documentType.value,
              imageBytes: uploadBytes,
              ext: 'jpg',
              fileName: 'document.jpg',
            )
          : await _setUseCase.uploadDocument(
              body: ImageDocumentRequestBody(
                encodedFileContent: base64Encode(uploadBytes),
                documentType: documentType.value,
              ),
            );

      hideLoader?.call();
      notifyListeners();

      if (result is UploadImageSuccess) {
        if (result.detectedTwoSideDocument && !_isFirstSideUploaded) {
          side = result.isFront ? DocumentSide.back : DocumentSide.front;
          _isFirstSideUploaded = true;
          notifyListeners();
        } else {
          onProceed?.call();
        }
      } else if (result is UploadImageError) {
        showError?.call(
          result.title,
          result.message,
          result.withInstruction,
        );
      }
    } on NoInternetException {
      hideLoader?.call();
      notifyListeners();
      showCommonError?.call(ErrorImageBottomSheetType.noInternet);
    } catch (e) {
      hideLoader?.call();
      notifyListeners();
      showError?.call(
        'Processing error',
        'Failed to process the document.',
        false,
      );
    }
  }
}
