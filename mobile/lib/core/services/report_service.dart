import 'dart:convert';
import 'package:bengkel_online_flutter/core/models/report.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ReportService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/v1/';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      throw Exception('Not authenticated');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get list of reports with pagination (supports both owner and admin)
  Future<Map<String, dynamic>> getReports({
    int page = 1, 
    int perPage = 10,
    bool isAdmin = false, // New parameter to differentiate admin vs owner
  }) async {
    try {
      final headers = await _getAuthHeaders();
      
      // Use different endpoint based on user type
      final String endpoint = isAdmin 
          ? '${_baseUrl}admins/reports?page=$page&per_page=$perPage'
          : '${_baseUrl}owners/reports?page=$page&per_page=$perPage';
      
      final uri = Uri.parse(endpoint);

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Handle both nested data structure and direct data
        dynamic dataWrapper = jsonData['data'];
        
        List<dynamic> reportsList;
        int currentPage = 1;
        int lastPage = 1;
        int total = 0;
        
        if (dataWrapper is Map<String, dynamic>) {
          // Paginated response: { "data": { "data": [...], "current_page": 1, ... } }
          reportsList = (dataWrapper['data'] as List?) ?? [];
          currentPage = dataWrapper['current_page'] ?? 1;
          lastPage = dataWrapper['last_page'] ?? 1;
          total = dataWrapper['total'] ?? 0;
        } else if (dataWrapper is List) {
          // Direct list response: { "data": [...] }
          reportsList = dataWrapper;
          currentPage = 1;
          lastPage = 1;
          total = reportsList.length;
        } else {
          reportsList = [];
        }
        
        // Parse list to Report objects
        final List<Report> reports = reportsList
            .map((json) => Report.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          'reports': reports,
          'current_page': currentPage,
          'last_page': lastPage,
          'total': total,
        };
      } else {
        throw Exception('Failed to load reports: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching reports: $e');
    }
  }

  /// Submit a new report
  Future<Report> submitReport({
    required String reportType,
    required String reportData,
    String? photoBase64,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('${_baseUrl}owners/reports');

      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode({
          'report_type': reportType,
          'report_data': reportData,
          if (photoBase64 != null) 'photo': photoBase64,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        
        // Safely parse data - could be nested or direct
        dynamic reportData = jsonData['data'];
        
        if (reportData is Map<String, dynamic>) {
          return Report.fromJson(reportData);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        final dynamic errorResponse = json.decode(response.body);
        if (errorResponse is Map<String, dynamic>) {
          throw Exception(errorResponse['message'] ?? 'Failed to submit report');
        }
        throw Exception('Failed to submit report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting report: $e');
    }
  }

  /// Get specific report detail
  Future<Report> getReportDetail(String reportId) async {
    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('${_baseUrl}owners/reports/$reportId');

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Report.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load report detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching report detail: $e');
    }
  }
}
