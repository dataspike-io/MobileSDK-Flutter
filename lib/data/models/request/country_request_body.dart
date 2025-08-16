class CountryRequestBody {
  final String country;

  CountryRequestBody({required this.country});

  Map<String, dynamic> toJson() => {
    'country': country,
  };
}