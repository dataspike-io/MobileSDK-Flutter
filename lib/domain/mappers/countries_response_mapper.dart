import 'package:dataspikemobilesdk/data/models/response/country_response.dart';
import 'package:dataspikemobilesdk/domain/models/states/countries_state.dart';
import 'package:dataspikemobilesdk/domain/models/country_domatin_model.dart';

class CountriesResponseMapper {
  CountriesState map({
    List<CountryResponse>? response,
    Exception? error,
  }) {
    if (response != null) {
      return CountriesSuccess(
        countries: response.map((countryResponse) {
          return CountryDomainModel(
            alphaTwo: countryResponse.alphaTwo?.toLowerCase() ?? "",
            alphaThree: countryResponse.alphaThree ?? "",
            name: countryResponse.name ?? "",
            continent: countryResponse.continent ?? "",
          );
        }).toList(),
      );
    } else if (error != null) {
      String message = error.toString();
      // Можно добавить парсинг ошибки, если есть структура
      return CountriesError(message: message);
    } else {
      return CountriesError(message: "Unknown error occurred");
    }
  }
}