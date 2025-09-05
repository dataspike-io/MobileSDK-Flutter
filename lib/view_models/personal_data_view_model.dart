import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/data/use_cases/set_profile_use_case.dart';
import 'package:dataspikemobilesdk/data/models/request/profile_fields_request_body.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_representation_type.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_type.dart';

class PersonalDataViewModel extends ChangeNotifier {
  Duration? timerDuration;
  
  List<ManualCustomFieldRepresentationModel> personalDataFields = [];
  String? description;
  final SetProfileUseCase _setProfileUseCase;

  PersonalDataViewModel({required SetProfileUseCase setProfileUseCase})
    : _setProfileUseCase = setProfileUseCase {
    setVerificationTimer();
    setStages();
  }

  bool get isContinueButtonDisabled {
    if (personalDataFields.isEmpty) return true;
    return personalDataFields.any(
      (f) => f.value == null || f.value!.trim().isEmpty || !f.isValid,
    );
  }

  void setVerificationTimer() {
    final verificationManager = DataspikeInjector.component.verificationManager;
    final millisecondsUntilVerificationExpired =
        verificationManager.millisecondsUntilVerificationExpired;
    timerDuration = Duration(
      milliseconds: millisecondsUntilVerificationExpired,
    );
    notifyListeners();
  }

  void setStages() {
    personalDataFields.clear();
    personalDataFields = _setProfileUseCase.getFields();
    description = _setProfileUseCase.description;
    notifyListeners();
  }

  void submitProfileData() async {
    if (isContinueButtonDisabled) return;
    final body = _buildRequestBody();
    await _setProfileUseCase.call(body);
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
          final key = f.caption.isNotEmpty == true
              ? f.caption
              : 'custom_${f.order}';
          custom[key] = raw;
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

  String _normalizeGender(String g) {
    final lower = g.toLowerCase();
    if (lower.startsWith('m')) return 'M';
    if (lower.startsWith('f')) return 'F';
    return g;
  }
}
