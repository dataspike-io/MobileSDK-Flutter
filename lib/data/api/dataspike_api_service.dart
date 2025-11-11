import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dataspikemobilesdk/data/models/response/proceed_with_verification_error_response.dart';
import 'package:http/http.dart' as http;
import 'package:dataspikemobilesdk/data/models/response/verification_response.dart';
import 'package:dataspikemobilesdk/data/models/response/upload_image_response.dart';
import 'package:dataspikemobilesdk/data/models/response/upload_manual_file_response.dart';
import 'package:dataspikemobilesdk/data/models/response/dataspike_empty_response.dart';
import 'package:dataspikemobilesdk/data/models/request/country_request_body.dart';
import 'package:dataspikemobilesdk/data/models/response/country_response.dart';
import 'package:dataspikemobilesdk/data/models/response/proceed_with_verification_response.dart';
import 'package:dataspikemobilesdk/data/api/dataspike_endpoint.dart';
import 'package:dataspikemobilesdk/data/models/response/upload_image_error_response.dart';
import 'package:dataspikemobilesdk/data/models/response/dataspike_profile_fields_response.dart';
import 'package:dataspikemobilesdk/data/models/request/profile_fields_request_body.dart';
import 'package:dataspikemobilesdk/data/models/request/image_document_request_body.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dataspikemobilesdk/data/models/errors/common_errors.dart';

abstract class IDataspikeApiService {
  Future<VerificationResponse> getVerification(String shortId);
  Future<UploadImageResponse> uploadImage(
    String shortId,
    String documentType,
    List<int> fileBytes,
    String ext,
    String fileName,
  );
  Future<UploadImageResponse> uploadDocument(
    String shortId,
    ImageDocumentRequestBody body,
  );
  Future<UploadManualFileResponse> uploadManualFile(
    String shortId,
    String type,
    List<int> fileBytes,
    String ext,
    String fileName,
  );
  Future<DataspikeEmptyResponse> setCountry(
    String shortId,
    CountryRequestBody body,
  );
  Future<List<CountryResponse>> getCountries();
  Future<ProceedWithVerificationResponse> proceedWithVerification(
    String shortId,
  );
  Future<DataspikeProfileFieldsResponse> setProfileFields(
    String shortId,
    ProfileFieldsRequestBody body,
  );
}

class DataspikeApiServiceImpl implements IDataspikeApiService {
  final String baseUrl;
  final String apiToken;

  static const Duration _defaultTimeout = Duration(seconds: 20);

  DataspikeApiServiceImpl({required this.baseUrl, required this.apiToken});

