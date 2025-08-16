import 'package:dataspikemobilesdk/data/repository/dataspike_repository.dart';
import 'package:dataspikemobilesdk/domain/models/states/empty_state.dart';
import 'package:dataspikemobilesdk/data/models/request/country_request_body.dart';

class SetCountryUseCase {
  final IDataspikeRepository dataspikeRepository;

  SetCountryUseCase({
    required this.dataspikeRepository,
  });

  Future<EmptyState> call(CountryRequestBody body) async {
    return await dataspikeRepository.setCountry(body: body);
  }
}