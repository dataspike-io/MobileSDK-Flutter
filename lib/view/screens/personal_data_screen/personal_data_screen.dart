import 'package:dataspikemobilesdk/view_models/personal_data_view_model.dart';
import 'package:flutter/material.dart';
import '../../ui/top_bar.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view/ui/continue_button.dart';
import '/view_models/factory/dataspike_view_model_factory.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_representation_type.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_type.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_option_type.dart';
import 'package:dataspikemobilesdk/view/screens/countries_screen/countries_screen.dart';

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
            TopBar(timer: timer),
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
              valid: fields[i].value == null ? true : fields[i].isValid,
              onChanged: onChanged,
            ),
            if (i < fields.length - 1)
              SizedBox(height: 24),
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
  final bool valid;
  final void Function(int, String?) onChanged;

  const _FieldLine({
    required this.index,
    required this.field,
    required this.value,
    required this.valid,
    required this.onChanged,
  });

  bool get isSelectChoices => field.options.type == ManualCustomFieldOptionType.select;
  bool get isListPicker => field.options.type == ManualCustomFieldOptionType.list;

  @override
  Widget build(BuildContext context) {
    final borderColor = valid ? AppColors.lightAccent : Colors.red;

    if (isListPicker) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(text: field.caption),
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final picked = await Navigator.of(context).push<String>(
                MaterialPageRoute(
                  builder: (_) => CountryPickerScreen(
                    title: 'Please, choose your ${field.caption.toLowerCase()}',
                    onCountrySelected: (country) {
                      onChanged(index, country);
                    },
                  ),
                ),
              );
              if (picked != null && picked.isNotEmpty) {
                onChanged(index, picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 1.4),
                borderRadius: BorderRadius.circular(14),
                color: AppColors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value?.isNotEmpty == true
                          ? value!
                          : (field.placeholder ?? 'Select ${field.caption.toLowerCase()}'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: value?.isNotEmpty == true
                            ? AppColors.black
                            : AppColors.lightAccent,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_right_rounded,
                      color: AppColors.black),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (isSelectChoices) {
      final opts = field.options.choices ?? [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(text: field.caption),
          const SizedBox(height: 8),
          _RadioChoices(
            options: opts,
            value: value,
            onChanged: (v) => onChanged(index, v),
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
                borderSide: BorderSide(color: borderColor, width: 1.4),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: borderColor, width: 1.4),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: borderColor,
                  width: 1.6,
                ),
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

class _RadioChoices extends StatelessWidget {
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  const _RadioChoices({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          for (int i = 0; i < options.length; i++) ...[
            _RadioRow(
              text: options[i],
              selected: value == options[i],
              onTap: () => onChanged(options[i]),
            ),
            if (i < options.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.lightAccent.withOpacity(.25),
              ),
          ],
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _RadioRow({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
        child: Row(
          children: [
            _CustomRadio(selected: selected),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomRadio extends StatelessWidget {
  final bool selected;
  const _CustomRadio({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
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
        duration: const Duration(milliseconds: 160),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.accent : Colors.transparent,
        ),
      ),
    );
  }
}