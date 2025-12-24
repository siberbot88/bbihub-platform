import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../../core/models/staff_performance.dart';

class StaffPerformanceRepository {
  final String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Adjust if using different config
  final _storage = const FlutterSecureStorage();

  Future<List<StaffPerformance>> getStaffPerformance({String range = 'today'}) async {
    final token = await _storage.read(key: 'auth_token');

    if (token == null) {
      throw Exception('Unauthorized - Please login again');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/owners/staff/performance?range=$range'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - Server tidak merespons');
        },
      );

      print('Staff Performance Response: ${response.statusCode}');
      print('Staff Performance Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((json) => StaffPerformance.fromJson(json)).toList();
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to load staff performance');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Fitur ini memerlukan paket Premium');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized - Please login again');
      } else {
        throw Exception('Failed to load: ${response.statusCode}');
      }
    } catch (e) {
      print('Staff Performance Error: $e');
      rethrow;
    }
  }
}
