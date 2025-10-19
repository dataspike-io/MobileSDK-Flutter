import 'package:flutter/material.dart';
import '../../../ui/top_bar.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/camera/additional/info_card_without_image.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CameraDeniedScreen extends StatefulWidget {
  const CameraDeniedScreen({super.key});

  @override
  State<CameraDeniedScreen> createState() => _CameraDeniedScreenState();
}

class _CameraDeniedScreenState extends State<CameraDeniedScreen> {
  String _appName = '';

  @override
  void initState() {
    super.initState();
    _loadAppName();
  }

  Future<void> _loadAppName() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final name = info.appName.trim();
      if (!mounted) return;
      setState(() {
        _appName = name.isNotEmpty ? name : info.packageName.split('.').last;
      });
    } catch (e) {
      debugPrint('PackageInfo error: $e');
      if (!mounted) return;
      setState(() => _appName = '');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appName = _appName.isEmpty ? 'this app' : _appName;

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
                    Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Camera access needed',
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
                              'To continue, please enable camera access for $appName in your device settings:',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black,
                                fontFamily: 'Figtree',
                                package: 'dataspikemobilesdk',
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 64,
                              child: InfoCardWithoutImage(
                                title:
                                    'Go to Settings → Privacy → Camera and allow $appName access to the camera',
                              ),
                            ),
                            SizedBox(height: 22),
                          ],
                        ),
                    ),
                   Flexible(
                      child: Image.asset(
                        'packages/dataspikemobilesdk/assets/images/camera_access_denied.png',
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.bottomCenter,
                      ),
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
