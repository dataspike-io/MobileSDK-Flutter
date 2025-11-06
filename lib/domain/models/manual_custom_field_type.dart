enum ManualCustomFieldType {
  fullName,
  email,
  phone,
  country,
  dob,
  gender,
  citizenship,
  address,
  certificateOfIncorporation,
  ownershipDocument,
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
      case ManualCustomFieldType.certificateOfIncorporation:
        return 'kyb_certificate_of_incorporation';
      case ManualCustomFieldType.ownershipDocument:
        return 'kyb_ownership_document';
      case ManualCustomFieldType.custom:
        return 'custom';
    }
  }
}