import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL of your API
  static const String baseUrl =
      "https://gateway-crm-qa.azurewebsites.net/gateway/netcrm-qa/v1/";

  // Contact Get Liat
  static Future<dynamic> getContactList(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("$baseUrl/$endpoint");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to post data: ${response.statusCode}");
    }
  }
}
