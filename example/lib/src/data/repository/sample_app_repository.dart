import '../api/sample_api_service.dart';
import '../../domain/models/new_verification_state.dart';
import '../../domain/models/result.dart';
import '../../domain/mappers/new_verification_response_mapper.dart';

abstract class ISampleAppRepository {
  Future<NewVerificationState> createVerification();
}

class SampleAppRepositoryImpl implements ISampleAppRepository {
  final ISampleAppApiService apiService;
  final NewVerificationResponseMapper newVerificationResponseMapper;

  SampleAppRepositoryImpl({
    required this.apiService,
    required this.newVerificationResponseMapper,
  });

  @override
  Future<NewVerificationState> createVerification() async {
    try {
      final response = await apiService.createVerification({});
      return newVerificationResponseMapper.map(Result.success(response));
    } catch (e) {
      return newVerificationResponseMapper.map(Result.failure(e));
    }
  }
}