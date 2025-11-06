import '../models/manual_field_settings_domain_model.dart';
import '../models/manual_custom_field_domain_model.dart';
import '../models/manual_custom_field_option_type.dart';
import '../models/manual_custom_field_type.dart';
import '../models/manual_custom_field_option_domain_model.dart';
import '../models/manual_custom_representation_type.dart';

class PersonalDataManager {
  List<ManualCustomFieldRepresentationModel> getPersonalDataFields(
    ManualFieldsSettingsDomainModel? manualFields,
  ) {
    if (manualFields == null || !manualFields.enabled) return const [];

    final result = <ManualCustomFieldRepresentationModel>[];

    addFullNameIfRequired(result, manualFields);
    addEmailIfRequired(result, manualFields);
    addPhoneIfRequired(result, manualFields);
    addCountryIfRequired(result, manualFields);
    addDobIfRequired(result, manualFields);
    addGenderIfRequired(result, manualFields);
    addCitizenshipIfRequired(result, manualFields);
    addAddressIfRequired(result, manualFields);
    addCertificateOfIncorporationIfRequired(result, manualFields);
    addOwnershipDocumentIfRequired(result, manualFields);

    addCustomFieldsIfRequired(result, manualFields.customFields);

    result.sort((a, b) => (a.order).compareTo(b.order));
    return result;
  }

  void addFullNameIfRequired(List<ManualCustomFieldRepresentationModel> target, ManualFieldsSettingsDomainModel fields) {
    final f = fields.fullName;
    if (f == null || !f.enabled || f.order == null) return;
    target.add(ManualCustomFieldRepresentationModel(
      label: 'Full name',
      order: f.order ?? 0,
      options: ManualCustomFieldOptionsDomainModel(type: ManualCustomFieldOptionType.text),
      fieldType: ManualCustomFieldType.fullName,
    ));
  }

  void addEmailIfRequired(List<ManualCustomFieldRepresentationModel> target, ManualFieldsSettingsDomainModel fields) {
    final f = fields.email;
    if (f == null || !f.enabled || f.order == null) return;
    target.add(ManualCustomFieldRepresentationModel(
      label: 'Email',
      order: f.order ?? 0,
      validation: r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
      options: ManualCustomFieldOptionsDomainModel(type: ManualCustomFieldOptionType.text),
      fieldType: ManualCustomFieldType.email,
    ));
  }

  void addPhoneIfRequired(List<ManualCustomFieldRepresentationModel> target, ManualFieldsSettingsDomainModel fields) {
    final f = fields.phone;
    if (f == null || !f.enabled || f.order == null) return;
    target.add(ManualCustomFieldRepresentationModel(
      label: 'Phone',
      order: f.order ?? 0,
      validation: r'^\+?[0-9\s\-()]{7,15}$',
      options: ManualCustomFieldOptionsDomainModel(type: ManualCustomFieldOptionType.text),
      fieldType: ManualCustomFieldType.phone,
    ));
  }

  void addCountryIfRequired(List<ManualCustomFieldRepresentationModel> target, ManualFieldsSettingsDomainModel fields) {
    final f = fields.country;
    if (f == null || !f.enabled || f.order == null) return;
    target.add(ManualCustomFieldRepresentationModel(
      label: 'Country',
      order: f.order ?? 0,
      options: ManualCustomFieldOptionsDomainModel(
        type: ManualCustomFieldOptionType.list,
      ),
      fieldType: ManualCustomFieldType.country,
    ));
  }

  void addDobIfRequired(List<ManualCustomFieldRepresentationModel> target, ManualFieldsSettingsDomainModel fields) {
    final f = fields.dob;
    if (f == null || !f.enabled || f.order == null) return;
    target.add(ManualCustomFieldRepresentationModel(
      label: 'Date of birth',
      order: f.order ?? 0,
      validation: r'^\d{4}-\d{2}-\d{2}$',
      placeholder: 'yyyy-MM-dd',
      options: ManualCustomFieldOptionsDomainModel(type: ManualCustomFieldOptionType.text),
      fieldType: ManualCustomFieldType.dob,
    ));
  }

