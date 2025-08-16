class CountryResponse {
  final String? alphaTwo;
  final String? alphaThree;
  final String? name;
  final String? continent;

  CountryResponse({
    this.alphaTwo,
    this.alphaThree,
    this.name,
    this.continent,
  });

  factory CountryResponse.fromJson(Map<String, dynamic> json) => CountryResponse(
    alphaTwo: json['alpha_2'] as String?,
    alphaThree: json['alpha_3'] as String?,
    name: json['name'] as String?,
    continent: json['continent'] as String?,
  );
}