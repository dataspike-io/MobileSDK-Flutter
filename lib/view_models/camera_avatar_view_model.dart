import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/data/use_cases/uploading_image_use_case.dart';
import 'package:flutter/services.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';
import 'package:dataspikemobilesdk/domain/managers/isolate_image_processing.dart';
import 'package:flutter/foundation.dart';
import 'package:dataspikemobilesdk/view/ui/error/error_image_bottom_sheet.dart';
import 'package:dataspikemobilesdk/data/models/errors/common_errors.dart';
import 'package:dataspikemobilesdk/utils/camera/camera_variable_environments.dart';

class CameraAvatarViewModel extends ChangeNotifier {
  late Future<void> init;
  final UploadImageUseCase _setUseCase;

  VoidCallback? onProceed;
  VoidCallback? showLoader;
  VoidCallback? hideLoader;

  void Function(ErrorImageBottomSheetType type)? showCommonError;
  void Function(String title, String message, bool withInstruction)? showError;
  
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

  Future<void> _setup() async { }


  Future<void> shootAndCrop(
    Uint8List imageBytes,
    Size previewKeySize, 
    Size screenSize,
    Size previewSize,
  ) async {
    showLoader?.call();
    notifyListeners();

    try {
      final containerW = previewKeySize.width;
      final containerH = previewKeySize.height;

      final ps = previewSize;
      final previewW = ps.width;
      final previewH = ps.height;

      final processed = await compute<AvatarCropParams, Uint8List>(
        processAvatarShotInIsolate,
        AvatarCropParams(
          imageBytes: imageBytes,
          containerW: containerW,
          containerH: containerH,
          previewW: previewW,
          previewH: previewH,
          sideInsetPct: CameraConstants.avatarSideInsetPct,
          topApexPct: CameraConstants.avatarTopApexPct,
          bottomApexFromBottomPct: CameraConstants.avatarBottomApexFromBottomPct,
          strokeWidth: CameraConstants.avatarStrokeWidth,
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
