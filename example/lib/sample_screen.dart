import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/main/models/dataspike_dependencies.dart';

class DependenciesInputScreen extends StatefulWidget {
  final void Function(BuildContext,DataspikeDependencies) onSubmit;

  const DependenciesInputScreen({super.key, required this.onSubmit});

  @override
  State<DependenciesInputScreen> createState() => _DependenciesInputScreenState();
}

class _DependenciesInputScreenState extends State<DependenciesInputScreen> {
  final _apiTokenController = TextEditingController();
  final TextEditingController? _shortIdController = TextEditingController();
  bool _isDebug = false;

  @override
  void dispose() {
    _apiTokenController.dispose();
    _shortIdController?.dispose();
    super.dispose();
  }

  void _submit() {
    final deps = DataspikeDependencies(
      isDebug: _isDebug,
      dsApiToken: _apiTokenController.text.trim(),
      shortId: _shortIdController?.text.trim() ?? '',
    );
    widget.onSubmit(context, deps);
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
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _shortIdController,
              decoration: const InputDecoration(
                labelText: 'Short ID (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isDebug,
                  onChanged: (v) => setState(() => _isDebug = v ?? false),
                ),
                const Text('Debug mode'),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}