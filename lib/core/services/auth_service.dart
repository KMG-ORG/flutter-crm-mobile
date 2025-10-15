import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService extends ChangeNotifier {
  SingleAccountPca? _pca;
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
    try {
      // await _pca.signOut();
      // final currentAccount = await _pca.getCurrentAccount();
      //       if (currentAccount != null) {
      //         await _pca.removeAccount(currentAccount);
      //       }

      // await _pca.logout();
      // await _pca.removeAccount(currentAccount);
      final result = await _pca?.acquireToken(scopes: ['User.Read']);
      return result?.accessToken;
    } catch (e) {
      print("Login error: $e");
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
