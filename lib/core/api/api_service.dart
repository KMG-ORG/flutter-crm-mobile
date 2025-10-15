import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: dotenv.env['API_BASE_URL']!));

  /// Set token for authenticated requests
  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Example: Get leads
  Future<Response> getLeads() async {
    return await _dio.get('/leads');
  }

  /// Example: Get dashboard data
  Future<Response> getDashboardData() async {
    return await _dio.get('/dashboard');
  }
}
