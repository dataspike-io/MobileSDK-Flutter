class CountryDomainModel {
  final String alphaTwo;
  final String alphaThree;
  final String name;
  final String continent;
  bool isSelected;

  CountryDomainModel({
    required this.alphaTwo,
    required this.alphaThree,
    required this.name,
    required this.continent,
    this.isSelected = false,
  });

  factory CountryDomainModel.fromJson(Map<String, dynamic> json) =>
      CountryDomainModel(
        alphaTwo: json['alphaTwo'] as String,
        alphaThree: json['alphaThree'] as String,
        name: json['name'] as String,
        continent: json['continent'] as String,
        isSelected: json['isSelected'] as bool? ?? false,
      );
}