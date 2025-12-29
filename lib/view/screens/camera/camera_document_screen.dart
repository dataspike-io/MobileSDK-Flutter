import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view/ui/continue_circle_button.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/view_models/camera_document_view_model.dart';
import 'package:dataspikemobilesdk/view/ui/camera/grey_corner_painter.dart';
import 'package:dataspikemobilesdk/view/ui/camera/dim_overlay_painter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dataspikemobilesdk/view/ui/loader.dart';
import '/main/coordinator/coordinator.dart';
import 'package:dataspikemobilesdk/view/ui/camera/instruction_pill.dart';
import 'package:dataspikemobilesdk/view/ui/camera/error_bottom_sheet.dart';
import 'package:dataspikemobilesdk/domain/models/document_type.dart';
import 'package:dataspikemobilesdk/domain/models/instruction_type.dart';
import 'package:dataspikemobilesdk/view/ui/error/error_image_bottom_sheet.dart';
import 'package:dataspikemobilesdk/view/ui/camera/file_chooser_sheet.dart';

class LiveCropCamera extends StatefulWidget {
  const LiveCropCamera({super.key, required this.docType});

  final DocumentType docType;

  @override
  State<LiveCropCamera> createState() => _LiveCropCameraState();
}

class _LiveCropCameraState extends State<LiveCropCamera> {
  late final CameraDocumentViewModel viewModel;
  bool _isLoading = false;

  @override
  void initState() {
    viewModel = DataspikeViewModelFactory().createCameraDocumentViewModel(
      docType: widget.docType,
    );

    viewModel.attachCallbacks(
      onProceed: () => proceedNext(),
      showLoader: showLoader,
      hideLoader: hideLoader,
      showChooserSheet: showFileChooserSheet,
      showError: (title, msg, withInstruction) =>
          showError(title, msg, withInstruction),
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
    switch (widget.docType) {
      case DocumentType.identity:
        DataspikeCoordinator.proceedNext(
          context,
          after: DataspikeStep.documentCamera,
        );
      case DocumentType.address:
        DataspikeCoordinator.proceedNext(context, after: DataspikeStep.address);
    }
  }

  void shootAndCrop(GlobalKey previewKey) async {
    await viewModel.shootAndCrop(previewKey, MediaQuery.of(context).size);
  }

  void showLoader() async {
    if (!mounted) return;
    _isLoading = true;
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: AppColors.slateGray,
      builder: (_) =>
          Align(alignment: const Alignment(0, -0.15), child: const Loader()),
    );
  }

