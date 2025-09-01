import 'package:dataspikemobilesdk/view_models/personal_data_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/timer/timer_box.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import '/view_models/onboarding_view_model.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({Key? key}) : super(key: key);

  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => const PersonalDataScreen());

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  late final PersonalDataViewModel viewModel;
  final Map<int, String?> _values = {};

  @override
  void initState() {
    super.initState();
    viewModel = DataspikeViewModelFactory().create<PersonalDataViewModel>();
    viewModel.setVerificationTimer();
    viewModel.addListener(_onVmChanged);
    // Если данные приходят позже, вызовите повторно viewModel.collectManualFields() когда ответ готов.
  }

  @override
  void dispose() {
    viewModel.removeListener(_onVmChanged);
    super.dispose();
  }

  void _onVmChanged() => setState(() {});

  void _onContinue() {
    final payload = <String, String>{};
    final fields = viewModel.orderedFields;
    for (var i = 0; i < fields.length; i++) {
      final v = _values[i];
      if (v != null && v.trim().isNotEmpty) {
        final key = fields[i].standard?.caption ?? fields[i].custom?.label ?? 'field_$i';
        payload[key] = v;
      }
    }
    viewModel.submitProfileData(payload);
  }

  bool get _allFilled {
    final fields = viewModel.orderedFields;
    if (fields.isEmpty) return false;
    for (var i = 0; i < fields.length; i++) {
      if (!fields[i].enabled) continue;
      final v = _values[i];
      if (v == null || v.trim().isEmpty) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final timer = viewModel.timerDuration;
    final fields = viewModel.orderedFields;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(timer: timer),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Complete personal data',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (fields.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      for (var i = 0; i < fields.length; i++) ...[
                        _DynamicFieldWidget(
                          field: fields[i],
                          value: _values[i],
                          onChanged: (v) => setState(() => _values[i] = v),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ContinueButton(
                      text: 'Continue',
                      onPressed: _allFilled ? _onContinue : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final Duration? timer;
  const _TopBar({required this.timer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          IconButton(
            splashRadius: 24,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: AppColors.black),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: Center(
              child: timer == null
                  ? const SizedBox.shrink()
                  : TimeBox(
                      initialTime: timer!,
                      onFinish: () {
                        Navigator.of(context).pop();
                      },
                    ),
            ),
          ),
          GestureDetector(
            onTap: () {
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'packages/dataspikemobilesdk/assets/images/flags_ae.svg',
                  height: 16,
                  width: 22,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 2),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: AppColors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DynamicFieldWidget extends StatelessWidget {
  final RenderableManualField field;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _DynamicFieldWidget({
    required this.field,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (field.hasChoices) {
      return _ChoicesCard(
        caption: field.caption,
        choices: field.choices,
        value: value,
        onChanged: onChanged,
      );
    }
    return _TextInputCard(
      caption: field.caption,
      value: value,
      onChanged: onChanged,
    );
  }
}

class _TextInputCard extends StatelessWidget {
  final String caption;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _TextInputCard({
    required this.caption,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightAccent.withOpacity(.6)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caption,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoicesCard extends StatelessWidget {
  final String caption;
  final List<String> choices;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _ChoicesCard({
    required this.caption,
    required this.choices,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightAccent.withOpacity(.6)),
        borderRadius: BorderRadius.circular(28),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            caption,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < choices.length; i++) ...[
            _RadioRow(
              title: choices[i],
              groupValue: value,
              value: choices[i],
              onChanged: onChanged,
            ),
            if (i < choices.length - 1)
              Divider(height: 24, color: AppColors.lightAccent.withOpacity(.4)),
          ],
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String title;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;
  const _RadioRow({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            _RadioIcon(selected: selected),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioIcon extends StatelessWidget {
  final bool selected;
  const _RadioIcon({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.lightAccent,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}