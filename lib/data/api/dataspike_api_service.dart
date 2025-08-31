import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dataspikemobilesdk/data/models/response/verification_response.dart';
import 'package:dataspikemobilesdk/data/models/response/upload_image_response.dart';
import 'package:dataspikemobilesdk/data/models/response/dataspike_empty_response.dart';
import 'package:dataspikemobilesdk/data/models/request/country_request_body.dart';
import 'package:dataspikemobilesdk/data/models/response/country_response.dart';
import 'package:dataspikemobilesdk/data/models/response/proceed_with_verification_response.dart';
import 'package:dataspikemobilesdk/data/api/dataspike_endpoint.dart';
import 'package:dataspikemobilesdk/data/models/response/upload_image_error_response.dart';
import 'package:dataspikemobilesdk/data/models/response/dataspike_profile_fields_response.dart';

abstract class IDataspikeApiService {
  Future<VerificationResponse> getVerification(String shortId);
  Future<UploadImageResponse> uploadImage(
    String shortId,
    String documentType,
    List<int> fileBytes,
    String fileName,
  );
  Future<DataspikeEmptyResponse> setCountry(
    String shortId,
    CountryRequestBody body,
  );
  Future<List<CountryResponse>> getCountries();
  Future<ProceedWithVerificationResponse> proceedWithVerification(String shortId);
  Future<DataspikeProfileFieldsResponse> setProfileFields(String shortId);
}

class DataspikeApiServiceImpl implements IDataspikeApiService {
  final String baseUrl;
  final String apiToken;

  DataspikeApiServiceImpl({
    required this.baseUrl,
    required this.apiToken,
  });

  @override
  Future<VerificationResponse> getVerification(String shortId) async {
    final url = Uri.parse('$baseUrl${DataspikeEndpoint.getVerification.path(shortId: shortId)}');
    final headers = DataspikeEndpoint.getVerification.headers(apiToken);

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      return VerificationResponse.fromJson(jsonBody);
    } else {
      throw Exception('Failed to load verification: ${response.statusCode}');
    }
  }

  @override
  Future<UploadImageResponse> uploadImage(
    String shortId,
    String documentType,
    List<int> fileBytes,
    String fileName,
  ) async {
    final url = Uri.parse('$baseUrl${DataspikeEndpoint.uploadImage.path(shortId: shortId)}');
    final headers = DataspikeEndpoint.uploadImage.headers(apiToken);

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..fields['document_type'] = documentType;

    if (fileBytes.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      return UploadImageResponse.fromJson(jsonBody);
    } else {
      try {
        final errorJson = json.decode(response.body) as Map<String, dynamic>;
        final errorResponse = UploadImageErrorResponse.fromJson(errorJson);
        throw errorResponse; 
      } catch (_) {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    }
  }

  @override
  Future<DataspikeEmptyResponse> setCountry(
    String shortId,
    CountryRequestBody body,
  ) async {
    final url = Uri.parse('$baseUrl${DataspikeEndpoint.setCountry.path(shortId: shortId)}');
    final headers = DataspikeEndpoint.setCountry.headers(apiToken);

    final response = await http.post(
      url,
      headers: headers,
      body: json.encode(body.toJson()),
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      return DataspikeEmptyResponse.fromJson(jsonBody);
    } else {
      throw Exception('Failed to set country: ${response.statusCode}');
    }
  }

  @override
  Future<List<CountryResponse>> getCountries() async {
    final url = Uri.parse('$baseUrl${DataspikeEndpoint.getCountries.path()}');
    final headers = DataspikeEndpoint.getCountries.headers(apiToken);

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body) as List<dynamic>;
      return jsonBody
          .map((e) => CountryResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }

  @override
  Future<ProceedWithVerificationResponse> proceedWithVerification(String shortId) async {
    final url = Uri.parse('$baseUrl${DataspikeEndpoint.proceedWithVerification.path(shortId: shortId)}');
    final headers = DataspikeEndpoint.proceedWithVerification.headers(apiToken);

    final response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      return ProceedWithVerificationResponse.fromJson(jsonBody);
    } else {
      throw Exception('Failed to proceed with verification: ${response.statusCode}');
    }
  }

  @override
  Future<DataspikeProfileFieldsResponse> setProfileFields(String shortId) async {
    final url = Uri.parse('$baseUrl${DataspikeEndpoint.setProfileFields.path(shortId: shortId)}');
    final headers = DataspikeEndpoint.setProfileFields.headers(apiToken);

    final response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      return DataspikeProfileFieldsResponse.fromJson(jsonBody);
    } else {
      throw Exception('Failed to set profile fields: ${response.statusCode}');
    }
  }
}