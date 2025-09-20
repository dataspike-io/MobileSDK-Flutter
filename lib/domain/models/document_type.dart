enum DocumentType { identity, address }

extension DocumentTypeX on DocumentType {
  String get value {
    switch (this) {
      case DocumentType.identity:
        return 'poi';
      case DocumentType.address:
        return 'poa';
    }
  }
}