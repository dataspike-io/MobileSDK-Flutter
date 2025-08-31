enum ManualCustomFieldOptionType {
  select,
  file,
  text;

  static ManualCustomFieldOptionType fromRaw(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'select':
        return ManualCustomFieldOptionType.select;
      case 'file':
        return ManualCustomFieldOptionType.file;
      case 'text':
        return ManualCustomFieldOptionType.text;
      default:
        return ManualCustomFieldOptionType.text;
    }
  }

  String get raw {
    switch (this) {
      case ManualCustomFieldOptionType.select:
        return 'select';
      case ManualCustomFieldOptionType.file:
        return 'file';
      case ManualCustomFieldOptionType.text:
        return 'text';
    }
  }
}