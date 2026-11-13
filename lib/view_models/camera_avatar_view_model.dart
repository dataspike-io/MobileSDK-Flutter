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
import 'package:dataspikemobilesdk/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/face_detector/captured_frames_scorer.dart';

class CameraAvatarViewModel extends ChangeNotifier {
  late Future<void> init;
  final UploadImageUseCase _setUseCase;

  VoidCallback? onProceed;
  VoidCallback? showLoader;
  VoidCallback? hideLoader;

  void Function(ErrorImageBottomSheetType type)? showCommonError;
  void Function(String title, String message, bool withInstruction)? showError;
  void Function(AvatarDetectionStatus? status)? showErrorV2;

  /// Debug (`showCapturedFrameScores`): replaces the regular result handling.
  /// [serverResult] is null when nothing was sent (dry run).
  void Function(
    List<CapturedFrameScore> frames,
    UploadImageStateV2? serverResult,
  )?
  showCapturedFrameScores;

  void attachCallbacks({
    VoidCallback? onProceed,
    VoidCallback? showLoader,
    VoidCallback? hideLoader,
    void Function(ErrorImageBottomSheetType type)? showCommonError,
    void Function(String title, String message, bool withInstruction)?
    showError,
    showErrorV2,
    void Function(
      List<CapturedFrameScore> frames,
      UploadImageStateV2? serverResult,
    )?
    showCapturedFrameScores,
  }) {
    this.onProceed = onProceed;
    this.showLoader = showLoader;
    this.hideLoader = hideLoader;
    this.showCommonError = showCommonError;
    this.showError = showError;
    this.showErrorV2 = showErrorV2;
    this.showCapturedFrameScores = showCapturedFrameScores;
  }

  CameraAvatarViewModel({required UploadImageUseCase setUseCase})
    : _setUseCase = setUseCase {
    init = _setup();
  }

  Future<void> _setup() async {}

  // Backend errors from most to least critical, following the priority table
  // in "Error handling logic in Liveness". The backend may return several
  // errors for one attempt; only the first entry of this list that is
  // present is shown.
  static const _backendErrorPriority = [
    AvatarDetectionStatus.halfAttempts,
    AvatarDetectionStatus.headwearIsOn,
    AvatarDetectionStatus.sunglassesOn,
    AvatarDetectionStatus.faceCovered,
    AvatarDetectionStatus.faceMaskOn,
    AvatarDetectionStatus.handNearFace,
    AvatarDetectionStatus.lowCameraResolution,
    AvatarDetectionStatus.chinOutOfFrame,
    AvatarDetectionStatus.foreheadOutOfFrame,
    AvatarDetectionStatus.faceTooFarFromCamera,
    AvatarDetectionStatus.eyesNotDetected,
    AvatarDetectionStatus.excessiveDarkness,
    AvatarDetectionStatus.excessiveBrightness,
    AvatarDetectionStatus.blurryPhoto,
  ];

  static AvatarDetectionStatus? _backendErrorStatus(int code) {
    switch (code) {
      // TODO: map the half-attempts signal to AvatarDetectionStatus.halfAttempts
      case 5013:
      case 5023:
        return AvatarDetectionStatus.headwearIsOn;
      case 5017:
        return AvatarDetectionStatus.excessiveBrightness;
      case 5020:
        return AvatarDetectionStatus.faceCovered;
      case 5021:
        return AvatarDetectionStatus.faceMaskOn;
      case 5022:
        return AvatarDetectionStatus.handNearFace;
      case 5024:
        return AvatarDetectionStatus.sunglassesOn;
      case 5012:
        return AvatarDetectionStatus.chinOutOfFrame;
      case 5011:
        return AvatarDetectionStatus.foreheadOutOfFrame;
      case 5010:
        return AvatarDetectionStatus.lowCameraResolution;
      case 5009:
        return AvatarDetectionStatus.blurryPhoto;
      case 5008:
        return AvatarDetectionStatus.eyesNotDetected;
      case 5006:
      case 5003:
        return AvatarDetectionStatus.faceTooFarFromCamera;
      case 5004:
        return AvatarDetectionStatus.excessiveDarkness;
      case 5007: // MY 3d depth phase? BACK: More faces
      case 5005: // Disputed
      case 5002: // Spoofing
      case 5001: // Deepfake
      case 4001: // No face
      default:
        return null;
    }
  }

  AvatarDetectionStatus? _pickBackendError(UploadImageErrorV2 result) {
    final codes = result.framesErrors.isEmpty
        ? [result.code]
        : result.framesErrors.map((e) => e.code);

    AvatarDetectionStatus? best;
    var bestRank = _backendErrorPriority.length;
    for (final code in codes) {
      final status = _backendErrorStatus(code);
      if (status == null) continue;
      final rank = _backendErrorPriority.indexOf(status);
      if (rank < bestRank) {
        best = status;
        bestRank = rank;
      }
    }
    return best;
  }

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
              cropToMask: CameraConstants.cropLivenessPhotosToMask,
            ),
          )
          .toList();

      final processedList =
          await compute<List<AvatarCropParams>, List<Uint8List>>(
            processAvatarShotBatchInIsolate,
            paramsList,
          );

      final debug = DataspikeInjector.component;
      if (debug.livenessDryRun) {
        // Dry run: photos are only taken to be scored, never uploaded.
        if (debug.showCapturedFrameScores) {
          showCapturedFrameScores?.call(
            await CapturedFramesScorer.score(processedList),
            null,
          );
        }
        return;
      }

      final batchFrames = <LivenessBatchFrame>[
        for (int i = 0; i < processedList.length; i++)
          LivenessBatchFrame(
            frameId: 'frame_$i',
            fileBytes: processedList[i],
            ext: 'jpg',
            fileName: 'selfie_$i.jpg',
          ),
      ];

      // Scoring runs alongside the upload, so it adds no wait of its own.
      final responses = await Future.wait<Object?>([
        _setUseCase.uploadImageV2(frames: batchFrames),
        if (debug.showCapturedFrameScores)
          CapturedFramesScorer.score(processedList),
      ]);
      final result = responses[0] as UploadImageStateV2;

      if (debug.showCapturedFrameScores) {
        showCapturedFrameScores?.call(
          responses[1] as List<CapturedFrameScore>,
          result,
        );
        return;
      }

      if (result is UploadImageSuccessV2) {
        onProceed?.call();
      } else if (result is UploadImageErrorV2) {
        showErrorV2?.call(_pickBackendError(result));
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
