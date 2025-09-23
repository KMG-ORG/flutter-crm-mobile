import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = "auth_token";
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

  Future<void> _loadToken() async {
    _token = await _storage.read(key: _tokenKey);

    notifyListeners();
  }

  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
    notifyListeners();
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
// ///////////
// import 'package:flutter/material.dart';
// import '../models/user.dart';

// /// Simple AuthService using ChangeNotifier. Replace with real API calls.
// class AuthService extends ChangeNotifier {
//   User? _user;

//   bool get isAuthenticated => _user != null;
//   User? get user => _user;

//   Future<bool> login({required String email, required String password}) async {
//     // TODO: replace with real authentication flow (API call, token storage, etc.)
//     await Future.delayed(const Duration(milliseconds: 800));
//     _user = User(id: '1', name: 'John Doe', email: email);
//     notifyListeners();
//     return true;
//   }

//   Future<void> logout() async {
//     // TODO: clear tokens, session storage, etc
//     _user = null;
//     notifyListeners();
//   }
// }
///////////
///import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_appauth/flutter_appauth.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;

// class AuthService extends ChangeNotifier {
//   final FlutterAppAuth _appAuth = const FlutterAppAuth();
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

//   bool _isAuthenticated = false;
//   bool get isAuthenticated => _isAuthenticated;

//   Map<String, dynamic>? _user;
//   Map<String, dynamic>? get user => _user;

//   final String clientId = dotenv.env['AZURE_CLIENT_ID'] ?? '';
//   final String tenantId = dotenv.env['AZURE_TENANT_ID'] ?? '';
//   final String redirectUri = dotenv.env['REDIRECT_URI'] ?? '';
//   final List<String> scopes = ["openid", "profile", "email", "User.Read"];

//   String get issuer => "https://login.microsoftonline.com/$tenantId/v2.0";

//   Future<void> signIn() async {
//     try {
//       final result = await _appAuth.authorizeAndExchangeCode(
//         AuthorizationTokenRequest(
//           clientId,
//           redirectUri,
//           issuer: issuer,
//           scopes: scopes,
//           promptValues: ['login'],
//         ),
//       );

//       if (result != null) {
//         await _secureStorage.write(
//           key: "access_token",
//           value: result.accessToken,
//         );
//         await _secureStorage.write(key: "id_token", value: result.idToken);
//         _isAuthenticated = true;
//         await fetchUserProfile();
//         notifyListeners();
//       }
//     } catch (e) {
//       print("Azure login failed: $e");
//     }
//   }

//   Future<void> fetchUserProfile() async {
//     final token = await _secureStorage.read(key: "access_token");
//     if (token == null) return;

//     final response = await http.get(
//       Uri.parse("https://graph.microsoft.com/v1.0/me"),
//       headers: {"Authorization": "Bearer $token"},
//     );

//     if (response.statusCode == 200) {
//       _user = jsonDecode(response.body);
//       notifyListeners();
//     }
//   }

//   Future<void> signOut() async {
//     await _secureStorage.deleteAll();
//     _isAuthenticated = false;
//     _user = null;
//     notifyListeners();
//   }

//   Future<void> checkAuthStatus() async {
//     final token = await _secureStorage.read(key: "access_token");
//     _isAuthenticated = token != null;
//     if (_isAuthenticated) {
//       await fetchUserProfile();
//     }
//     notifyListeners();
//   }
// }
