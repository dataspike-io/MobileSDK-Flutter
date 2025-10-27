import 'package:dataspikemobilesdk/main/coordinator/coordinator.dart';
import 'package:flutter/material.dart';
import '../../../ui/top_bar.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';

class CameraAccessScreen extends StatefulWidget {
  const CameraAccessScreen({super.key});

  @override
  State<CameraAccessScreen> createState() => _CameraAccessScreenState();
}

class _CameraAccessScreenState extends State<CameraAccessScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              TopBar(hasTimer: true),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Spacer(),
                            Text(
                              'Allow camera access to continue',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                                fontFamily: 'FunnelDisplay',
                                package: 'dataspikemobilesdk',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'We need access to your camera to complete verification. It`s used only to check liveness and confirm your identity.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black,
                                fontFamily: 'Figtree',
                                package: 'dataspikemobilesdk',
                              ),
                            ),
                            const SizedBox(height: 24),
                            ContinueButton(
                              text: 'Allow camera access',
                              onPressed: () async {
                                try {
                                  final isGranted = await DataspikeInjector
                                      .component
                                      .permissionService
                                      .requestCameraPermission();
                                  if (!mounted) return;
                                  if (isGranted) {
                                    DataspikeCoordinator.proceedNext(
                                      context,
                                      after: DataspikeStep.cameraAccess,
                                    );
                                  } else {
                                    DataspikeCoordinator.showCameraDeniedScreen(
                                      context,
                                    );
                                  }
                                } catch (e) {
                                  debugPrint('Camera permission error: $e');
                                }
                              },
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                    Image.asset(
                      'packages/dataspikemobilesdk/assets/images/allow_camera_access.png',
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
