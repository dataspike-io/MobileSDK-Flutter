import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/view_models/camera_document_view_model.dart';
import 'package:dataspikemobilesdk/view/ui/camera/grey_corner_painter.dart';
import 'package:dataspikemobilesdk/view/ui/camera/dim_overlay_painter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dataspikemobilesdk/view/ui/loader.dart';
import '/main/coordinator/coordinator.dart';

class LiveCropCamera extends StatefulWidget {
  const LiveCropCamera({super.key});

  @override
  State<LiveCropCamera> createState() => _LiveCropCameraState();
}

class _LiveCropCameraState extends State<LiveCropCamera> {
  late final CameraDocumentViewModel viewModel;

  @override
  void initState() {
    viewModel = DataspikeViewModelFactory().create<CameraDocumentViewModel>();
    super.initState();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void proceedNext() {
    DataspikeCoordinator.proceedNext(
      context,
      after: DataspikeStep.documentCamera,
    );
  }

  void shootAndCrop(GlobalKey previewKey) async {
    await viewModel.shootAndCrop(previewKey, MediaQuery.of(context).size);
    proceedNext();
  }

  void pickAndUploadDocument() async {
    try {
      await viewModel.pickAndUploadDocument();
      proceedNext();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewKey = GlobalKey();
    final screenSize = MediaQuery.of(context).size;

    final cropWidth = screenSize.width * 0.85;
    final cropHeight = screenSize.height * 0.3;

    final camWidth = screenSize.width;
    final camHeight = screenSize.height * 0.65;

    final timer = viewModel.timerDuration;

    return FutureBuilder(
      future: viewModel.init,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: const Center(child: Loader()),
          );
        }

        return AnimatedBuilder(
          animation: viewModel,
          builder: (context, _) {
            final ctrl = viewModel.ctrl;
            final isReady = ctrl != null && ctrl.value.isInitialized;

            if (!isReady) {
              return Scaffold(
                backgroundColor: AppColors.white,
                body: const Center(child: Loader()),
              );
            }

            return Scaffold(
              backgroundColor: AppColors.white,
              body: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TopBar(timer: timer),
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

                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Transform.scale(
                                    scale: coverScale,
                                    child: Center(
                                      child: AspectRatio(
                                        aspectRatio: previewAR,
                                        child: CameraPreview(
                                          ctrl,
                                          key: ValueKey(ctrl.description.name),
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
                                                  viewModel.frontCam != null &&
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
                                  Positioned(
                                    top: 100,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Text(
                                        'Please make a photo of front-side of ID',
                                        style: const TextStyle(
                                          color: AppColors.white,
                                          fontSize: 14,
                                          decoration: TextDecoration.none,
                                        ),
                                        textAlign: TextAlign.center,
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
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ContinueButton(
                          text: 'Take a photo',
                          onPressed: () => shootAndCrop(previewKey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    SizedBox(
                      height: 60.0,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: TextButton(
                          onPressed: viewModel.pickAndUploadDocument,
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
