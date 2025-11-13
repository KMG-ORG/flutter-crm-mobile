import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  late final String apiBaseUrl;
  late final String azureClientId;
  late final String azureAuthority;
  late final String azureScope;
  late final String redirectUri;

  /// Load environment variables safely
  Future<void> load() async {
    await dotenv.load(fileName: ".env");

    apiBaseUrl = _require('API_BASE_URL');
    azureClientId = _require('AZURE_CLIENT_ID');
    azureAuthority = _require('AZURE_AUTHORITY');
    azureScope = _require('AZURE_SCOPES');
    redirectUri = _require('REDIRECT_URI');
  }

  /// Throws clear error if key missing or empty
  String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw Exception("❌ Missing environment variable: $key in .env file");
    }
    return value;
  }
}
