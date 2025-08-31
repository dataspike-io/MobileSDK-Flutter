import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/domain/models/manual_field_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/manual_custom_field_domain_model.dart';
import 'package:dataspikemobilesdk/domain/models/manual_field_settings_domain_model.dart';

class RenderableManualField {
  final ManualFieldDomainModel? standard;
  final ManualCustomFieldDomainModel? custom;
  RenderableManualField.standard(this.standard) : custom = null;
  RenderableManualField.custom(this.custom) : standard = null;

  bool get isCustom => custom != null;
  int get order => standard?.order ?? custom?.order ?? 0;
  String get caption =>
      (standard?.caption?.trim().isNotEmpty == true
          ? standard!.caption!
          : custom?.caption) ??
      '';
  bool get enabled => (standard?.enabled ?? true);
  bool get hasChoices =>
      (custom?.options?.choices?.isNotEmpty ?? false); 
  List<String> get choices => custom?.options?.choices ?? const [];
}

class PersonalDataViewModel extends ChangeNotifier {
  Duration? timerDuration;

  final List<ManualFieldDomainModel> enabledStandardFields = [];
  final List<ManualCustomFieldDomainModel> enabledCustomFields = [];

  PersonalDataViewModel() {
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
    enabledStandardFields.clear();
    enabledCustomFields.clear();

    final verificationManager = DataspikeInjector.component.verificationManager;
    final ManualFieldsSettingsDomainModel? manual =
        verificationManager.checks.manualFields;

    if (manual != null) {
      void addIfEnabled(ManualFieldDomainModel? f) {
        if (f != null && (f.enabled == true)) {
          enabledStandardFields.add(f);
        }
      }

      addIfEnabled(manual.fullName);
      addIfEnabled(manual.email);
      addIfEnabled(manual.phone);
      addIfEnabled(manual.country);
      addIfEnabled(manual.dob);
      addIfEnabled(manual.gender);
      addIfEnabled(manual.citizenship);
      addIfEnabled(manual.address);

      final custom = manual.customFields;
      if (custom != null) {
        for (final c in custom) {
          enabledCustomFields.add(c);
        }
      }
    }

    notifyListeners();
  }

  List<RenderableManualField> get orderedFields {
    final list = <RenderableManualField>[];
    for (final s in enabledStandardFields) {
      list.add(RenderableManualField.standard(s));
    }
    for (final c in enabledCustomFields) {
      list.add(RenderableManualField.custom(c));
    }
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }
}
