// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class AuthService extends ChangeNotifier {
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();
//   static const String _tokenKey = "auth_token";
//   // Add this getter to expose user information
//   Map<String, dynamic>? get user => _user;

//   // Make sure you have a private field to hold user data
//   Map<String, dynamic>? _user;
//   String? _token;

//   String? get token => _token;
//   bool get isAuthenticated => _token != null && _token!.isNotEmpty;

//   AuthService() {
//     _loadToken();
//   }

//   Future<void> _loadToken() async {
//     _token = await _storage.read(key: _tokenKey);

//     notifyListeners();
//   }

//   Future<void> saveToken(String token) async {
//     _token = token;
//     await _storage.write(key: _tokenKey, value: token);
//     notifyListeners();
//   }

//   Future<void> clearToken() async {
//     _token = null;
//     await _storage.delete(key: _tokenKey);
//     notifyListeners();
//   }

//   Future<void> signOut() async {
//     // Implement sign out logic here, e.g., clear user data and notify listeners
//     _user = null;
//     notifyListeners();
//   }
// }

//before
//after
import 'dart:async';
import 'dart:convert';
import 'package:crmMobileUi/core/config/app_config.dart';
import 'package:dio/dio.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// import 'package:ttMobileUi/services/api_service.dart';

class AuthService extends ChangeNotifier {
  final Dio _dio = Dio();
  final baseUrl = AppConfig().apiBaseUrl;
  SingleAccountPca? _pca; // ✅ must exist at class level
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  static const String _tokenKey = "auth_token";
  static const String _usernameKey = "username";
  static const String _userDetailKey = "user_detail";

  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  String? _token;
  String? _username;
  String? get username => _username;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  AuthService() {
    // Optional: Default headers that never change
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    // _loadToken();
    _getUserDetail();
  }
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
  ///////////////
  ///

  Future<void> init() async {
    if (_pca != null) return; // Prevent re-init

    try {
      _pca = await SingleAccountPca.create(
        clientId:
            AppConfig().azureClientId, //dotenv.env['AZURE_CLIENT_ID'] ?? '',
        androidConfig: AndroidConfig(
          configFilePath: 'assets/msal_config.json',
          redirectUri:
              AppConfig().redirectUri, //dotenv.env['REDIRECT_URI'] ?? '',
        ),
        appleConfig: AppleConfig(authority: AppConfig().redirectUri),
      );

      _isInitialized = true;
      notifyListeners();
      print("✅ MSAL initialized successfully");
    } catch (e) {
      print("❌ AuthService init() error: $e");
    }
  }

  ///
  // /// Initialize MSAL Public Client Application
  // Future<void> init() async {
  //   if (_pca != null) return; // Prevent re-init
  //   _pca = await SingleAccountPca.create(
  //     clientId: dotenv.env['AZURE_CLIENT_ID']!,
  //     androidConfig: AndroidConfig(
  //       configFilePath: 'assets/msal_config.json',
  //       redirectUri: dotenv.env['REDIRECT_URI']!,
  //     ),
  //     appleConfig: AppleConfig(authority: dotenv.env['REDIRECT_URI']!),
  //   );
  //   print("✅ MSAL initialized successfully");
  // }

  /// Perform Azure AD login and save the token securely
  Future<Map<String, String?>> login() async {
    // ✅ Ensure MSAL is initialized
    if (_pca == null) {
      await init();
    }

    if (_pca == null) {
      throw Exception("MSAL PublicClientApplication not initialized");
    }

    try {
      // ✅ Clear any previous cached account before starting a new login
      try {
        await _pca?.signOut();
        print("🔄 Cleared old MSAL session before login");
      } catch (e) {
        print("⚠️ No cached account to sign out: $e");
      }
      // 🔹 Start Microsoft login flow
      final result = await _pca?.acquireToken(
        scopes: [AppConfig().azureScope],
        prompt: Prompt.selectAccount, // always show account picker
      );

      final token = result?.accessToken;

      // ✅ If MSAL gives a valid token
      if (token != null && token.isNotEmpty) {
        try {
          // Call backend to fetch user details
          await saveUserDetail(token, result!.account.toJson());

          print("✅ Login successful — token & user details saved securely");
          return {
            'token': token,
            'message': 'Login successful — Welcome ${result.account.username}',
          };
        } catch (apiError) {
          // ❌ Backend (API) failed — do not save token or proceed
          print("❌ API error during saveUserDetail: $apiError");

          String apiErrorMsg;

          if (apiError is DioError) {
            apiErrorMsg =
                apiError.response?.data['message']?.toString() ??
                apiError.message ??
                "Failed to fetch user details.";
          } else {
            apiErrorMsg = apiError.toString();
          }

          // Optionally clear the token if backend rejects it
          await clearToken();

          return {'token': null, 'message': apiErrorMsg};
        }
      } else {
        // MSAL didn’t return a valid token
        return {
          'token': null,
          'message': 'Login failed — No token received from Microsoft.',
        };
      }
    } catch (e, stackTrace) {
      // 🔹 Handle MSAL / network / user errors gracefully
      String errorMessage = e.toString();

      if (errorMessage.contains("User canceled")) {
        errorMessage = "Login cancelled by user.";
      } else if (errorMessage.contains("AADSTS")) {
        final aadMatch = RegExp(
          r"(AADSTS[0-9]+): ([^\n]+)",
        ).firstMatch(errorMessage);
        if (aadMatch != null) {
          errorMessage = "${aadMatch.group(1)} - ${aadMatch.group(2)}";
        } else {
          errorMessage = "Azure AD authentication failed.";
        }
      } else if (errorMessage.toLowerCase().contains("network")) {
        errorMessage = "Network error. Please check your connection.";
      } else if (errorMessage.isEmpty) {
        errorMessage = "An unknown error occurred.";
      }

      print("❌ Login error: $errorMessage");
      print(stackTrace);

      // ❌ Don’t call logout — just return error
      return {'token': null, 'message': errorMessage};
    }
  }