  void addGenderIfRequired(List<ManualCustomFieldRepresentationModel> target, ManualFieldsSettingsDomainModel fields) {
    final f = fields.gender;
    if (f == null || !f.enabled || f.order == null) return;
    target.add(ManualCustomFieldRepresentationModel(
      label: 'Choose your gender',
      caption: 'Like in passport or ID',
      order: f.order ?? 0,
      options: ManualCustomFieldOptionsDomainModel(
        type: ManualCustomFieldOptionType.select,
        choices: [
          'Male',
          'Female',
        ],
      ),
      fieldType: ManualCustomFieldType.gender,
    ));
  }

  void addCitizenshipIfRequired(List<ManualCustomFieldRepresentationModel> target, ManualFieldsSettingsDomainModel fields) {
    final f = fields.citizenship;
    if (f == null || !f.enabled || f.order == null) return;
    target.add(ManualCustomFieldRepresentationModel(
      label: 'Citizenship',
      order: f.order ?? 0,
      options: ManualCustomFieldOptionsDomainModel(
        type: ManualCustomFieldOptionType.list,
      ),
      fieldType: ManualCustomFieldType.citizenship,
    ));
  }

  void addAddressIfRequired(List<ManualCustomFieldRepresentationModel> target, ManualFieldsSettingsDomainModel fields) {
    final f = fields.address;
    if (f == null || !f.enabled || f.order == null) return;
    target.add(ManualCustomFieldRepresentationModel(
      label: 'Address',
      order: f.order ?? 0,
      options: ManualCustomFieldOptionsDomainModel(type: ManualCustomFieldOptionType.text),
      fieldType: ManualCustomFieldType.address,
    ));
  }

  void addCertificateOfIncorporationIfRequired(List<ManualCustomFieldRepresentationModel> target, ManualFieldsSettingsDomainModel fields) {
    final f = fields.certificateOfIncorporation;
    if (f == null || !f.enabled || f.order == null) return;
    target.add(ManualCustomFieldRepresentationModel(
      label: 'Certificate of Incorporation',
      order: f.order ?? 0,
      options: ManualCustomFieldOptionsDomainModel(
        type: ManualCustomFieldOptionType.file,
        attachmentTypePreset: 'image&document',
        allowedMimeTypes: ['image/jpeg', 'image/png', 'application/pdf'],
      ),
      fieldType: ManualCustomFieldType.certificateOfIncorporation,
    ));
  }

  void addOwnershipDocumentIfRequired(List<ManualCustomFieldRepresentationModel> target, ManualFieldsSettingsDomainModel fields) {
    final f = fields.ownershipDocument;
    if (f == null || !f.enabled || f.order == null) return;
    target.add(ManualCustomFieldRepresentationModel(
      label: 'Ownership Document',
      order: f.order ?? 0,
      options: ManualCustomFieldOptionsDomainModel(
        type: ManualCustomFieldOptionType.file,
        attachmentTypePreset: 'image&document',
        allowedMimeTypes: ['image/jpeg', 'image/png', 'application/pdf'],
      ),
      fieldType: ManualCustomFieldType.ownershipDocument,
    ));
  }

  void addCustomFieldsIfRequired(
    List<ManualCustomFieldRepresentationModel> target,
    List<ManualCustomFieldDomainModel>? custom,
  ) {
    if (custom == null || custom.isEmpty) return;

    for (final customField in custom) {
      if (customField.order == null) continue;

      target.add(
        ManualCustomFieldRepresentationModel(
          label: customField.label ?? 'Custom field',
          caption: customField.caption,
          order: customField.order ?? 0,
          options: customField.options ?? ManualCustomFieldOptionsDomainModel(type: ManualCustomFieldOptionType.text),
          fieldType: ManualCustomFieldType.custom,
        ),
      );
    }
  }
}