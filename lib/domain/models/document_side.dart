enum DocumentSide { 
  front,
  back;
   
   static DocumentSide fromRaw(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'front':
        return DocumentSide.front;
      case 'back':
        return DocumentSide.back;
      default:
        return DocumentSide.front;
    }
  }
}