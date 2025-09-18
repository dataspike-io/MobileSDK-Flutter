import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import 'package:dataspikemobilesdk/view/ui/camera/two_arcs_painter.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/loader.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/view_models/camera_avatar_view_model.dart';
import '/main/coordinator/coordinator.dart';

class LiveAvatarCamera extends StatefulWidget {
  const LiveAvatarCamera({super.key});

  @override
  State<LiveAvatarCamera> createState() => _LiveAvatarCameraState();
}

class _LiveAvatarCameraState extends State<LiveAvatarCamera> {
  static const double _sideInsetPct = 0.10;
  static const double _topApexPct = 0.10;
  static const double _bottomApexFromBottomPct = 0.20;
  static const double _topRisePx = 120;
  static const double _bottomRisePx = 120;
  static const double _ctrlXpx = 80;
  static const double _strokeWidth = 3;

  late final CameraAvatarViewModel viewModel;

  @override
  void initState() {
    viewModel = DataspikeViewModelFactory().create<CameraAvatarViewModel>();
    viewModel.attachCallbacks(
      onProceed: () => proceedNext(),
      showLoader: showLoader,
      hideLoader: hideLoader,
      showError: (msg) => showError(msg),
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

  void shootAndCrop(GlobalKey previewKey) async {
    await viewModel.shootAndCrop(previewKey, MediaQuery.of(context).size);
  }

  void showLoader() async {
    if (!mounted) return;
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      barrierColor: AppColors.blackTransparent,
      builder: (_) => const Center(child: Loader()),
    );
  }

  void hideLoader() {
    if (!mounted) return;
    final rootNav = Navigator.of(context, rootNavigator: true);
    rootNav.pop();
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Upload error: $message')));
  }

  @override
  Widget build(BuildContext context) {
    final previewKey = GlobalKey();
    final screenSize = MediaQuery.of(context).size;

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
                              final ps = viewModel.ctrl!.value.previewSize!;
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
                                        child: CameraPreview(viewModel.ctrl!),
                                      ),
                                    ),
                                  ),

                                  CustomPaint(
                                    size: Size(c.maxWidth, c.maxHeight),
                                    painter: TwoArcsPainter(
                                      color: AppColors.white,
                                      strokeWidth: _strokeWidth,
                                      sideInsetPct: _sideInsetPct,
                                      topApexPct: _topApexPct,
                                      bottomApexFromBottomPct:
                                          _bottomApexFromBottomPct,
                                      topRisePx: _topRisePx,
                                      bottomRisePx: _bottomRisePx,
                                      ctrlXpx: _ctrlXpx,
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
                    const SizedBox(height: 10),
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