  @override
  Future<VerificationResponse> getVerification(String shortId) async {
    final url = Uri.parse(
      '$baseUrl${DataspikeEndpoint.getVerification.path(shortId: shortId)}',
    );
    final headers = DataspikeEndpoint.getVerification.headers(apiToken);

    return _wrapNetworkErrors(() async {
      final response = await http.get(url, headers: headers).timeout(_defaultTimeout);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body) as Map<String, dynamic>;
        return VerificationResponse.fromJson(jsonBody);
      } else {
        throw Exception('Failed to load verification: ${response.statusCode}');
      }
    });
  }

  @override
  Future<UploadImageResponse> uploadImage(
    String shortId,
    String documentType,
    List<int> fileBytes,
    String ext,
    String fileName,
  ) async {
    final url = Uri.parse(
      '$baseUrl${DataspikeEndpoint.uploadImage.path(shortId: shortId)}',
    );
    final headers = DataspikeEndpoint.uploadImage.headers(apiToken);

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..fields['document_type'] = documentType;

    if (fileBytes.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          contentType: _mimeFromExt(ext),
          filename: fileName,
        ),
      );
    }

    return _wrapNetworkErrors(() async {
      final streamedResponse = await request.send().timeout(_defaultTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body) as Map<String, dynamic>;
        return UploadImageResponse.fromJson(jsonBody);
      } else {
        try {
          final errorJson = json.decode(response.body) as Map<String, dynamic>;
          final errorResponse = UploadImageErrorResponse.fromJson(errorJson);
          throw errorResponse;
        } on UploadImageErrorResponse {
          rethrow;
        } catch (_) {
          throw Exception('Failed to upload image: ${response.statusCode}');
        }
      }
    });
  }

  @override
  Future<UploadImageResponse> uploadDocument(
    String shortId,
    ImageDocumentRequestBody body,
  ) async {
    final url = Uri.parse(
      '$baseUrl${DataspikeEndpoint.uploadImage.path(shortId: shortId)}',
    );
    final headers = DataspikeEndpoint.uploadImage.headers(apiToken);

    return _wrapNetworkErrors(() async {
      final response = await http
          .post(url, headers: headers, body: json.encode(body.toJson()))
          .timeout(_defaultTimeout);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body) as Map<String, dynamic>;
        return UploadImageResponse.fromJson(jsonBody);
      } else {
        try {
          final errorJson = json.decode(response.body) as Map<String, dynamic>;
          final errorResponse = UploadImageErrorResponse.fromJson(errorJson);
          throw errorResponse;
        } on UploadImageErrorResponse {
          rethrow;
        } catch (_) {
          throw Exception('Failed to upload image: ${response.statusCode}');
        }
      }
    });
  }

  @override
  Future<UploadManualFileResponse> uploadManualFile(
    String shortId,
    String type,
    List<int> fileBytes,
    String ext,
    String fileName,
  ) async {
    final url = Uri.parse(
      '$baseUrl${DataspikeEndpoint.uploadManualDocument.path(shortId: shortId)}',
    );
    final headers = DataspikeEndpoint.uploadManualDocument.headers(apiToken);

    var request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers);

    if (fileBytes.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          type,
          fileBytes,
          contentType: _mimeFromExt(ext),
          filename: fileName,
        ),
      );
    }

    return _wrapNetworkErrors(() async {
      final streamedResponse = await request.send().timeout(_defaultTimeout);
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body) as Map<String, dynamic>;
        return UploadManualFileResponse.fromJson(jsonBody);
      } else {
        try {
          final errorJson = json.decode(response.body) as Map<String, dynamic>;
          final errorResponse = UploadManualFileResponse.fromJson(errorJson);
          throw errorResponse;
        } on UploadManualFileResponse {
          rethrow;
        } catch (_) {
          throw Exception('Failed to upload image: ${response.statusCode}');
        }
      }
    });
  }

  @override
  Future<DataspikeEmptyResponse> setCountry(
    String shortId,
    CountryRequestBody body,
  ) async {
    final url = Uri.parse(
      '$baseUrl${DataspikeEndpoint.setCountry.path(shortId: shortId)}',
    );
    final headers = DataspikeEndpoint.setCountry.headers(apiToken);

    return _wrapNetworkErrors(() async {
      final response = await http
          .post(url, headers: headers, body: json.encode(body.toJson()))
          .timeout(_defaultTimeout);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body) as Map<String, dynamic>;
        return DataspikeEmptyResponse.fromJson(jsonBody);
      } else {
        throw Exception('Failed to set country: ${response.statusCode}');
      }
    });
  }

  @override
  Future<List<CountryResponse>> getCountries() async {
    final url = Uri.parse('$baseUrl${DataspikeEndpoint.getCountries.path()}');
    final headers = DataspikeEndpoint.getCountries.headers(apiToken);

    return _wrapNetworkErrors(() async {
      final response = await http.get(url, headers: headers).timeout(_defaultTimeout);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body) as List<dynamic>;
        return jsonBody
            .map((e) => CountryResponse.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    });
  }

  @override
  Future<ProceedWithVerificationResponse> proceedWithVerification(
    String shortId,
  ) async {
    final url = Uri.parse(
      '$baseUrl${DataspikeEndpoint.proceedWithVerification.path(shortId: shortId)}',
    );
    final headers = DataspikeEndpoint.proceedWithVerification.headers(apiToken);

    return _wrapNetworkErrors(() async {
      final response = await http.post(url, headers: headers).timeout(_defaultTimeout);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body) as Map<String, dynamic>;
        return ProceedWithVerificationResponse.fromJson(jsonBody);
      } else {
        try {
          final errorJson = json.decode(response.body) as Map<String, dynamic>;
          final errorResponse = ProceedWithVerificationErrorResponse.fromJson(errorJson);
          throw errorResponse;
        } on ProceedWithVerificationErrorResponse {
          rethrow;
        } catch (_) {
          throw Exception(
            'Failed to proceed with verification: ${response.statusCode}',
          );
        }
      }
    });
  }

  @override
  Future<DataspikeProfileFieldsResponse> setProfileFields(
    String shortId,
    ProfileFieldsRequestBody body,
  ) async {
    final url = Uri.parse(
      '$baseUrl${DataspikeEndpoint.setProfileFields.path(shortId: shortId)}',
    );
    final headers = DataspikeEndpoint.setProfileFields.headers(apiToken);

    return _wrapNetworkErrors(() async {
      final response = await http
          .post(url, headers: headers, body: json.encode(body.toJson()))
          .timeout(_defaultTimeout);
      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body) as Map<String, dynamic>;
        return DataspikeProfileFieldsResponse.fromJson(jsonBody);
      } else {
        throw Exception('Failed to set profile fields: ${response.statusCode}');
      }
    });
  }

  // Wrap network errors to detect no internet and timeouts
  Future<T> _wrapNetworkErrors<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on SocketException {
      throw NoInternetException();
    } on TimeoutException {
      throw NoInternetException();
    }
  }
}

extension DataspikeApiServiceImplExtensions on IDataspikeApiService {
  MediaType _mimeFromExt(String? ext) {
    switch ((ext ?? '').toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'jpe':
      case 'heic':
      case 'heif':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'mp4':
      case 'mov':
        return MediaType('video', 'mp4');
      case 'mpeg':
        return MediaType('video', 'mpeg'); 
      case 'pdf':
        return MediaType('application', 'pdf');
      default:
        return MediaType('application', 'octet-stream'); 
    }
  }
}