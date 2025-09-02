import 'package:dataspikemobilesdk/view_models/personal_data_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/timer/timer_box.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_representation_type.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_type.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_option_type.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  static Route route() =>
      MaterialPageRoute<void>(builder: (_) => const PersonalDataScreen());

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  late final PersonalDataViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = DataspikeViewModelFactory().create<PersonalDataViewModel>();
    viewModel.setVerificationTimer();
    viewModel.addListener(_onVmChanged);
  }

  @override
  void dispose() {
    viewModel.removeListener(_onVmChanged);
    super.dispose();
  }

  void _onVmChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final timer = viewModel.timerDuration;
    final fields = viewModel.personalDataFields;

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
                      _FieldsCard(
                        fields: fields,
                        onChanged: (index, val) {
                          setState(() {
                            fields[index].value = val;
                          });
                        },
                      ),
                    const SizedBox(height: 24),
                    ContinueButton(
                      text: 'Continue',
                      onPressed: viewModel.isContinueButtonDisabled 
                      ? null 
                      : viewModel.submitProfileData,
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
            onTap: () {},
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

class _FieldsCard extends StatelessWidget {
  final List<ManualCustomFieldRepresentationModel> fields;
  final void Function(int index, String? value) onChanged;
  const _FieldsCard({
    required this.fields,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightAccent.withOpacity(.6)),
        borderRadius: BorderRadius.circular(28),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            _FieldLine(
              index: i,
              field: fields[i],
              value: fields[i].value,
              onChanged: onChanged,
            ),
          ],
          const SizedBox(height: 28),

          Center(
            child: Image.asset(
              'packages/dataspikemobilesdk/assets/images/personal_data_dinosaurs.png',
              height: 140,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLine extends StatelessWidget {
  final int index;
  final ManualCustomFieldRepresentationModel field;
  final String? value;
  final void Function(int, String?) onChanged;
  const _FieldLine({
    required this.index,
    required this.field,
    required this.value,
    required this.onChanged,
  });

  bool get isChoice {
    final t = field.options?.type;
    return t == ManualCustomFieldOptionType.select ||
           t == ManualCustomFieldOptionType.list ||
           (field.options?.choices.isNotEmpty == true);
  }

  @override
  Widget build(BuildContext context) {
    if (isChoice) {
      final opts = field.options?.choices ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(text: field.caption),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final o in opts)
                _ChipChoice(
                  text: o,
                  selected: value == o,
                  onTap: () => onChanged(index, o),
                ),
            ],
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(text: field.caption),
        const SizedBox(height: 8),
        TextField(
          keyboardType: _keyboardTypeFor(field.fieldType),
          decoration: InputDecoration(
            isDense: true,
            hintText: field.placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          controller: TextEditingController.fromValue(
            TextEditingValue(
              text: value ?? '',
              selection: TextSelection.collapsed(offset: (value ?? '').length),
            ),
          ),
          onChanged: (v) => onChanged(index, v),
        ),
      ],
    );
  }

  TextInputType _keyboardTypeFor(ManualCustomFieldType? t) {
    switch (t) {
      case ManualCustomFieldType.email:
        return TextInputType.emailAddress;
      case ManualCustomFieldType.phone:
        return TextInputType.phone;
      case ManualCustomFieldType.dob:
        return TextInputType.datetime;
      default:
        return TextInputType.text;
    }
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      ),
    );
  }
}

class _ChipChoice extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _ChipChoice({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
            color: selected
                ? AppColors.accent.withOpacity(.12)
                : AppColors.lightAccent.withOpacity(.15),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.lightAccent,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? AppColors.accent : AppColors.black,
          ),
        ),
      ),
    );
  }
}