  /// Logout from Azure AD and clear local storage
  Future<void> logout() async {
    if (_pca == null) return;
    try {
      await _pca!.signOut();
      await clearToken();
      _pca = null;
      print("✅ Logout successful, token cleared from storage");
    } catch (e) {
      print("❌ Logout error: $e");
    }
  }

  // /// Load token from secure storage when app starts
  // Future<void> _loadToken() async {
  //   _token = await _storage.read(key: _tokenKey);
  //   if (_token != null && _token!.isNotEmpty) {
  //     print("🔁 Loaded token from storage");
  //   } else {
  //     print("⚠️ No token found in secure storage");
  //   }
  //   notifyListeners();
  // }

  /// Save token securely
  Future<void> saveToken(String token) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);
    notifyListeners();
  }

  // --- 🔹 Ensure Headers are Always Set Before Each Request ---
  Future<void> _setAuthHeaders() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty)
      throw Exception("User not authenticated");

    _dio.options.headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'X-Correlation-Id': generateGUID(),
      'X-Request-Id': generateGUID(),
    };
  }

  // --- 🔹 GET Helper (automatically includes headers) ---
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) async {
    await _setAuthHeaders();
    final url = '$baseUrl/$endpoint';
    print("📡 GET: $url");

    return _dio.get(url, queryParameters: queryParams);
  }

  // --- 🔹 POST Helper (automatically includes headers) ---
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
  }) async {
    await _setAuthHeaders();
    final url = '$baseUrl/$endpoint';
    print("📡 POST: $url");
    if (data != null) print("📦 Payload: ${jsonEncode(data)}");

    return _dio.post(url, data: data, queryParameters: queryParams);
  }

  // Future<void> _getUserDetail() async {
  //   _user = (await _storage.read(key: _userDetailKey)) as Map<String, dynamic>?;
  //   notifyListeners();
  // }
  Future<void> _getUserDetail() async {
    final userJson = await _storage.read(key: _userDetailKey);
    if (userJson != null && userJson.isNotEmpty) {
      _user = jsonDecode(userJson) as Map<String, dynamic>;
    } else {
      _user = null;
    }
    notifyListeners();
  }

  // --- 🔹 Save token and fetch user details ---
  Future<void> saveUserDetail(String token, Map<String, dynamic> data) async {
    _token = token;
    await _storage.write(key: _tokenKey, value: token);

    final userName = data['username'];
    if (userName == null || userName.isEmpty) {
      throw Exception("❌ Missing username in user data");
    }

    try {
      // ✅ Use your centralized GET helper
      final response = await get(
        'NetAuth/GetUserVmByUserName',
        queryParams: {'userName': userName},
      );

      print("🔍 Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        _user = userData;

        await _storage.write(key: _userDetailKey, value: jsonEncode(userData));

        print("✅ User detail saved successfully");
        notifyListeners();
      } else {
        throw Exception(
          'Failed to load user detail: ${response.statusCode} - ${response.data}',
        );
      }
    } catch (e) {
      print("❌ saveUserDetail error: $e");
      rethrow;
    }
  }

  /// Clear token and reset authentication state
  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userDetailKey);
    notifyListeners();
  }

  /// Optional: Sign out locally without Azure sign-out
  Future<void> signOut() async {
    _user = null;
    await clearToken();
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
