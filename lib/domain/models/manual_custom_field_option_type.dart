enum ManualCustomFieldOptionType {
  select,
  file,
  list,
  text;

  static ManualCustomFieldOptionType fromRaw(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'select':
        return ManualCustomFieldOptionType.select;
      case 'file':
        return ManualCustomFieldOptionType.file;
      case 'text':
        return ManualCustomFieldOptionType.text;
      case 'list':
        return ManualCustomFieldOptionType.list;
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
      case ManualCustomFieldOptionType.list:
        return 'list';
    }
  }
}