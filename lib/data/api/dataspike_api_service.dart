import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dataspikemobilesdk/data/models/response/verification_response.dart';
import 'package:dataspikemobilesdk/data/api/dataspike_endpoint.dart';

abstract class IDataspikeApiService {
  Future<VerificationResponse> getVerification(String shortId);
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
    final url = Uri.parse('$baseUrl${DataspikeEndpoint.getVerification.path(shortId: 'VBA45F44FB3FE268F')}');
    final headers = DataspikeEndpoint.getVerification.headers(apiToken);

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body) as Map<String, dynamic>;
      return VerificationResponse.fromJson(jsonBody);
    } else {
      throw Exception('Failed to load verification: ${response.statusCode}');
    }
  }
}