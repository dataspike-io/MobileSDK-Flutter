import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/data/use_cases/set_profile_use_case.dart';
import 'package:dataspikemobilesdk/data/models/request/profile_fields_request_body.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_representation_type.dart';

class PersonalDataViewModel extends ChangeNotifier {
  Duration? timerDuration;
  
  List<ManualCustomFieldRepresentationModel> personalDataFields = [];
  final SetProfileUseCase _setProfileUseCase;

  PersonalDataViewModel({required SetProfileUseCase setProfileUseCase})
    : _setProfileUseCase = setProfileUseCase {
    setVerificationTimer();
    setStages();
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
    notifyListeners();
  }

  void submitProfileData(Map<String, String> payload) async {
    final fields = ProfileFieldsRequestBody(
      fullName: "Mikhail Tiranov",
      email: "mikhail.tiranov@mail.com",
      phone: "+381601234567",
      country: "Serbia",
      dob: "1990-01-01",
      gender: "M",
      citizenship: "Serbia",
      address: "LENINGRAD SPB TOCHKA RU",
      customFields: {
        "Custom1": "Value 1",
        "Custom2": "Option1",
        // "Custom3": "FILE", FIX LATER FOR CAMERA
      }, // TODO: custom fields (если нужно
    );
    await _setProfileUseCase.call(fields);
  }
}
