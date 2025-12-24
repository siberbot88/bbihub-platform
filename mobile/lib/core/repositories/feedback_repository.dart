import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';
import '../models/feedback_model.dart';

class FeedbackRepository {
  final ApiService _apiService = ApiService();

  Future<FeedbackResponse> getFeedback({int page = 1, String filter = 'semua'}) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    
    final baseUrl = _apiService.baseUrl;
    
    String url = '$baseUrl/owners/feedback?page=$page';
    if (filter != 'semua') {
      url += '&filter=$filter';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        return FeedbackResponse.fromJson(json);
      }
    }
    
    throw Exception('Failed to load feedback');
  }
}
