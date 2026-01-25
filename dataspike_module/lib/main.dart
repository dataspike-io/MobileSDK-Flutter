import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/dataspikemobilesdk.dart';
import 'package:dataspikemobilesdk/native_bridge.dart';
import 'package:dataspikemobilesdk/main/models/dataspike_dependencies.dart';
import 'package:dataspikemobilesdk/main/models/dataspike_verifications_status.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: _HostScreen());
  }
}

class _HostScreen extends StatefulWidget {
  const _HostScreen();

  @override
  State<_HostScreen> createState() => _HostScreenState();
}

class _HostScreenState extends State<_HostScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DataspikeHostChannel.ensureInitialized(
        onStartRequested: (args) async {
          final deps = DataspikeDependencies(
            isDebug: args['isDebug'],
            dsApiToken: args['dsApiToken'],
            shortId: args['shortId'],
          );

          await Dataspikemobilesdk().startDataspikeFlow(
            context: context,
            dependencies: deps,
            callback: (result) async {
              await DataspikeHostChannel.sendCompleted({
                "status": result?.toJson(),
              });
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: ColoredBox(color: AppColors.white)
    );
  }
}
