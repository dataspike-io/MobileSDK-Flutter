import 'package:dataspikemobilesdk/domain/models/states/message_state.dart';
import 'package:dataspikemobilesdk/domain/models/states/verification_state.dart';
import 'package:dataspikemobilesdk/domain/models/states/upload_image_state.dart';
import 'package:dataspikemobilesdk/domain/models/states/countries_state.dart';
import 'package:dataspikemobilesdk/domain/models/states/empty_state.dart';
import 'package:dataspikemobilesdk/domain/models/states/proceed_with_verification_state.dart';
import 'package:dataspikemobilesdk/data/api/dataspike_api_service.dart';
import 'package:dataspikemobilesdk/domain/mappers/verification_response_mapper.dart';
import 'package:dataspikemobilesdk/domain/mappers/upload_image_response_mapper.dart';
import 'package:dataspikemobilesdk/domain/mappers/countries_response_mapper.dart';
import 'package:dataspikemobilesdk/domain/mappers/empty_response_mapper.dart';
import 'package:dataspikemobilesdk/domain/mappers/proceed_with_verification_response_mapper.dart';
import 'package:dataspikemobilesdk/data/models/request/country_request_body.dart';
import 'package:dataspikemobilesdk/data/models/request/profile_fields_request_body.dart';
import 'package:dataspikemobilesdk/domain/mappers/message_response_mapper.dart';

abstract class IDataspikeRepository {
  Future<VerificationState> getVerification({required bool darkModeIsEnabled});
  Future<UploadImageState> uploadImage({
    required String documentType,
    required List<int> imageBytes,
    required String fileName,
  });
  Future<CountriesState> getCountries();
  Future<EmptyState> setCountry({required CountryRequestBody body});
  Future<ProceedWithVerificationState> proceedWithVerification();
  Future<MessageState> setProfileFields(ProfileFieldsRequestBody body);
}

class DataspikeRepositoryImpl implements IDataspikeRepository {
  final IDataspikeApiService apiService;
  final String shortId;
  final VerificationResponseMapper verificationResponseMapper;
  final UploadImageResponseMapper uploadImageResponseMapper;
  final CountriesResponseMapper countriesResponseMapper;
  final EmptyResponseMapper emptyResponseMapper;
  final ProceedWithVerificationResponseMapper proceedWithVerificationResponseMapper;
  final MessageResponseMapper messageResponseMapper;

  DataspikeRepositoryImpl({
    required this.apiService,
    required this.shortId,
    required this.verificationResponseMapper,
    required this.uploadImageResponseMapper,
    required this.countriesResponseMapper,
    required this.emptyResponseMapper,
    required this.proceedWithVerificationResponseMapper,
    required this.messageResponseMapper,
  });

  @override
  Future<VerificationState> getVerification({required bool darkModeIsEnabled}) async {
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

  @override
  Future<UploadImageState> uploadImage({
    required String documentType,
    required List<int> imageBytes,
    required String fileName,
  }) async {
    try {
      final response = await apiService.uploadImage(shortId, documentType, imageBytes, fileName);
      return uploadImageResponseMapper.map(response: response, error: null);
    } catch (e) {
      return uploadImageResponseMapper.map(response: null, error: e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<CountriesState> getCountries() async {
    try {
      final response = await apiService.getCountries();
      return countriesResponseMapper.map(response: response, error: null);
    } catch (e) {
      return countriesResponseMapper.map(response: null, error: e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<EmptyState> setCountry({required CountryRequestBody body}) async {
    try {
      final response = await apiService.setCountry(shortId, body);
      return emptyResponseMapper.map(response: response, error: null);
    } catch (e) {
      return emptyResponseMapper.map(response: null, error: e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<ProceedWithVerificationState> proceedWithVerification() async {
    try {
      final response = await apiService.proceedWithVerification(shortId);
      return proceedWithVerificationResponseMapper.map(response: response, error: null);
    } catch (e) {
      return proceedWithVerificationResponseMapper.map(response: null, error: e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<MessageState> setProfileFields(ProfileFieldsRequestBody body) async {
    try {
      final response = await apiService.setProfileFields(shortId, body);
      return messageResponseMapper.map(response: response, error: null);
    } catch (e) {
      return messageResponseMapper.map(response: null, error: e is Exception ? e : Exception(e.toString()));
    }
  }
}