import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/data/use_cases/set_profile_use_case.dart';
import 'package:dataspikemobilesdk/data/models/request/profile_fields_request_body.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_representation_type.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_type.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_option_type.dart';
import 'package:dataspikemobilesdk/domain/models/states/message_state.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_manual_file_state.dart';

class PersonalDataViewModel extends ChangeNotifier {
  List<ManualCustomFieldRepresentationModel> personalDataFields = [];
  final SetProfileUseCase _setProfileUseCase;

  PersonalDataViewModel({required SetProfileUseCase setProfileUseCase})
    : _setProfileUseCase = setProfileUseCase {
    setStages();
  }

  bool get isContinueButtonDisabled {
    if (personalDataFields.isEmpty) return true;
    return personalDataFields.any(
      (f) =>
          f.value == null ||
          f.value!.trim().isEmpty ||
          !f.isValid ||
          !f.isValidData,
    );
  }

  void setStages() {
    personalDataFields.clear();
    personalDataFields = _setProfileUseCase.getFields();
    notifyListeners();
  }

  void submitProfileData() async {
    if (isContinueButtonDisabled) return;
    final body = _buildRequestBody();
    await _uploadAllCustomFields();
    await _uploadAllPredefinedFields();
    final result = await _setProfileUseCase.call(body);
    if (result is! MessageStateSuccess) {
      throw Exception('Failed to submit profile data');
    }
  }

  ProfileFieldsRequestBody _buildRequestBody() {
    String? fullName;
    String? email;
    String? phone;
    String? country;
    String? dob;
    String? gender;
    String? citizenship;
    String? address;
    final Map<String, String> custom = {};

    for (final f in personalDataFields) {
      final raw = f.value?.trim();
      if (raw == null || raw.isEmpty) continue;
      switch (f.fieldType) {
        case ManualCustomFieldType.fullName:
          fullName = raw;
          break;
        case ManualCustomFieldType.email:
          email = raw;
          break;
        case ManualCustomFieldType.phone:
          phone = raw;
          break;
        case ManualCustomFieldType.country:
          country = _getCountry(raw);
          break;
        case ManualCustomFieldType.dob:
          dob = raw;
          break;
        case ManualCustomFieldType.gender:
          gender = _normalizeGender(raw);
          break;
        case ManualCustomFieldType.citizenship:
          citizenship = _getCountry(raw);
          break;
        case ManualCustomFieldType.address:
          address = raw;
          break;
        case ManualCustomFieldType.certificateOfIncorporation:
        case ManualCustomFieldType.ownershipDocument:
          break;
        case ManualCustomFieldType.custom:
          final key = f.label.isNotEmpty == true
              ? f.label
              : 'custom_${f.order}';

          if (f.options.type != ManualCustomFieldOptionType.file) {
            custom[key] = raw;
          }

          break;
      }
    }

    return ProfileFieldsRequestBody(
      fullName: fullName,
      email: email,
      phone: phone,
      country: country,
      dob: dob,
      gender: gender,
      citizenship: citizenship,
      address: address,
      customFields: custom.isEmpty ? null : custom,
    );
  }

  Future<void> _uploadAllCustomFields() async {
    for (final f in personalDataFields) {
      if (f.fieldType == ManualCustomFieldType.custom &&
          f.options.type == ManualCustomFieldOptionType.file &&
          f.file != null) {
        final bytes = f.file?.bytes;
        final fileName = f.file?.name ?? 'custom_${f.order}';
        final type = (f.label.isNotEmpty ? f.label : 'custom_${f.order}');

        try {
          final state = await _setProfileUseCase.uploadManualFile(
            type: type,
            imageBytes: bytes ?? [],
            ext: f.file?.extension ?? '',
            fileName: fileName,
          );

          if (state is! UploadManualFileStateSuccess) {
            throw Exception('Upload failed for $fileName');
          }
        } catch (e) {
          throw Exception('Upload failed for $fileName: $e');
        }
      }
    }
  }

  Future<void> _uploadAllPredefinedFields() async {
    for (final f in personalDataFields) {
      switch (f.fieldType) {
        case ManualCustomFieldType.certificateOfIncorporation:
        case ManualCustomFieldType.ownershipDocument:
          if (f.file != null) {
            final bytes = f.file?.bytes;
            final fileName = f.file?.name ?? 'custom_${f.order}';
            final ext = f.file?.extension ?? '';
            final type = f.fieldType.raw;

            try {
              final state = await _setProfileUseCase.uploadImage(
                documentType: type,
                imageBytes: bytes ?? [],
                ext: ext,
                fileName: fileName,
              );

              if (state is! UploadImageSuccess) {
                throw Exception('Upload failed for $fileName');
              }
            } catch (e) {
              throw Exception('Upload failed for $fileName: $e');
            }
          }
        default:
          continue;
      }
    }
  }

  String _normalizeGender(String g) {
    final lower = g.toLowerCase();
    if (lower.startsWith('m')) return 'M';
    if (lower.startsWith('f')) return 'F';
    return g;
  }

  String _getCountry(String rawValue) {
    final countries = DataspikeInjector.component.verificationManager.countries;

    final i = countries.indexWhere(
      (c) => c.name.toLowerCase() == rawValue.trim().toLowerCase(),
    );

    return i == -1 ? rawValue : countries[i].alphaTwo;
  }
}
