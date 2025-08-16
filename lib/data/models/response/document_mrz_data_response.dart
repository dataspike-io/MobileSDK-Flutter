class DocumentMrzDataResponse {
  final String? documentType;
  final String? country;
  final String? name;
  final String? surname;
  final String? docNumber;
  final String? nationality;
  final String? birthDate;
  final String? sex;
  final String? expiryDate;

  DocumentMrzDataResponse({
    this.documentType,
    this.country,
    this.name,
    this.surname,
    this.docNumber,
    this.nationality,
    this.birthDate,
    this.sex,
    this.expiryDate,
  });

  factory DocumentMrzDataResponse.fromJson(Map<String, dynamic> json) =>
      DocumentMrzDataResponse(
        documentType: json['document_type'] as String?,
        country: json['country'] as String?,
        name: json['name'] as String?,
        surname: json['surname'] as String?,
        docNumber: json['doc_number'] as String?,
        nationality: json['nationality'] as String?,
        birthDate: json['birth_date'] as String?,
        sex: json['sex'] as String?,
        expiryDate: json['expiry_date'] as String?,
      );
}