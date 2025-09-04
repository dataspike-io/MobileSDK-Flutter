enum ManualCustomFieldOptionType {
  select,
  file,
  image,
  video,
  document,
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
      case 'image':
        return ManualCustomFieldOptionType.image;
      case 'video':
        return ManualCustomFieldOptionType.video;
      case 'document':
        return ManualCustomFieldOptionType.document;
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
      case ManualCustomFieldOptionType.image:
        return 'image';
      case ManualCustomFieldOptionType.video:
        return 'video';
      case ManualCustomFieldOptionType.document:
        return 'document';
    }
  }
}