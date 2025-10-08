import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ///////////
// import 'package:shared_preferences/shared_preferences.dart';
// ///////////
class ApiService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = "auth_token";

  // String generateGUID() {
  //   final random =
  //       DateTime.now().microsecondsSinceEpoch.toRadixString(16) +
  //       List.generate(16, (index) => (index % 16).toRadixString(16)).join();
  //   return '${random.substring(0, 8)}-${random.substring(8, 12)}-4${random.substring(13, 16)}-${random.substring(16, 20)}-${random.substring(20, 32)}';
  // }
  String generateGUID() {
    final rand = () =>
        (DateTime.now().microsecondsSinceEpoch +
                (1000000 *
                    (1 + (DateTime.now().millisecondsSinceEpoch % 1000))))
            .toRadixString(16)
            .padLeft(4, '0')
            .substring(0, 4);
    return '${rand()}${rand()}-${rand()}-${rand()}-${rand()}-${rand()}${rand()}${rand()}';
  }

  // static Future<http.Response> getData(String url) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString("auth_token") ?? "";

  //   return http.get(
  //     Uri.parse(url),
  //     headers: {
  //       "Authorization": "Bearer $token",
  //       "Content-Type": "application/json",
  //     },
  //   );
  // }

  Future<List<Map<String, dynamic>>> getLeads() async {
    // final token = await _storage.read(key: "access_token");
    final token = await _storage.read(key: _tokenKey);
    final payload = {
      'pageSize': 20,
      'pageNumber': 1,
      'columnName': 'UpdatedDateTime',
      'orderType': 'desc',
      'filterJson': null,
      'searchText': null,
    };
    final response = await http.post(
      Uri.parse("$baseUrl/Lead/GetLeads"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "X-Correlation-Id": generateGUID(), // Generate X-Correlation-Id header
        "X-Request-Id": generateGUID(), // Generate X-Request-Id header
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List leads = body['leads']; // Graph API returns { "value": [...] }
      return leads.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception("Failed to fetch leads: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> getContacts(Map<String, dynamic> payload) async {
    final token = await _storage.read(key: _tokenKey);
    final response = await http.post(
      Uri.parse("$baseUrl/Contact/GetContact"),
      //headers: {'Content-Type': 'application/json'},
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "X-Correlation-Id": generateGUID(),
        "X-Request-Id": generateGUID(),
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return {
        'data': List<Map<String, dynamic>>.from(body['contacts'] ?? []),
        'totalCount': body['totalCount'] ?? 0,
      };
    } else {
      throw Exception('Failed to load contacts');
    }
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    final token = await _storage.read(key: _tokenKey);

    final payload = {
      'pageSize': 20,
      'pageNumber': 1,
      'columnName': 'UpdatedDateTime',
      'orderType': 'desc',
      'filterJson': null,
      'searchText': null,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/Account/GetAccount"), // 👈 change endpoint
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "X-Correlation-Id": generateGUID(),
        "X-Request-Id": generateGUID(),
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List accounts = body['account']; // 👈 match API key
      return accounts.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception("Failed to fetch accounts: ${response.body}");
    }
  }
}
