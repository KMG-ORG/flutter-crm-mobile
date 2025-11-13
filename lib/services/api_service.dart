import 'dart:convert';
import 'package:crmMobileUi/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

// ///////////
// import 'package:shared_preferences/shared_preferences.dart';
// ///////////
class ApiService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = "auth_token";
  static const String _userDetailKey = "user_detail";
  //final _dioService = AuthService();
  final AuthService _dioService = AuthService();

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

  // Future<Map<String, dynamic>> getLeads(Map<String, dynamic> payload) async {
  //   // final token = await _storage.read(key: "access_token");
  //   final token = await _storage.read(key: _tokenKey);
  //   final payload = {
  //     'pageSize': 20,
  //     'pageNumber': 1,
  //     'columnName': 'UpdatedDateTime',
  //     'orderType': 'desc',
  //     'filterJson': null,
  //     'searchText': null,
  //   };
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/Lead/GetLeads"),
  //     headers: {
  //       "Authorization": "Bearer $token",
  //       "Content-Type": "application/json",
  //       "X-Correlation-Id": generateGUID(), // Generate X-Correlation-Id header
  //       "X-Request-Id": generateGUID(), // Generate X-Request-Id header
  //     },
  //     body: jsonEncode(payload),
  //   );

  //   if (response.statusCode == 200) {
  //     final body = jsonDecode(response.body);
  //     // final List leads = body['leads']; // Graph API returns { "value": [...] }
  //     return {
  //       'data': List<Map<String, dynamic>>.from(body['leads'] ?? []),
  //       'totalCount': body['totalCount'] ?? 0,
  //     };
  //   } else {
  //     throw Exception("Failed to fetch leads: ${response.body}");
  //   }
  // }

  Future<Map<String, dynamic>> getLeads(Map<String, dynamic> payload) async {
    try {
      // ✅ AuthService.post() automatically adds headers & base URL
      final response = await _dioService.post('Lead/GetLeads', data: payload);

      print("🔍 getLeads status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'data': List<Map<String, dynamic>>.from(data['leads'] ?? []),
          'totalCount': data['totalCount'] ?? 0,
        };
      } else {
        throw Exception(
          'Failed to load leads: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print("❌ getLeads error: $e");
      rethrow;
    }
  }

  /// --- 🔹 Fetch saved user details from secure storage ---
  Future<Map<String, dynamic>?> getUserDetails() async {
    final userDetail = await _storage.read(key: _userDetailKey);
    final Map<String, dynamic>? userMap = userDetail != null
        ? json.decode(userDetail)
        : null;
    return userMap;
  }

  // Future<Map<String, dynamic>?> getUserDetails() async {
  //   try {
  //     // Read JSON string from secure storage
  //     final userDetail = await _storage.read(key: _userDetailKey);

  //     if (userDetail == null || userDetail.isEmpty) {
  //       print("⚠️ No user details found in storage");
  //       return null;
  //     }

  //     // Decode JSON to a Map
  //     final Map<String, dynamic> userMap = jsonDecode(userDetail);
  //     print("👤 Loaded user details: ${userMap['username'] ?? 'Unknown'}");
  //     return userMap;
  //   } catch (e, s) {
  //     print("❌ Error reading user details: $e");
  //     print(s);
  //     return null;
  //   }
  // }

  Future<Map<String, List<dynamic>>> getFilteredMasterData() async {
    try {
      // ✅ Define payload
      final payload = {
        "type": [
          "RevenueType",
          "LeadSource",
          "Industry",
          "AccountType",
          "TimeZone",
          "Salutation",
          "Stage",
        ],
      };

      // ✅ Use centralized Dio service
      final response = await _dioService.post(
        "Master/GetFilteredGenericMasterTable",
        data: payload,
      );

      print("🔍 getFilteredMasterData status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> body = response.data;

        // ✅ Transform to Map<String, List<dynamic>>
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
        throw Exception(
          "Failed to fetch master data: ${response.statusCode} - ${response.data}",
        );
      }
    } catch (e, st) {
      print("❌ getFilteredMasterData error: $e");
      print(st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createLead(Map<String, dynamic> leadData) async {
    try {
      // ✅ Use centralized AuthService with Dio
      final response = await _dioService.post(
        'Lead/CreateLead',
        data: leadData,
      );

      print("📡 createLead status: ${response.statusCode}");
      print("📦 createLead response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // 🧠 Case 1: Backend returns a GUID or plain string (not JSON)
        if (data is String && !data.trim().startsWith('{')) {
          return {
            "success": true,
            "message": "Lead created successfully",
            "leadId": data.trim(),
          };
        }

        // 🧠 Case 2: Backend returns a proper JSON response
        if (data is Map<String, dynamic>) {
          return {
            "success": true,
            "message": data["message"] ?? "Lead created successfully",
            "data": data,
          };
        }

        // 🧠 Case 3: Fallback for unknown types
        return {
          "success": true,
          "message": "Lead created successfully",
          "data": {"value": data},
        };
      } else {
        throw Exception(
          'Failed to create lead: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print("❌ createLead error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getContacts(Map<String, dynamic> payload) async {
    try {
      // ✅ Use centralized Dio service
      final response = await _dioService.post(
        'Contact/GetContact',
        data: payload,
      );

      print("🔍 getContacts status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        return {
          'data': List<Map<String, dynamic>>.from(data['contacts'] ?? []),
          'totalCount': data['totalCount'] ?? 0,
        };
      } else {
        throw Exception(
          'Failed to load contacts: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print("❌ getContacts error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAccounts(Map<String, dynamic> payload) async {
    try {
      // ✅ Use your centralized Dio service
      final response = await _dioService.post(
        'Account/GetAccount',
        data: payload,
      );

      print("🔍 getAccounts status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        // ✅ Extract account data and total count
        return {
          'data': List<Map<String, dynamic>>.from(data['account'] ?? []),
          'totalCount': data['totalCount'] ?? 0,
        };
      } else {
        throw Exception(
          'Failed to load accounts: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e, st) {
      print("❌ getAccounts error: $e");
      print(st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTickets(Map<String, dynamic> payload) async {
    try {
      // ✅ Make POST request using your centralized Dio service
      final response = await _dioService.post(
        'Ticket/GetTicket',
        data: payload,
      );

      print("🎫 getTickets status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        // ✅ Extract ticket list and total count
        return {
          'data': List<Map<String, dynamic>>.from(data['ticket'] ?? []),
          'totalCount': data['totalCount'] ?? 0,
        };
      } else {
        throw Exception(
          'Failed to load tickets: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e, st) {
      print("❌ getTickets error: $e");
      print(st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCampaigns(
    Map<String, dynamic> payload,
  ) async {
    try {
      // ✅ Make POST request using centralized Dio service
      final response = await _dioService.post(
        'Campaign/GetCampaign',
        data: payload,
      );

      print("📢 getCampaigns status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        // ✅ Extract campaign list and total count
        return {
          'data': List<Map<String, dynamic>>.from(data['campaign'] ?? []),
          'totalCount': data['totalCount'] ?? 0,
        };
      } else {
        throw Exception(
          'Failed to load campaigns: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e, st) {
      print("❌ getCampaigns error: $e");
      print(st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSales(Map<String, dynamic> payload) async {
    try {
      // ✅ Use centralized Dio service
      final response = await _dioService.post(
        "SaleOrder/GetSaleOrders",
        data: payload,
      );

      print("🔍 getSales status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        return {
          'data': List<Map<String, dynamic>>.from(data['saleOrders'] ?? []),
          'totalCount': data['totalCount'] ?? 0,
        };
      } else {
        throw Exception(
          "Failed to load sales: ${response.statusCode} - ${response.data}",
        );
      }
    } catch (e, st) {
      print("❌ getSales error: $e");
      print(st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getOpportunity(
    Map<String, dynamic> payload,
  ) async {
    try {
      // ✅ Use centralized Dio service
      final response = await _dioService.post(
        "Opportunity/GetOpportunity",
        data: payload,
      );

      print("🔍 getOpportunity status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        return {
          'data': List<Map<String, dynamic>>.from(data['opportunity'] ?? []),
          'totalCount': data['totalCount'] ?? 0,
        };
      } else {
        throw Exception(
          'Failed to load opportunity: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e, st) {
      print("❌ getOpportunity error: $e");
      print(st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getProducts(Map<String, dynamic> payload) async {
    try {
      // ✅ Use centralized Dio service
      final response = await _dioService.post("Product/Getlist", data: payload);

      print("🔍 getProducts status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        return {
          'data': List<Map<String, dynamic>>.from(data['product'] ?? []),
          'totalCount': data['totalCount'] ?? 0,
        };
      } else {
        throw Exception(
          "Failed to load products: ${response.statusCode} - ${response.data}",
        );
      }
    } catch (e, st) {
      print("❌ getProducts error: $e");
      print(st);
      rethrow;
    }
  }

  Future<bool> updateAccount(Map<String, dynamic> data) async {
    try {
      // ✅ Use centralized Dio service
      final response = await _dioService.post(
        "Account/UpdateAccount",
        data: data,
      );

      print("🔍 updateAccount status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return true; // ✅ Success
      } else {
        throw Exception(
          "Failed to update account. Status: ${response.statusCode} - ${response.data}",
        );
      }
    } catch (e, st) {
      print("❌ updateAccount error: $e");
      print(st);
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOwners() async {
    try {
      // ✅ Use centralized Dio service
      final response = await _dioService.get('NetAuth/GetUsersAsync');

      print("🔍 getOwners status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        // ✅ Safely handle different possible response structures
        if (data is Map && data.containsKey("userList")) {
          final List userList = data["userList"];
          return List<Map<String, dynamic>>.from(userList);
        }

        return [];
      } else {
        throw Exception(
          'Failed to fetch contact owners: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e, st) {
      print("❌ getOwners error: $e");
      print(st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateContact(
    Map<String, dynamic> contactData,
  ) async {
    try {
      // ✅ Centralized AuthService handles headers, tokens, and baseUrl
      final response = await _dioService.post(
        'Contact/UpdateContact',
        data: contactData,
      );

      print("📡 updateContact status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        // 🧠 Handle both Map and primitive responses (bool/int/string)
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          // Wrap primitive response into a map
          return {'success': true, 'value': data};
        }
      } else {
        throw Exception(
          'Failed to update contact: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print("❌ updateContact error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getContactById(String id) async {
    try {
      // ✅ Centralized Dio GET request
      final response = await _dioService.get(
        'Contact/GetContactById',
        queryParams: {'id': id},
      );

      print("📡 getContactById status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        // Ensure consistent return type
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          // In case API returns a primitive type or list accidentally
          return {'data': data};
        }
      } else {
        throw Exception(
          'Failed to fetch contact: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print('❌ getContactById error: $e');
      rethrow; // Propagate error for handling in UI
    }
  }

  Future<List<Map<String, dynamic>>> getAccountNamesList(
    Map<String, dynamic> payload,
  ) async {
    try {
      // ✅ Use centralized AuthService
      final response = await _dioService.post(
        'Account/GetNamesList',
        data: payload,
      );

      print("📡 getAccountNamesList status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        // ✅ Extract `accountList` safely
        final List<dynamic> list = data['accountList'] ?? [];

        // ✅ Ensure consistent type
        return List<Map<String, dynamic>>.from(list);
      } else {
        throw Exception(
          'Failed to fetch account names: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print('❌ getAccountNamesList error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateLead(Map<String, dynamic> leadData) async {
    try {
      // ✅ Use centralized AuthService with automatic headers + base URL
      final response = await _dioService.post(
        'Lead/UpdateLead',
        data: leadData,
      );

      print("📡 updateLead status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        // 🧠 Handle both Map and primitive types
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          // Wrap simple response (int, bool, string) in a map
          return {'success': true, 'value': data};
        }
      } else {
        throw Exception(
          'Failed to update lead: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print('❌ updateLead error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getLeadById(String id) async {
    try {
      // ✅ Use centralized Dio helper that auto-handles token, headers, and baseUrl
      final response = await _dioService.get(
        'Lead/GetLeadById',
        queryParams: {'id': id},
      );

      print("📡 getLeadById status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        // 🧠 Ensure consistent Map response
        if (data is Map<String, dynamic>) {
          return data;
        } else {
          return {'data': data};
        }
      } else {
        throw Exception(
          'Failed to fetch lead: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print('❌ getLeadById error: $e');
      rethrow; // propagate error for UI handling
    }
  }

  Future<bool> updateOpportunity(Map<String, dynamic> data) async {
    try {
      // ✅ Use centralized Dio service
      final response = await _dioService.post(
        "Opportunity/UpdateOpportunity",
        data: data,
      );

      print("🔍 updateOpportunity status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return true; // ✅ Successful update
      } else {
        throw Exception(
          "Failed to update opportunity: ${response.statusCode} - ${response.data}",
        );
      }
    } catch (e, st) {
      print("❌ updateOpportunity error: $e");
      print(st);
      rethrow;
    }
  }

  Future<int> getTotalLead() async {
    try {
      // ✅ Use centralized AuthService helper (auto handles token + headers)
      final response = await _dioService.get('CrmDashboard/GetTotalLead');

      print("📊 getTotalLead status: ${response.statusCode}");
      print("📦 getTotalLead response: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        // 🧠 Handle plain integer or string response
        if (data is int) return data;
        if (data is String) return int.tryParse(data) ?? 0;

        // 🧠 Handle JSON response (if backend returns wrapped data)
        if (data is Map && data.containsKey('totalLead')) {
          return int.tryParse(data['totalLead'].toString()) ?? 0;
        }

        // Default fallback
        return 0;
      } else {
        throw Exception(
          'Failed to fetch total leads: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print("❌ getTotalLead error: $e");
      rethrow;
    }
  }

  Future<int> getOpenOpportunity() async {
    try {
      // ✅ Use centralized Dio helper (automatically sets token + headers)
      final response = await _dioService.get('CrmDashboard/GetOpenOpportunity');

      print("💼 getOpenOpportunity status: ${response.statusCode}");
      print("📦 getOpenOpportunity response: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        // 🧠 Handle multiple possible return formats
        if (data is int) return data;
        if (data is String) return int.tryParse(data) ?? 0;
        if (data is Map && data.containsKey('openOpportunity')) {
          return int.tryParse(data['openOpportunity'].toString()) ?? 0;
        }

        // 🧩 Fallback for unexpected format
        return 0;
      } else {
        throw Exception(
          'Failed to fetch open opportunities: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print("❌ getOpenOpportunity error: $e");
      rethrow;
    }
  }

  Future<int> getTotalOpenTicket() async {
    try {
      // ✅ Use centralized AuthService helper (auto adds token + headers)
      final response = await _dioService.get('CrmDashboard/TotalOpenTicket');

      print("🎟️ getTotalOpenTicket status: ${response.statusCode}");
      print("📦 getTotalOpenTicket response: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        // 🧠 Handle different possible response formats
        if (data is int) return data;
        if (data is String) return int.tryParse(data) ?? 0;
        if (data is Map && data.containsKey('totalOpenTicket')) {
          return int.tryParse(data['totalOpenTicket'].toString()) ?? 0;
        }

        // 🧩 Fallback — unexpected response format
        return 0;
      } else {
        throw Exception(
          'Failed to fetch total open tickets: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print("❌ getTotalOpenTicket error: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCrmDashboard() async {
    try {
      // ✅ Use centralized Dio helper (auto handles token, headers, base URL)
      final response = await _dioService.get('CrmDashboard/GetCrmDashboard');

      print("📊 getCrmDashboard status: ${response.statusCode}");
      print("📦 getCrmDashboard response: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        // 🧠 Ensure the response is a valid map
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is String) {
          // If backend returns stringified JSON
          return jsonDecode(data);
        } else {
          throw Exception("Unexpected response format: ${data.runtimeType}");
        }
      } else {
        throw Exception(
          "Failed to fetch CRM Dashboard: ${response.statusCode} - ${response.data}",
        );
      }
    } catch (e) {
      print("❌ getCrmDashboard error: $e");
      rethrow;
    }
  }
}
