import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:msal_auth/msal_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  SingleAccountPca? _pca;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = "auth_token";
  static const String _userDetailKey = "user_detail";
  final String baseUrl = "https://gateway-crm-qa.azurewebsites.net/gateway/netcrm-qa/v1"; 
  // Add this getter to expose user information
  Map<String, dynamic>? get user => _user;

  // Make sure you have a private field to hold user data
  Map<String, dynamic>? _user;
  String? _token;

  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  AuthService() {
    _loadToken();
  }

  // Future<void> init() async {
  //   _pca = await SingleAccountPca.create(
  //     clientId: dotenv.env['AZURE_CLIENT_ID']!,
  //     androidConfig: AndroidConfig(
  //       configFilePath: 'assets/msal_config.json',
  //       // redirectUri: 'msauth://com.yourcompany.yourapp/yourredirect',
  //       redirectUri: dotenv.env['REDIRECT_URI']!,
  //     ),

  //     appleConfig: AppleConfig(authority: dotenv.env['REDIRECT_URI']!),
  //   );
  // }
  Future<void> init() async {
    if (_pca != null) return; // Already initialized, skip
    _pca = await SingleAccountPca.create(
      clientId: dotenv.env['AZURE_CLIENT_ID']!,
      androidConfig: AndroidConfig(
        configFilePath: 'assets/msal_config.json',
        redirectUri: dotenv.env['REDIRECT_URI']!,
      ),
      appleConfig: AppleConfig(authority: dotenv.env['REDIRECT_URI']!),
    );
  }

Future<String?> login() async {
  if (_pca == null) {
    throw Exception("MSAL PublicClientApplication not initialized");
  }

  try {
    // 🔹 Acquire token using MSAL
    final result = await _pca!.acquireToken(
      scopes: [dotenv.env['AZURE_SCOPES'] ?? "User.Read"],
    );

    final token = result.accessToken;
    print("✅ Access token acquired: $token");

    // 🔹 Extract account details
    final accountData = result.account.toJson();
    print("👤 Account info: $accountData");

    // 🔹 Save token and user detail
    await saveUserDetail(token, accountData);

    return token;
  } catch (e, s) {
    print("❌ MSAL Login Error: $e");
    print(s);
    return null;
  }
}




  Future<void> logout() async {
    if (_pca == null) return;
    try {
      await _pca!.signOut();
      _pca = null; // allow re-initialization
      print("Logout successful, ready for new login");
    } catch (e) {
      print("Logout error: $e");
    }
  }

  Future<void> _loadToken() async {
    _token = await _storage.read(key: _tokenKey);

    notifyListeners();
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
    notifyListeners();
  }

   /// --- 🔹 Save token and fetch user details (MOBILE ONLY) ---
  Future<void> saveUserDetail(String token, Map<String, dynamic> data) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);

    final userName = data['username']?.toString().trim();
    if (userName == null || userName.isEmpty) {
      throw Exception("❌ Missing username in user data");
    }

    try {
      // ✅ API call to fetch user details
      final uri = Uri.parse('$baseUrl/NetAuth/GetUserVmByUserName')
          .replace(queryParameters: {'userName': userName});

      final response = await http.get(
        uri,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print("🔍 Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);

        // ✅ Some APIs return { "user": {...} }, others return {...} directly
        final userData = body['user'] ?? body;
        _user = userData;

        // ✅ Save to secure storage
        await _storage.write(key: _userDetailKey, value: jsonEncode(userData));

        print("✅ User detail saved successfully");
        debugPrint("👤 Saved user: ${userData['fullName'] ?? 'Unknown'}");
      } else {
        throw Exception(
          'Failed to load user detail: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, s) {
      print("❌ saveUserDetail error: $e");
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
    notifyListeners();
  }

  Future<void> signOut() async {
    // Implement sign out logic here, e.g., clear user data and notify listeners
    _user = null;
    notifyListeners();
  }
}
