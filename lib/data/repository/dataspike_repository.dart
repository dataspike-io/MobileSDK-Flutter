import 'package:dataspikemobilesdk/domain/models/verification_state.dart';
import 'package:dataspikemobilesdk/data/api/dataspike_api_service.dart';
import 'package:dataspikemobilesdk/domain/mappers/verification_response_mapper.dart';

abstract class IDataspikeRepository {
  Future<VerificationState> getVerification({required bool darkModeIsEnabled});
}

class DataspikeRepositoryImpl implements IDataspikeRepository {
  final IDataspikeApiService apiService;
  final String shortId;
  final VerificationResponseMapper verificationResponseMapper;

  DataspikeRepositoryImpl({
    required this.apiService,
    required this.shortId,
    required this.verificationResponseMapper,
  });

  @override
  Future<VerificationState> getVerification({
    required bool darkModeIsEnabled,
  }) async {
    try {
      final response = await apiService.getVerification(shortId);
      return verificationResponseMapper.map(
        response: response,
        error: null,
        darkModeIsEnabled: darkModeIsEnabled,
      );
    } catch (e) {
      return verificationResponseMapper.map(
        response: null,
        error: e is Exception ? e : Exception(e.toString()),
        darkModeIsEnabled: darkModeIsEnabled,
      );
    }
  }
}
