import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb, ChangeNotifier;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  Future<void> init() async {
    try {
      Map<String, dynamic> config = {};

      // ✅ Platform-specific config loading
      if (kIsWeb) {
        final jsonString = await rootBundle.loadString(
          'assets/msal_config.json',
        );
        config = json.decode(jsonString);
      } else {
        await dotenv.load(fileName: ".env");
        config = {
          "client_id": dotenv.env['AZURE_CLIENT_ID'],
          "redirect_uri": dotenv.env['REDIRECT_URI'],
          "authority": dotenv.env['AUTHORITY'],
        };
      }

      // ✅ Assign PCA instance
      _pca = await SingleAccountPca.create(
        clientId: dotenv.env['AZURE_CLIENT_ID']!,
        androidConfig: AndroidConfig(
          configFilePath: 'assets/msal_config.json',
          redirectUri: dotenv.env['REDIRECT_URI']!,
        ),
        appleConfig: AppleConfig(authority: dotenv.env['REDIRECT_URI']!),
      );

      print("✅ MSAL initialized successfully");
    } catch (e, s) {
      print("❌ MSAL init failed: $e");
      print(s);
    }
  }

  Future<String?> login() async {
    if (_pca == null) {
      print("⚠️ PCA is null. Trying to initialize...");
      await init();
      if (_pca == null)
        throw Exception("MSAL PublicClientApplication not initialized");
    }

    try {
      await _pca?.signOut(); // clear existing session (optional)
      final result = await _pca?.acquireToken(
        scopes: [dotenv.env['AZURE_SCOPES'] ?? 'user.read'],
      );

      if (result?.accessToken != null) {
        _token = result!.accessToken;
        await saveToken(_token!);
        print("✅ Access token acquired");
      } else {
        print("⚠️ Access token is null");
      }

      return result?.accessToken;
    } catch (e) {
      print("❌ Login error: $e");
      return null;
    }
  }

  Future<void> logout() async {
    if (_pca == null) return;
    try {
      await _pca!.signOut();
      await clearToken();
      print("✅ Logout successful");
    } catch (e) {
      print("❌ Logout error: $e");
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

  Future<void> clearToken() async {
    _token = null;
    await _storage.delete(key: _tokenKey);
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }
}
