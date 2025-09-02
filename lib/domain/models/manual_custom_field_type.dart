enum ManualCustomFieldType {
  fullName,
  email,
  phone,
  country,
  dob,
  gender,
  citizenship,
  address,
  custom;

  String get raw {
    switch (this) {
      case ManualCustomFieldType.fullName:
        return 'full_name';
      case ManualCustomFieldType.email:
        return 'email';
      case ManualCustomFieldType.phone:
        return 'phone';
      case ManualCustomFieldType.country:
        return 'country';
      case ManualCustomFieldType.dob:
        return 'dob';
      case ManualCustomFieldType.gender:
        return 'gender';
      case ManualCustomFieldType.citizenship:
        return 'citizenship';
      case ManualCustomFieldType.address:
        return 'address';
      case ManualCustomFieldType.custom:
        return 'custom';
    }
  }
}