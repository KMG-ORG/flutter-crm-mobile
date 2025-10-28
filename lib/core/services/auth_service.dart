@JS() // 👈 Must be at the top before any imports
library auth_js;

import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, ChangeNotifier;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// ✅ External JS Interop bindings (defined in index.html)
@JS('msalLogin')
external JSPromise msalLogin();

@JS('webAzureLogout')
external void webAzureLogout();

/// 🔹 AUTH SERVICE
class AuthService extends ChangeNotifier {
  SingleAccountPca? _pca;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _tokenKey = "auth_token";

  Map<String, dynamic>? _user;
  String? _token;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  AuthService() {
    _loadToken();
  }

  /// ✅ Initialize MSAL (native only)
  Future<void> init() async {
    if (!kIsWeb) {
      await initMSAL();
    } else {
      print("🌐 Skipping native MSAL init on Web");
    }
  }

  Future<void> initMSAL() async {
    try {
      await dotenv.load(fileName: ".env");

      _pca = await SingleAccountPca.create(
        clientId: dotenv.env['AZURE_CLIENT_ID']!,
        androidConfig: AndroidConfig(
          configFilePath: 'assets/msal_config.json',
          redirectUri: dotenv.env['REDIRECT_URI']!,
        ),
        appleConfig: AppleConfig(authority: dotenv.env['AUTHORITY']!),
      );

      print("✅ MSAL initialized successfully");
    } catch (e, s) {
      print("❌ MSAL init failed: $e");
      print(s);
    }
  }

  /// 🔹 Web Login via MSAL.js
  Future<String?> _loginWithMsalJs() async {
    try {
      print("🌐 Using MSAL.js for Web login...");

      // Call JS function (returns JSPromise)
      final jsPromise = msalLogin();

      // Convert JS promise to Dart Future
      final token = await jsPromise.toDart;

      print("✅ Web login token resolved: $token");

      if (token != null && token.toString().isNotEmpty) {
        await saveToken(token.toString());
        print("✅ Token saved successfully!");
        return _token;;
      } else {
        print("⚠️ No token returned from msalLogin()");
        return null;
      }
    } catch (e, s) {
      print("❌ Web MSAL Login Error: $e");
      print(s);
      return null;
    }
  }

  /// 🔹 UNIVERSAL LOGIN
  Future<String?> login() async {
    if (kIsWeb) {
      print("🌐 Detected Web — using MSAL.js flow");
      return await _loginWithMsalJs();
    }

    // ✅ Native (Android/iOS)
    if (_pca == null) {
      print("⚠️ PCA is null. Initializing MSAL...");
      await initMSAL();
      if (_pca == null) throw Exception("MSAL not initialized");
    }

    try {
      await _pca?.signOut(); // optional cleanup
      final result = await _pca?.acquireToken(
        scopes: const ["User.Read", "openid", "profile", "email"],
      );

      if (result?.accessToken != null) {
        _token = result!.accessToken;
        await saveToken(_token!);
        print("✅ Access token acquired");
        return _token;
      } else {
        print("⚠️ Access token is null");
        return null;
      }
    } catch (e, s) {
      print("❌ MSAL Login Error: $e");
      print(s);
      return null;
    }
  }

  /// 🔹 LOGOUT
  Future<void> logout() async {
    try {
      if (kIsWeb) {
        webAzureLogout(); // ✅ Call JS function
        print("🌐 Logged out (Web)");
        await clearToken();
      } else {
        await _pca?.signOut();
        print("✅ Logged out (Mobile)");
        await clearToken();
      }
    } catch (e, s) {
      print("❌ Logout error: $e");
      print(s);
    }
  }

  /// 🔹 Load Token (Web or Mobile)
  Future<void> _loadToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
    } else {
      _token = await _storage.read(key: _tokenKey);
    }
    notifyListeners();
  }

  /// 🔹 Save Token (Web or Mobile)
  Future<void> saveToken(String token) async {
    _token = token;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } else {
      await _storage.write(key: _tokenKey, value: token);
    }
    notifyListeners();
  }

  /// 🔹 Clear Token (Web or Mobile)
  Future<void> clearToken() async {
    _token = null;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } else {
      await _storage.delete(key: _tokenKey);
    }
    notifyListeners();
  }
}
