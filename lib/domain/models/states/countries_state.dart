import '../country_domain_model.dart';

abstract class CountriesState {}

class CountriesSuccess extends CountriesState {
  final List<CountryDomainModel> countries;

  CountriesSuccess({required this.countries});
}

class CountriesError extends CountriesState {
  final String message;

  CountriesError({required this.message});
}