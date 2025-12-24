import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../feature/owner/widgets/report/report_data.dart';


class AnalyticsRepository {
  static const String _baseUrl = 'http://10.0.2.2:8000'; // Android emulator localhost

  /// Fetch analytics data from backend API
  /// 
  /// [range] - 'daily', 'weekly', or 'monthly'
  /// [token] - Bearer authentication token
  Future<ReportData> getAnalytics({
    required String range,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/v1/owners/analytics/report?range=$range');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          return ReportData.fromJson(jsonData['data'], range);
        } else {
          throw Exception('Invalid response format from server');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        final jsonData = json.decode(response.body);
        throw Exception(jsonData['message'] ?? 'Bad request');
      } else {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Get analytics with automatic token retrieval from storage
  Future<ReportData> getAnalyticsWithAuth({
    required String range,
  }) async {
    try {
      // Get token from secure storage
      final storage = const FlutterSecureStorage();
      final token = await storage.read(key: 'auth_token');
      
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please login.');
      }

      return await getAnalytics(range: range, token: token);
    } catch (e) {
      rethrow;
    }
  }
}
