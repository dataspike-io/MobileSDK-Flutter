import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/domain/models/states/countries_state.dart';

class GetCountriesUseCase {
  final IDataspikeRepository dataspikeRepository;

  GetCountriesUseCase({
    required this.dataspikeRepository,
  });

  Future<CountriesState> call() async {
    return await dataspikeRepository.getCountries();
  }
}