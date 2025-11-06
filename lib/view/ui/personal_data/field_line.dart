import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_representation_type.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_type.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_option_type.dart';
import 'package:dataspikemobilesdk/main/coordinator/coordinator.dart';
import 'package:file_picker/file_picker.dart';
import '/view/ui/personal_data/radio_view.dart';
import '/view/ui/personal_data/label.dart';
import '/view/ui/personal_data/caption_view.dart';
import 'package:dataspikemobilesdk/view/ui/loader.dart';

class FieldLine extends StatelessWidget {
  final int index;
  final ManualCustomFieldRepresentationModel field;
  final String? value;
  final bool valid;
  final void Function(int, String?) onChanged;
  final void Function(int index, PlatformFile file)? uploadFile;

  const FieldLine({super.key, 
    required this.index,
    required this.field,
    required this.value,
    required this.valid,
    required this.onChanged,
    this.uploadFile,
  });

  bool get isSelectChoices =>
      field.options.type == ManualCustomFieldOptionType.select;
  bool get isListPicker =>
      field.options.type == ManualCustomFieldOptionType.list;
  bool get isFileUpload =>
      field.options.type == ManualCustomFieldOptionType.file;

  @override
  Widget build(BuildContext context) {
    final borderColor = valid ? AppColors.palePeriwinkle : AppColors.lightRed;

    if (isFileUpload) {
      final hasFile = (value ?? '').isNotEmpty;
      final fileName = hasFile
          ? value!.split(RegExp(r'[\/\\]')).last
          : (field.placeholder ?? 'Select ${field.label.toLowerCase()}');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(text: field.label),
          if (field.caption?.isNotEmpty == true) ...[
            Caption(text: field.caption!),
          ],
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final type = field.options.attachmentTypePreset;
              FileType pickerType = FileType.custom;
              List<String>? allowed;

              if (type == 'image') {
                allowed = ['jpg', 'jpeg', 'png', 'heic', 'jpe'];
              } else if (type == 'video') {
                allowed =  ['mp4', 'mp4v', 'mpg4', 'mpeg', 'mpg', 'mpe', 'm1v', 'm2v'];
              } else if (type == 'document') {
                allowed = ['pdf'];
              } else if (type == 'image&document') {
                allowed = ['jpg', 'jpeg', 'png', 'heic', 'jpe', 'pdf'];
              } else {
                pickerType = FileType.any;
              }

              final rootNav = Navigator.of(context, rootNavigator: true);

              showDialog(
                context: context,
                useRootNavigator: true,
                barrierDismissible: false,
                barrierColor: AppColors.slateGray,
                builder: (_) => const Center(child: Loader()),
              );

              final res = await FilePicker.platform.pickFiles(
                type: pickerType,
                allowMultiple: false,
                allowedExtensions: allowed,
                withData: true,
              );

              rootNav.pop();

              final picked = res?.files.single;

              if (picked != null) {
                if (uploadFile != null) {
                  uploadFile!(index, picked);
                }
                onChanged(index, picked.path ?? '');
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 1.4),
                borderRadius: BorderRadius.circular(14),
                color: AppColors.white,
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      fileName,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w500,
                        color: hasFile ? AppColors.black : AppColors.darkIndigo,
                        package: 'dataspikemobilesdk',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasFile) ...[
                    GestureDetector(
                      onTap: () => onChanged(index, null),
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: AppColors.darkIndigo,
                        ),
                      ),
                    ),
                  ],
                  const Icon(
                    Icons.upload_file_rounded,
                    color: AppColors.darkIndigo,
                  ),
                ],
              ),
            ),
          ),
          if (hasFile) ...[
            const SizedBox(height: 6),
            if (valid)
              Text(
                'Selected: $fileName',
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 14,
                  color: AppColors.royalPurple,
                  package: 'dataspikemobilesdk',
                ),
              )
            else
              Text(
                'File size should be less than ${field.options.maxSize} bytes',
                style: const TextStyle(
                  fontFamily: 'Figtree',
                  fontSize: 14,
                  color: AppColors.lightRed,
                  package: 'dataspikemobilesdk',
                ),
              ),
          ],
        ],
      );
    }

    if (isListPicker) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Label(text: field.label),
          if (field.caption?.isNotEmpty == true) ...[
            Caption(text: field.caption!),
          ],
          const SizedBox(height: 8),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final picked = await DataspikeCoordinator.showCountryPicker(
                context,
                title: 'Please, choose your ${field.label.toLowerCase()}',
                onSelected: (country) => onChanged(index, country),
              );
              if (picked != null && picked.isNotEmpty) {
                onChanged(index, picked);
              }
            },
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 1.4),
                borderRadius: BorderRadius.circular(14),
                color: AppColors.white,
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value?.isNotEmpty == true
                          ? value!
                          : (field.placeholder ??
                                'Select ${field.label.toLowerCase()}'),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Figtree',
                        package: 'dataspikemobilesdk',
                        fontWeight: FontWeight.w500,
                        color: value?.isNotEmpty == true
                            ? AppColors.black
                            : AppColors.darkIndigo,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: AppColors.darkIndigo,
                  ),
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
          Label(text: field.label),
          if (field.caption?.isNotEmpty == true) ...[
            Caption(text: field.caption!),
          ],
          const SizedBox(height: 8),
          RadioChoices(
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
        Label(text: field.label),
        if (field.caption?.isNotEmpty == true) ...[
          Caption(text: field.caption!),
        ],
        const SizedBox(height: 8),
        TextField(
          keyboardType: _keyboardTypeFor(field.fieldType),
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            color: AppColors.darkIndigo,
            fontSize: 14,
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w500,
            package: 'dataspikemobilesdk',
          ),
          cursorColor: AppColors.royalPurple,
          decoration: InputDecoration(
            isDense: true,
            hintText: field.placeholder,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.darkIndigo,
              fontWeight: FontWeight.w400,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: borderColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
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
      default:
        return TextInputType.text;
    }
  }
}
