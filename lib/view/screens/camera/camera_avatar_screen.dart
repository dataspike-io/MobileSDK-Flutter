import 'package:dataspikemobilesdk/view/ui/camera/detection/face_detector_view.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/loader.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/view_models/camera_avatar_view_model.dart';
import '/main/coordinator/coordinator.dart';
import 'package:dataspikemobilesdk/view/ui/camera/error_bottom_sheet.dart';
import 'package:dataspikemobilesdk/domain/models/instruction_type.dart';
import 'package:dataspikemobilesdk/view/ui/error/error_image_bottom_sheet.dart';

class LiveAvatarCamera extends StatefulWidget {
  const LiveAvatarCamera({super.key});

  @override
  State<LiveAvatarCamera> createState() => _LiveAvatarCameraState();
}

class _LiveAvatarCameraState extends State<LiveAvatarCamera> {
  late final CameraAvatarViewModel viewModel;

  @override
  void initState() {
    viewModel = DataspikeViewModelFactory().create<CameraAvatarViewModel>();
    viewModel.attachCallbacks(
      onProceed: () => proceedNext(),
      showLoader: showLoader,
      hideLoader: hideLoader,
      showError: (title, msg, instruction) =>
          showError(title, msg, instruction),
      showCommonError: (type) => _showCommonError(type),
    );
    super.initState();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void proceedNext() {
    if (!mounted) return;
    DataspikeCoordinator.proceedNext(
      context,
      after: DataspikeStep.selfieCamera,
    );
  }

  void showLoader() async {
    if (!mounted) return;
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: AppColors.slateGray,
      builder: (_) => Align(
        alignment: const Alignment(0, -0.15), 
        child: const Loader(),
      ),
    );
  }

  void hideLoader() {
    if (!mounted) return;
    final rootNav = Navigator.of(context, rootNavigator: true);
    rootNav.pop();
  }

  void showError(String title, String message, bool withInstruction) {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: AppColors.clear,
      barrierColor: AppColors.clear,
      builder: (_) => ErrorBottomSheet(
        title: title,
        message: message,
        instruction: withInstruction ? InstructionType.liveness : null,
      ),
    );
  }

  void _showCommonError(ErrorImageBottomSheetType type) {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: AppColors.clear,
      barrierColor: AppColors.clear,
      builder: (_) => ErrorImageBottomSheet(
        type: type,
        onContinue: () {
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              TopBar(hasTimer: true),
              Expanded(
                child: FaceDetectorView(
                  onShootCallback:
                      (imageBytes, previewKeySize, screenSize, previewSize) =>
                          viewModel.shootAndCrop(
                            imageBytes,
                            previewKeySize,
                            screenSize,
                            previewSize,
                          ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
