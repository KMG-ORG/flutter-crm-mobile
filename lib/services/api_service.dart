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
  static const String _userDetailKey = "user_detail";

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

  Future<Map<String, dynamic>> getLeads(Map<String, dynamic> payload) async {
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
      // final List leads = body['leads']; // Graph API returns { "value": [...] }
      return {
        'data': List<Map<String, dynamic>>.from(body['leads'] ?? []),
        'totalCount': body['totalCount'] ?? 0,
      };
    } else {
      throw Exception("Failed to fetch leads: ${response.body}");
    }
  }

  /// --- 🔹 Fetch saved user details from secure storage ---
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      // Read JSON string from secure storage
      final userDetail = await _storage.read(key: _userDetailKey);

      if (userDetail == null || userDetail.isEmpty) {
        print("⚠️ No user details found in storage");
        return null;
      }

      // Decode JSON to a Map
      final Map<String, dynamic> userMap = jsonDecode(userDetail);
      print("👤 Loaded user details: ${userMap['username'] ?? 'Unknown'}");
      return userMap;
    } catch (e, s) {
      print("❌ Error reading user details: $e");
      print(s);
      return null;
    }
  }

  Future<Map<String, List<dynamic>>> getFilteredMasterData() async {
    try {
      final token = await _storage.read(key: _tokenKey);

      final payload = {
        "type": [
          "RevenueType",
          "LeadSource",
          "Industry",
          "AccountType",
          "TimeZone",
          "Salutation",
        ],
      };

      final response = await http.post(
        Uri.parse("$baseUrl/Master/GetFilteredGenericMasterTable"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "X-Correlation-Id": generateGUID(),
          "X-Request-Id": generateGUID(),
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);

        final Map<String, List<dynamic>> result = {};
        for (var item in body) {
          final type = item["type"];
          final data = item["data"] ?? [];
          if (type != null && data is List) {
            result[type] = List<Map<String, dynamic>>.from(data);
          }
        }
        return result;
      } else {
        throw Exception("Failed to fetch master data: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching master data: $e");
    }
  }

  // 🔹 CREATE LEAD
  Future<Map<String, dynamic>> createLead(Map<String, dynamic> leadData) async {
    try {
      final token = await _storage.read(key: _tokenKey);

      final response = await http.post(
        Uri.parse("$baseUrl/Lead/CreateLead"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "X-Correlation-Id": generateGUID(),
          "X-Request-Id": generateGUID(),
        },
        body: jsonEncode(leadData),
      );

      // 🔹 Log response for debugging
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final bodyText = response.body.trim();

        // ✅ If backend returns GUID or plain text instead of JSON
        if (!bodyText.startsWith("{") && !bodyText.startsWith("[")) {
          return {
            "success": true,
            "message": "Lead created successfully",
            "leadId": bodyText,
          };
        }

        // ✅ Otherwise, parse JSON
        final body = jsonDecode(bodyText);
        return {
          "success": true,
          "message": body["message"] ?? "Lead created successfully",
          "data": body,
        };
      } else {
        throw Exception("Failed to create lead: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error creating lead: $e");
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

  // Future<List<Map<String, dynamic>>> getAccounts(payload) async {
  //   final token = await _storage.read(key: _tokenKey);

  //   // final payload = {
  //   //   'pageSize': 20,
  //   //   'pageNumber': 1,
  //   //   'columnName': 'UpdatedDateTime',
  //   //   'orderType': 'desc',
  //   //   'filterJson': null,
  //   //   'searchText': null,
  //   // };

  //   final response = await http.post(
  //     Uri.parse("$baseUrl/Account/GetAccount"), // 👈 change endpoint
  //     headers: {
  //       "Authorization": "Bearer $token",
  //       "Content-Type": "application/json",
  //       "X-Correlation-Id": generateGUID(),
  //       "X-Request-Id": generateGUID(),
  //     },
  //     body: jsonEncode(payload),
  //   );

  //   if (response.statusCode == 200) {
  //     final body = jsonDecode(response.body);
  //     final List accounts = body['account']; // 👈 match API key
  //     return accounts.map((e) => e as Map<String, dynamic>).toList();
  //   } else {
  //     throw Exception("Failed to fetch accounts: ${response.body}");
  //   }
  // }

  Future<Map<String, dynamic>> getAccounts(Map<String, dynamic> payload) async {
    final token = await _storage.read(key: _tokenKey);
    final response = await http.post(
      Uri.parse("$baseUrl/Account/GetAccount"),
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
        'data': List<Map<String, dynamic>>.from(body['account'] ?? []),
        'totalCount': body['totalCount'] ?? 0,
      };
    } else {
      throw Exception('Failed to load accounts');
    }
  }

  Future<Map<String, dynamic>> getTickets(Map<String, dynamic> payload) async {
    final token = await _storage.read(key: _tokenKey);
    final response = await http.post(
      Uri.parse("$baseUrl/Ticket/GetTicket"),
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
        'data': List<Map<String, dynamic>>.from(body['ticket'] ?? []),
        'totalCount': body['totalCount'] ?? 0,
      };
    } else {
      throw Exception('Failed to load tickets');
    }
  }

  Future<Map<String, dynamic>> getCampaigns(
    Map<String, dynamic> payload,
  ) async {
    final token = await _storage.read(key: _tokenKey);
    final response = await http.post(
      Uri.parse("$baseUrl/Campaign/GetCampaign"),
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
        'data': List<Map<String, dynamic>>.from(body['campaign'] ?? []),
        'totalCount': body['totalCount'] ?? 0,
      };
    } else {
      throw Exception('Failed to load campaigns');
    }
  }

  Future<Map<String, dynamic>> getSales(Map<String, dynamic> payload) async {
    final token = await _storage.read(key: _tokenKey);
    final response = await http.post(
      Uri.parse("$baseUrl/SaleOrder/GetSaleOrders"),
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
        'data': List<Map<String, dynamic>>.from(body['saleOrders'] ?? []),
        'totalCount': body['totalCount'] ?? 0,
      };
    } else {
      throw Exception('Failed to load sales');
    }
  }

  Future<Map<String, dynamic>> getOpportunity(
    Map<String, dynamic> payload,
  ) async {
    final token = await _storage.read(key: _tokenKey);
    final response = await http.post(
      Uri.parse("$baseUrl/Opportunity/GetOpportunity"),
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
        'data': List<Map<String, dynamic>>.from(body['opportunity'] ?? []),
        'totalCount': body['totalCount'] ?? 0,
      };
    } else {
      throw Exception('Failed to load opportunity');
    }
  }

  Future<Map<String, dynamic>> getProducts(Map<String, dynamic> payload) async {
    final token = await _storage.read(key: _tokenKey);
    final response = await http.post(
      Uri.parse("$baseUrl/Product/Getlist"),
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
        'data': List<Map<String, dynamic>>.from(body['product'] ?? []),
        'totalCount': body['totalCount'] ?? 0,
      };
    } else {
      throw Exception('Failed to load Products');
    }
  }

  Future<bool> updateAccount(Map<String, dynamic> data) async {
    final token = await _storage.read(key: _tokenKey);

    final response = await http.post(
      Uri.parse("$baseUrl/Account/UpdateAccount"), // ✅ Confirm correct path
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "X-Correlation-Id": generateGUID(),
        "X-Request-Id": generateGUID(),
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // ✅ Only status code check, no need to parse JSON
      return true;
    } else {
      throw Exception(
        'Failed to update account. Status: ${response.statusCode}',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getOwners() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final response = await http.get(
        Uri.parse("$baseUrl/NetAuth/GetUsersAsync"),
        //headers: {'Content-Type': 'application/json'},
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "X-Correlation-Id": generateGUID(),
          "X-Request-Id": generateGUID(),
        },
      );
      // final response = await http.get(
      //   Uri.parse(
      //     "https://gateway-crm-qa.azurewebsites.net/gateway/netcrm-qa/v1/NetAuth/GetUsersAsync",
      //   ),
      //   headers: {
      //     "Authorization": "Bearer $token",
      //     "Content-Type": "application/json",
      //     "X-Correlation-Id": generateGUID(),
      //     "X-Request-Id": generateGUID(),
      //   },
      // );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        // ✅ Check if response contains `userList`
        if (body is Map && body.containsKey("userList")) {
          final List userList = body["userList"];
          return List<Map<String, dynamic>>.from(userList);
        }

        return [];
      } else {
        throw Exception("Failed to fetch contact owners: ${response.body}");
      }
    } catch (e) {
      print("❌ Error fetching contact owners: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateContact(
    Map<String, dynamic> contactData,
  ) async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final response = await http.post(
        Uri.parse("$baseUrl/Contact/UpdateContact"),
        //headers: {'Content-Type': 'application/json'},
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "X-Correlation-Id": generateGUID(),
          "X-Request-Id": generateGUID(),
        },
        body: jsonEncode(contactData),
      );
      // final token = await _getToken();
      // _dio.options.headers['Authorization'] = 'Bearer $token';

      // final response =
      //     await _dio.post('${baseUrl}Contact/UpdateContact', data: contactData);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // 🧠 Handle if backend returns int or bool instead of Map
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          // Wrap primitive responses in a map
          return {'success': true, 'value': decoded};
        }
      } else {
        throw Exception(
          'Failed to update contact: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error updating contact: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getContactById(String id) async {
    try {
      final token = await _storage.read(key: _tokenKey);

      final response = await http.get(
        Uri.parse("$baseUrl/Contact/GetContactById?id=$id"), // ✅ Corrected
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "X-Correlation-Id": generateGUID(),
          "X-Request-Id": generateGUID(),
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body; // ✅ Now always returns Map<String, dynamic>
      } else {
        throw Exception(
          'Failed to fetch contact: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error fetching contact by ID: $e');
      rethrow; // ✅ ensures error is properly propagated
    }
  }

  Future<List<Map<String, dynamic>>> getAccountNamesList(payload) async {
    try {
      final token = await _storage.read(key: _tokenKey);

      final response = await http.post(
        Uri.parse("$baseUrl/Account/GetNamesList"),
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

        // ✅ Extract `accountList` properly
        final List<dynamic> list = body['accountList'] ?? [];

        // Return list as List<Map<String, dynamic>>
        return List<Map<String, dynamic>>.from(list);
      } else {
        throw Exception(
          'Failed to fetch account names: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error fetching account names: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateLead(Map<String, dynamic> leadData) async {
    try {
      final token = await _storage.read(key: _tokenKey);
      final response = await http.post(
        Uri.parse("$baseUrl/Lead/UpdateLead"),
        //headers: {'Content-Type': 'application/json'},
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "X-Correlation-Id": generateGUID(),
          "X-Request-Id": generateGUID(),
        },
        body: jsonEncode(leadData),
      );
      // final token = await _getToken();
      // _dio.options.headers['Authorization'] = 'Bearer $token';

      // final response =
      //     await _dio.post('${baseUrl}Contact/UpdateContact', data: contactData);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // 🧠 Handle if backend returns int or bool instead of Map
        if (decoded is Map<String, dynamic>) {
          return decoded;
        } else {
          // Wrap primitive responses in a map
          return {'success': true, 'value': decoded};
        }
      } else {
        throw Exception(
          'Failed to update contact: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error updating contact: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLeadById(String id) async {
    try {
      final token = await _storage.read(key: _tokenKey);

      final response = await http.get(
        Uri.parse("$baseUrl/Lead/GetLeadById?id=$id"), // ✅ Corrected
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
          "X-Correlation-Id": generateGUID(),
          "X-Request-Id": generateGUID(),
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body; // ✅ Now always returns Map<String, dynamic>
      } else {
        throw Exception(
          'Failed to fetch lead: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error fetching lead by ID: $e');
      rethrow; // ✅ ensures error is properly propagated
    }
  }
}
