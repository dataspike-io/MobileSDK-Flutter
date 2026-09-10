import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/data/use_cases/uploading_image_use_case.dart';
import 'package:dataspikemobilesdk/face_detector/models/captured_frame.dart';
import 'package:dataspikemobilesdk/domain/managers/isolate_image_processing.dart';
import 'package:flutter/foundation.dart';
import 'package:dataspikemobilesdk/view/ui/error/error_image_bottom_sheet.dart';
import 'package:dataspikemobilesdk/data/models/errors/common_errors.dart';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';
import 'package:dataspikemobilesdk/data/models/request/image_selfie_v2_request_body.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state_v2.dart';
import 'package:dataspikemobilesdk/domain/models/avatar_detection_status.dart';

class CameraAvatarViewModel extends ChangeNotifier {
  late Future<void> init;
  final UploadImageUseCase _setUseCase;

  VoidCallback? onProceed;
  VoidCallback? showLoader;
  VoidCallback? hideLoader;

  void Function(ErrorImageBottomSheetType type)? showCommonError;
  void Function(String title, String message, bool withInstruction)? showError;
  void Function(AvatarDetectionStatus? status)? showErrorV2;

  void attachCallbacks({
    VoidCallback? onProceed,
    VoidCallback? showLoader,
    VoidCallback? hideLoader,
    void Function(ErrorImageBottomSheetType type)? showCommonError,
    void Function(String title, String message, bool withInstruction)?
    showError,
    showErrorV2,
  }) {
    this.onProceed = onProceed;
    this.showLoader = showLoader;
    this.hideLoader = hideLoader;
    this.showCommonError = showCommonError;
    this.showError = showError;
    this.showErrorV2 = showErrorV2;
  }

  CameraAvatarViewModel({required UploadImageUseCase setUseCase})
    : _setUseCase = setUseCase {
    init = _setup();
  }

  Future<void> _setup() async {}

  Future<void> shootAndCropV2(
    List<CapturedFrame> frames,
    Size previewKeySize,
    Size screenSize,
    Size previewSize,
  ) async {
    try {
      final containerW = previewKeySize.width;
      final containerH = previewKeySize.height;
      final previewW = previewSize.width;
      final previewH = previewSize.height;

      final paramsList = frames
          .map(
            (frame) => AvatarCropParams(
              rgbaBytes: frame.rgbaBytes,
              imageWidth: frame.width,
              imageHeight: frame.height,
              containerW: containerW,
              containerH: containerH,
              previewW: previewW,
              previewH: previewH,
              sideInsetPct: CameraConstants.avatarSideInsetPct,
              topApexPct: CameraConstants.avatarTopApexPct,
              bottomApexFromBottomPct:
                  CameraConstants.avatarBottomApexFromBottomPct,
              strokeWidth: CameraConstants.avatarStrokeWidth,
            ),
          )
          .toList();

      final processedList =
          await compute<List<AvatarCropParams>, List<Uint8List>>(
            processAvatarShotBatchInIsolate,
            paramsList,
          );

      final batchFrames = <LivenessBatchFrame>[
        for (int i = 0; i < processedList.length; i++)
          LivenessBatchFrame(
            frameId: 'frame_$i',
            fileBytes: processedList[i],
            ext: 'jpg',
            fileName: 'selfie_$i.jpg',
          ),
      ];

      final result = await _setUseCase.uploadImageV2(frames: batchFrames);

      if (result is UploadImageSuccessV2) {
        onProceed?.call();
      } else if (result is UploadImageErrorV2) {
        switch (result.code) {
          // showErrorV2?.call(AvatarDetectionStatus.halfAttempts); //
          case 5013:
          case 5023:
            showErrorV2?.call(AvatarDetectionStatus.headwearIsOn);
          case 5017:
            showErrorV2?.call(AvatarDetectionStatus.excessiveBrightness);
          case 5020:
            showErrorV2?.call(AvatarDetectionStatus.faceCovered);
          case 5021:
            showErrorV2?.call(AvatarDetectionStatus.faceMaskOn);
          case 5022: 
            showErrorV2?.call(AvatarDetectionStatus.handNearFace);
          case 5024: 
            showErrorV2?.call(AvatarDetectionStatus.sunglassesOn);
          case 5012:
            showErrorV2?.call(AvatarDetectionStatus.chinOutOfFrame);
          case 5011: 
            showErrorV2?.call(AvatarDetectionStatus.foreheadOutOfFrame);
          case 5010:
            showErrorV2?.call(AvatarDetectionStatus.lowCameraResolution);
          case 5009:
            showErrorV2?.call(AvatarDetectionStatus.blurryPhoto);
          case 5008:
            showErrorV2?.call(AvatarDetectionStatus.eyesNotDetected);
          case 5006: 
          case 5003: 
            showErrorV2?.call(AvatarDetectionStatus.faceTooFarFromCamera);
          case 5004:
            showErrorV2?.call(AvatarDetectionStatus.excessiveDarkness);
          case 5007: // MY 3d depth phase? BACK: More faces
          case 5005: // Disputed
          case 5002: // Spoofing
          case 5001: // Deepfake
          case 4001: // No face
          default: showErrorV2?.call(null);
        }
      } else {
        showErrorV2?.call(null);
      }
    } on NoInternetException {
      notifyListeners();
      showCommonError?.call(ErrorImageBottomSheetType.noInternet);
    } catch (e) {
      notifyListeners();
      showError?.call(
        'Processing error',
        'Failed to process the image.',
        false,
      );
    }
  }
}
