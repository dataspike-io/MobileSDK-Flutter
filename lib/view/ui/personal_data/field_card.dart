import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_representation_type.dart';
import 'field_line.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_option_type.dart';

class FieldsCard extends StatelessWidget {
  final List<ManualCustomFieldRepresentationModel> fields;
  final void Function(int index, String? value) onChanged;
  final void Function(int index, PlatformFile file)? uploadFile;
  const FieldsCard({super.key, required this.fields, required this.onChanged, this.uploadFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.palePeriwinkle),
        borderRadius: BorderRadius.circular(28),
        color: AppColors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < fields.length; i++) ...[
            FieldLine(
              index: i,
              field: fields[i],
              value: fields[i].value,
              valid: fields[i].options.type == ManualCustomFieldOptionType.file
                ? fields[i].file == null ? true : fields[i].isValidData
                : fields[i].value == null ? true : fields[i].isValid,
              onChanged: onChanged,
              uploadFile: uploadFile,
            ),
            if (i < fields.length - 1) SizedBox(height: 24),
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

