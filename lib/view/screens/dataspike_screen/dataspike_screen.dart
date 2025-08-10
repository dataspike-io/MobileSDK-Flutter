import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view_models/dataspike_activity_view_model.dart';
import 'package:dataspikemobilesdk/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/domain/models/verification_state.dart';

class DataspikeScreen extends StatefulWidget {
  final void Function(BuildContext context) onSuccess;
  final void Function(BuildContext context) onFail;

  const DataspikeScreen({
    Key? key,
    required this.onSuccess,
    required this.onFail,
  }) : super(key: key);

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

    viewModel.getVerification(
      false,
    ); // Assuming darkModeIsEnabled is false for prefetch
  }

  @override
  void dispose() {
    _verificationSubscription?.cancel();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [const CircularProgressIndicator()],
        ),
      ),
    );
  }
}
