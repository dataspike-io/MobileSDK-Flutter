import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/main/models/dataspike_dependencies.dart';
import '../view_models/input_view_model.dart';
import '../view_models/view_model_factory.dart';
import '../view/models/new_verification_ui_state.dart';
import '../dependencies_provider/sample_app_injector.dart';
import '../dependencies_provider/model/sample_app_dependencies.dart';

class DependenciesInputScreen extends StatefulWidget {
  final void Function(BuildContext context, DataspikeDependencies deps)
  onSubmit;

  const DependenciesInputScreen({super.key, required this.onSubmit});

  @override
  State<DependenciesInputScreen> createState() =>
      _DependenciesInputScreenState();
}

class _DependenciesInputScreenState extends State<DependenciesInputScreen> {
  final _apiTokenController = TextEditingController();
  final _shortIdController = TextEditingController();
  bool _isDebug = false;

  late final InputViewModel viewModel;

  @override
  void initState() {
    super.initState();
    SampleAppInjector.setComponent(SampleAppDependencies.dependencies);
    viewModel = InputViewModelFactory().create<InputViewModel>();
    _apiTokenController.text = viewModel.dependencies.dsApiToken;
    _shortIdController.text = viewModel.dependencies.shortId;
    _isDebug = viewModel.dependencies.isDebug;
    viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    _apiTokenController.dispose();
    _shortIdController.dispose();
    viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    final state = viewModel.verificationState;
    if (state is NewVerificationUiSuccess) {
      _startDataspikeFlow(
        shortId: state.shortId,
        apiToken: _apiTokenController.text.trim(),
        isDebug: _isDebug,
      );
    } else if (state is NewVerificationUiError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${state.details}: ${state.error}'),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _startDataspikeFlow({
    required String shortId,
    required String apiToken,
    required bool isDebug,
  }) {
    final deps = DataspikeDependencies(
      isDebug: _isDebug,
      dsApiToken: apiToken,
      shortId: shortId,
    );
    widget.onSubmit(context, deps);
  }

  void _submit() {
    viewModel.createVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Dependencies')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _apiTokenController,
              decoration: const InputDecoration(
                labelText: 'API Token',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                viewModel.onApiTokenChanged(value);
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _shortIdController,
              decoration: const InputDecoration(
                labelText: 'Short ID (optional)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                viewModel.onShortIdChanged(value);
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isDebug,
                  onChanged: (v) {
                    viewModel.onIsDebugChanged(v ?? false);
                    setState(() => _isDebug = v ?? false);
                  },
                ),
                const Text('Debug mode'),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _apiTokenController.text.isNotEmpty ? _submit : null,
                child: const Text('Start Verification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