  void hideLoader() {
    if (!mounted) return;
    _isLoading = false;
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
        instruction: withInstruction ? InstructionType.poi : null,
      ),
    );
  }

  void showFileChooserSheet() {
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: AppColors.clear,
      barrierColor: AppColors.clear,
      builder: (_) => FileChooserSheet(
        onImagePressed: () => viewModel.pickAndUploadImage(),
        onFilePressed: () => viewModel.pickAndUploadDocument(),
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
    final previewKey = GlobalKey();
    final screenSize = MediaQuery.of(context).size;

    final camWidth = screenSize.width;
    final camHeight = screenSize.height * 0.65;

    final cropWidth =
        screenSize.width *
        (widget.docType == DocumentType.identity ? 0.85 : 0.6);
    final cropHeight =
        screenSize.height *
        (widget.docType == DocumentType.identity ? 0.3 : 0.5);

    return FutureBuilder(
      future: viewModel.init,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return PopScope(
            canPop: false,
            child: Scaffold(
              backgroundColor: AppColors.white,
              body: const Center(child: Loader(color: AppColors.slateGray)),
            ),
          );
        }

        return AnimatedBuilder(
          animation: viewModel,
          builder: (context, _) {
            final ctrl = viewModel.ctrl;
            final isReady = ctrl != null && ctrl.value.isInitialized;

            if (!isReady) {
              return PopScope(
                canPop: false,
                child: Scaffold(
                  backgroundColor: AppColors.white,
                  body: const Center(child: Loader(color: AppColors.slateGray)),
                ),
              );
            }

            return PopScope(
              canPop: false,
              child: Scaffold(
                backgroundColor: AppColors.white,
                body: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TopBar(hasTimer: true),
                      Center(
                        child: SizedBox(
                          key: previewKey,
                          width: camWidth,
                          height: camHeight,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: LayoutBuilder(
                              builder: (context, c) {
                                final ps = ctrl.value.previewSize!;
                                final previewAR = ps.height / ps.width;
                                final containerAR = c.maxWidth / c.maxHeight;
                                final coverScale = previewAR / containerAR;
                                final coverScaleRation = coverScale >= 1
                                    ? coverScale
                                    : 1 / coverScale;

                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Transform.scale(
                                      scale: coverScaleRation,
                                      child: Center(
                                        child: AspectRatio(
                                          aspectRatio: previewAR,
                                          child: CameraPreview(
                                            ctrl,
                                            key: ValueKey(
                                              ctrl.description.name,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: DimOverlayPainter(
                                          holeRect: Rect.fromCenter(
                                            center: Offset(
                                              c.maxWidth / 2,
                                              c.maxHeight / 2,
                                            ),
                                            width: cropWidth,
                                            height: cropHeight,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: CustomPaint(
                                        size: Size(cropWidth, cropHeight),
                                        painter: GreyCornersPainter(
                                          rect: Rect.fromLTWH(
                                            0,
                                            0,
                                            cropWidth,
                                            cropHeight,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 24,
                                      right: 24,
                                      child:
                                          (viewModel.frontCam != null ||
                                              viewModel.backCam != null)
                                          ? Builder(
                                              builder: (context) {
                                                final canSwitch =
                                                    viewModel.frontCam !=
                                                        null &&
                                                    viewModel.backCam != null;
                                                return Opacity(
                                                  opacity: canSwitch ? 1 : 0.4,
                                                  child: GestureDetector(
                                                    onTap: canSwitch
                                                        ? () async {
                                                            await viewModel
                                                                .toggleCamera();
                                                          }
                                                        : null,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        SvgPicture.asset(
                                                          'packages/dataspikemobilesdk/assets/images/camera.svg',
                                                          height: 24,
                                                          width: 24,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                          : const SizedBox.shrink(),
                                    ),

                                    if (widget.docType == DocumentType.identity)
                                      Positioned(
                                        bottom: 60,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: AnimatedSwitcher(
                                            duration: const Duration(
                                              milliseconds: 650,
                                            ),
                                            switchInCurve: Curves.easeOutBack,
                                            switchOutCurve: Curves.easeInBack,
                                            transitionBuilder:
                                                (
                                                  Widget child,
                                                  Animation<double> animation,
                                                ) {
                                                  final fade = FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  );
                                                  final slide = SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(
                                                        0,
                                                        0.65,
                                                      ),
                                                      end: Offset.zero,
                                                    ).animate(animation),
                                                    child: fade,
                                                  );
                                                  final scale = ScaleTransition(
                                                    scale: Tween<double>(
                                                      begin: 0.5,
                                                      end: 1.0,
                                                    ).animate(animation),
                                                    child: slide,
                                                  );
                                                  return scale;
                                                },
                                            child: _isLoading
                                                ? const SizedBox.shrink()
                                                : InstructionPill(
                                                    key: ValueKey(
                                                      viewModel.hint,
                                                    ),
                                                    text: viewModel.hint,
                                                  ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      CircularContinueButton(
                        onPressed: () => shootAndCrop(previewKey),
                      ),
                      const SizedBox(height: 2),
                      if (viewModel.isUploadButtonVisible)
                        SizedBox(
                          height: 60.0,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: TextButton(
                              onPressed: viewModel.pickButtonTap,
                              child: Text(
                                'Upload document',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Figtree',
                                  package: 'dataspikemobilesdk',
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
