import 'dart:async';
import 'package:dataspikemobilesdk/view/ui/loader.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view_models/dataspike_activity_view_model.dart';
import 'package:dataspikemobilesdk/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/domain/models/states/verification_state.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';

class DataspikeScreen extends StatefulWidget {
  final void Function(BuildContext context) onSuccess;
  final void Function(BuildContext context) onFail;

  const DataspikeScreen({
    super.key,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<DataspikeScreen> createState() => _DataspikeScreenState();
}

class _DataspikeScreenState extends State<DataspikeScreen> {
  late final DataspikeActivityViewModel viewModel;
  StreamSubscription<VerificationState>? _verificationSubscription;

  @override
  void initState() {
    super.initState();
    viewModel = DataspikeViewModelFactory()
        .create<DataspikeActivityViewModel>();

    _verificationSubscription = viewModel.verificationFlow.listen((
      verificationState,
    ) {
      if (verificationState is VerificationSuccess) {
        widget.onSuccess(context);
      } else if (verificationState is VerificationError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(
                content: Text(
                  '${verificationState.details}: ${verificationState.error}',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 28,
                    fontFamily: 'FunnelDisplay',
                    fontWeight: FontWeight.w600,
                    package: 'dataspikemobilesdk',
                  ),
                ),
                duration: const Duration(seconds: 4),
              ),
            )
            .closed
            .then((_) {
              widget.onFail(context);
            });
      }
    });

    viewModel.getVerification(false);
  }

  @override
  void dispose() {
    _verificationSubscription?.cancel();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [const Center(child: Loader(color: AppColors.slateGray))],
          ),
        ),
      ),
    );
  }
}
