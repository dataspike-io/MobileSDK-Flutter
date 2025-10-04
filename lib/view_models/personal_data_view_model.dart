import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/data/use_cases/set_profile_use_case.dart';
import 'package:dataspikemobilesdk/data/models/request/profile_fields_request_body.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_representation_type.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_type.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_option_type.dart';
import 'dart:convert';
import 'package:dataspikemobilesdk/domain/models/states/message_state.dart';

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
          country = raw;
          break;
        case ManualCustomFieldType.dob:
          dob = raw;
          break;
        case ManualCustomFieldType.gender:
          gender = _normalizeGender(raw);
          break;
        case ManualCustomFieldType.citizenship:
          citizenship = raw;
          break;
        case ManualCustomFieldType.address:
          address = raw;
          break;
        case ManualCustomFieldType.custom:
          final key = f.label.isNotEmpty == true
              ? f.label
              : 'custom_${f.order}';

          if (f.options.type == ManualCustomFieldOptionType.file) {
            if (f.file?.bytes != null) {
              final mime = _mimeFromExt(f.file!.extension);
              final b64 = base64Encode(f.file!.bytes!);
              custom[key] =
                  'data:$mime;base64,$b64'; // TODO: CHANGE IF WILL BE NEEDED
            }
          } else {
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

  String _mimeFromExt(String? ext) {
    switch ((ext ?? '').toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg'; // FROM SERVER
      case 'heif':
        return 'image/heif';
      case 'png':
        return 'image/png'; // FROM SERVER
      case 'mp4':
        return 'video/mp4'; // FROM SERVER
      case 'mpeg':
        return 'video/mpeg'; // FROM SERVER
      case 'pdf':
        return 'application/pdf'; // FROM SERVER
      default:
        return 'application/octet-stream'; // generic binary data
    }
  }

  String _normalizeGender(String g) {
    final lower = g.toLowerCase();
    if (lower.startsWith('m')) return 'M';
    if (lower.startsWith('f')) return 'F';
    return g;
  }
}
