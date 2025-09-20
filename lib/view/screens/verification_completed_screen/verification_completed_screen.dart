import 'dart:async';
import 'package:dataspikemobilesdk/view_models/verification_completed_view_model.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/domain/models/states/proceed_with_verification_state.dart';

class VerificationCompletedScreen extends StatefulWidget {
  const VerificationCompletedScreen({super.key});

  @override
  State<VerificationCompletedScreen> createState() => _VerificationCompletedScreenState();
}

class _VerificationCompletedScreenState extends State<VerificationCompletedScreen> {
  late final VerificationCompletedViewModel viewModel;

  StreamSubscription? _verificationSubscription;
  Object? _state; 

  @override
  void initState() {
    super.initState();
    viewModel = DataspikeViewModelFactory().create<VerificationCompletedViewModel>();

    _verificationSubscription = viewModel.verificationFlow.listen((verificationState) {
      setState(() {
        _state = verificationState;
      });
    });

    viewModel.getVerificationCompleted();
  }

  @override
  void dispose() {
    _verificationSubscription?.cancel();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;

    if (state == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isSuccess = state is ProceedWithVerificationStateSuccess;
    final title = isSuccess ? 'Success' : 'Error';
    final icon = isSuccess ? Icons.check_circle : Icons.error;
    final color = isSuccess ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      package: 'dataspikemobilesdk',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    state.toString(), 
                    style: const TextStyle(
                      fontSize: 14,
                      package: 'dataspikemobilesdk',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (!isSuccess)
                ElevatedButton(
                  onPressed: viewModel.getVerificationCompleted,
                  child: const Text('Retry'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
