import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/data/use_cases/uploading_image_use_case.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';
import 'package:dataspikemobilesdk/domain/managers/isolate_image_processing.dart';
import 'package:flutter/foundation.dart';
import 'package:dataspikemobilesdk/view/ui/error/error_image_bottom_sheet.dart';
import 'package:dataspikemobilesdk/data/models/errors/common_errors.dart';
import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:flutter/services.dart';

class CameraAvatarViewModel extends ChangeNotifier {
  CameraController? ctrl;
  late Future<void> init;
  CameraDescription? frontCam;
  final UploadImageUseCase _setUseCase;

  VoidCallback? onProceed;
  VoidCallback? showLoader;
  VoidCallback? hideLoader;

  void Function(ErrorImageBottomSheetType type)? showCommonError;
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
    void Function(ErrorImageBottomSheetType type)? showCommonError,
    void Function(String title, String message, bool withInstruction)?
    showError,
  }) {
    this.onProceed = onProceed;
    this.showLoader = showLoader;
    this.hideLoader = hideLoader;
    this.showCommonError = showCommonError;
    this.showError = showError;
  }

  CameraAvatarViewModel({required UploadImageUseCase setUseCase})
    : _setUseCase = setUseCase {
    init = _setup();
  }

  Future<void> _setup() async {
    final cams = await availableCameras();
    for (final c in cams) {
      if (c.lensDirection == CameraLensDirection.front && frontCam == null) {
        frontCam = c;
      }
    }
    final initial = frontCam ?? cams.first;
    ctrl = CameraController(
      initial,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup
                .nv21 // for Android
          : ImageFormatGroup.bgra8888, // for iOS
    );
    await ctrl!.initialize();
    await ctrl!.lockCaptureOrientation(DeviceOrientation.portraitUp);

    try {
      await ctrl!.setFlashMode(FlashMode.off);
    } catch (e) {
      debugPrint('Flash off not supported: $e');
    }
  }
  
  // InputImage? _lastInputImage;

  // final FaceDetector _faceDetector = FaceDetector(
  //   options: FaceDetectorOptions(
  //     enableContours: true,
  //     enableLandmarks: true,
  //     enableClassification: true
  //   ),
  // );

  // Future<void> inputImage(InputImage inputImage) async {
  //   final faces = await _faceDetector.processImage(inputImage);

  //   for (Face face in faces) {
  //     debugPrint('faces: ${faces.length}');
  //     final Rect boundingBox = face.boundingBox;

      // final double? rotX =
      //     face.headEulerAngleX; // Head is tilted up and down rotX degrees
      //     debugPrint('rotX $rotX');
      // final double? rotY =
      //     face.headEulerAngleY;
      //      debugPrint('rotY $rotY'); // Head is rotated to the right rotY degrees
      // final double? rotZ =
      //     face.headEulerAngleZ;
      //      debugPrint('rotZ $rotZ'); // Head is tilted sideways rotZ degrees

      // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
      // eyes, cheeks, and nose available):
  //     final FaceLandmark? leftEar = face.landmarks[FaceLandmarkType.leftEar];
  //     if (leftEar != null) {
  //       final Point<int> leftEarPos = leftEar.position;
  //       debugPrint('leftEar: $leftEarPos');
  //     }

  //     // If classification was enabled with FaceDetectorOptions:
  //     if (face.smilingProbability != null) {
  //       final double? smileProb = face.smilingProbability;
  //       debugPrint('smileProb: $smileProb');
  //     }
  //   }
  // }

  @override
  void dispose() {
    ctrl?.dispose();
    ctrl = null;
    super.dispose();
  }

  // final _orientations = {
  //   DeviceOrientation.portraitUp: 0,
  //   DeviceOrientation.landscapeLeft: 90,
  //   DeviceOrientation.portraitDown: 180,
  //   DeviceOrientation.landscapeRight: 270,
  // };

  // InputImage? inputImageFromCameraImage(CameraImage image) {
  //   // get image rotation
  //   // it is used in android to convert the InputImage from Dart to Java
  //   // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
  //   // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
  //   final camera = ctrl!;
  //   final sensorOrientation = camera.description.sensorOrientation;
  //   InputImageRotation? rotation;
  //   if (Platform.isIOS) {
  //     rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
  //   } else if (Platform.isAndroid) {
  //     var rotationCompensation = _orientations[ctrl!.value.deviceOrientation];
  //     if (rotationCompensation == null) return null;
  //     rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
  //     rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
  //   }
  //   if (rotation == null) return null;

  //   final format = InputImageFormatValue.fromRawValue(image.format.raw);
  //   if (format == null ||
  //       (Platform.isAndroid && format != InputImageFormat.nv21) ||
  //       (Platform.isIOS && format != InputImageFormat.bgra8888))
  //     return null;

  //   // since format is constraint to nv21 or bgra8888, both only have one plane
  //   if (image.planes.length != 1) return null;
  //   final plane = image.planes.first;

  //   // compose InputImage using bytes
  //   return InputImage.fromBytes(
  //     bytes: plane.bytes,
  //     metadata: InputImageMetadata(
  //       size: Size(image.width.toDouble(), image.height.toDouble()),
  //       rotation: rotation, // used only in Android
  //       format: format, // used only in iOS
  //       bytesPerRow: plane.bytesPerRow, // used only in iOS
  //     ),
  //   );
  // }

  // CameraImage image; // your image from camera/controller image stream
  // final inputImage = _inputImageFromCameraImage(image);

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

      final result = await _setUseCase.uploadImage(
        documentType: 'liveness_photo',
        imageBytes: processed,
        ext: 'jpg',
        fileName: 'selfie.jpg',
      );

      hideLoader?.call();
      notifyListeners();

      if (result is UploadImageSuccess) {
        onProceed?.call();
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
}
