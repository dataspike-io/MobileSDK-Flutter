enum DocumentType { identity, address }

extension DocumentTypeX on DocumentType {
  String get value {
    switch (this) {
      case DocumentType.identity:
        return 'poa';
      case DocumentType.address:
        return 'residence_permit';
    }
  }
}