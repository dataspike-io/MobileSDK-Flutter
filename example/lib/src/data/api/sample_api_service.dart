import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/responses/new_verification_response.dart';

class ISampleAppApiService {
  final String baseUrl;
  final String apiToken;

  ISampleAppApiService({
    required this.baseUrl,
    required this.apiToken,
  });

  Future<NewVerificationResponse> createVerification(Map<String, String> body) async {
    final url = Uri.parse('$baseUrl/api/v3/verifications');
    final response = await http.post(
      url,
      headers: {
        'ds-api-token': apiToken,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return NewVerificationResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create verification: ${response.body}');
    }
  }
}