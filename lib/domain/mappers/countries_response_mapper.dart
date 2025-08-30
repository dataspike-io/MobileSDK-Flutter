import 'package:dataspikemobilesdk/data/models/response/country_response.dart';
import 'package:dataspikemobilesdk/domain/models/states/countries_state.dart';
import 'package:dataspikemobilesdk/domain/models/country_domain_model.dart';

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
      return CountriesError(message: message);
    } else {
      return CountriesError(message: "Unknown error occurred");
    }
  }
}