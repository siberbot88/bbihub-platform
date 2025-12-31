// core/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:bengkel_online_flutter/core/models/voucher.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'package:bengkel_online_flutter/core/models/user.dart';
import 'package:bengkel_online_flutter/core/models/workshop.dart';
import 'package:bengkel_online_flutter/core/models/workshop_document.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api/v1/';
  String get baseUrl => _baseUrl; // Added public getter
  final _storage = const FlutterSecureStorage();

  /* ===================== Common helpers ===================== */

  Future<String?> _getToken() async => _storage.read(key: 'auth_token');

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Token not found. Please login again.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> _getJsonHeaders() => {
    'Content-Type': 'application/json; charset=UTF-8',
    'Accept': 'application/json',
  };

  bool _isJsonResponse(http.Response r) =>
      (r.headers['content-type'] ?? '')
          .toLowerCase()
          .contains('application/json');

  dynamic _tryDecodeJson(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _firstChars(String s, [int max = 200]) =>
      s.length <= max ? s : '${s.substring(0, max)}...';

  String _sanitize(String input) => input
      .replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), '')
      .replaceAll('\r', ' ')
      .replaceAll('\n', ' ')
      .replaceAll('"', "'")
      .trim();

  void _debugRequest(
      String label, Uri uri, Map<String, String> headers, String? body) {
    if (kDebugMode) {
      print('[$label] ${uri.toString()}');
      // Redact sensitive data from headers
      final safeHeaders = {...headers};
      if (safeHeaders.containsKey('Authorization')) {
        safeHeaders['Authorization'] = 'Bearer ***REDACTED***';
      }
      print('[$label] headers: $safeHeaders');
      if (body != null) {
        print('[$label] body: ${_firstChars(body)}');
      }
    }
  }

  void _debugResponse(String label, http.Response response) {
    if (kDebugMode) {
      print('[$label] status: ${response.statusCode}');
      print('[$label] content-type: ${response.headers['content-type']}');
      print('[$label] body: ${_firstChars(response.body)}');
    }
  }

  // Helper untuk mengambil pesan error dengan aman dari JSON Laravel
  String _getErrorMessage(Map<String, dynamic> json) {
    // 1. Prioritaskan 'errors' object (Validasi Laravel)
    final errors = json['errors'];
    if (errors is Map) {
      final firstErrorValue = errors.values.first;
      if (firstErrorValue is List && firstErrorValue.isNotEmpty) {
        final firstError = firstErrorValue[0];
        if (firstError is String) return firstError;
      }
    }

    // 2. Fallback ke 'message' generic
    final message = json['message'];
    if (message is String) return message;

    return 'Terjadi kesalahan yang tidak diketahui';
  }

  /* ========================= AUTH ========================= */

  // Generic POST helper
  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final headers = await _getAuthHeaders();
      final bodyString = jsonEncode(body);

      _debugRequest('POST_GENERIC', uri, headers, bodyString);
      final res = await http.post(uri, headers: headers, body: bodyString);
      _debugResponse('POST_GENERIC', res);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (_isJsonResponse(res)) {
           return _tryDecodeJson(res.body);
        }
        return res.body; 
      }
      
      if (_isJsonResponse(res)) {
         final j = _tryDecodeJson(res.body);
         if (j is Map<String, dynamic>) throw Exception(_getErrorMessage(j));
      }
      throw Exception('Request failed (HTTP ${res.statusCode})');

    } catch (e) {
      throw Exception(e.toString().replaceFirst("Exception: ", ""));
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final uri = Uri.parse('${_baseUrl}auth/login');
      final headers = _getJsonHeaders();
      final body = jsonEncode({'login': email, 'password': password});

      _debugRequest('LOGIN', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('LOGIN', res);

      if (res.statusCode == 200) {
        final json = _tryDecodeJson(res.body);
        if (json is Map<String, dynamic>) return json;
        throw Exception('Respon login bukan JSON.');
      }

      final json = _tryDecodeJson(res.body);
      if (json is Map<String, dynamic>) {
        throw Exception(_getErrorMessage(json));
      }
      throw Exception('Login gagal (HTTP ${res.statusCode}).');
    } catch (e) {
      throw Exception('Gagal login: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}auth/register');
      final headers = _getJsonHeaders();
      final body = jsonEncode({
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      _debugRequest('REGISTER', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('REGISTER', res);

      if (res.statusCode == 201) {
        final json = _tryDecodeJson(res.body);
        if (json is Map<String, dynamic>) return json;
        throw Exception('Respon registrasi bukan JSON.');
      }

      final json = _tryDecodeJson(res.body);
      if (json is Map<String, dynamic>) {
        throw Exception(_getErrorMessage(json));
      }
      throw Exception('Registrasi gagal (HTTP ${res.statusCode}).');
    } catch (e) {
      throw Exception('Gagal registrasi: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      final uri = Uri.parse('${_baseUrl}auth/logout');
      final headers = await _getAuthHeaders();

      _debugRequest('LOGOUT', uri, headers, null);
      final res = await http.post(uri, headers: headers);
      _debugResponse('LOGOUT', res);

      if (res.statusCode != 200) {
        if (kDebugMode) {
          print('Server logout failed with status: ${res.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error calling API logout: $e');
      }
    }
  }

  Future<User> fetchUser() async {
    try {
      final uri = Uri.parse('${_baseUrl}auth/user');
      final headers = await _getAuthHeaders();

      _debugRequest('FETCH_USER', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('FETCH_USER', res);

      if (res.statusCode == 200 && _isJsonResponse(res)) {
        final json = _tryDecodeJson(res.body);

        if (json is Map<String, dynamic> && json['data'] is Map<String, dynamic>) {
          return User.fromJson(json['data'] as Map<String, dynamic>);
        }

        throw Exception('Respon user tidak valid.');
      } else if (res.statusCode == 401) {
        throw Exception('Unauthorized');
      }

      throw Exception('Gagal mengambil data user. Status: ${res.statusCode}');
    } catch (e) {
      throw Exception('Gagal mengambil data user: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}auth/change-password');
      final headers = await _getAuthHeaders();

      final body = jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      });

      _debugRequest('CHANGE_PASSWORD', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('CHANGE_PASSWORD', res);

      final json = _tryDecodeJson(res.body);

      if (res.statusCode == 200) {
        if (json is Map<String, dynamic> && json['message'] != null) {
          return json;
        }
        return {};
      }

      if (json is Map<String, dynamic>) {
        throw Exception(_getErrorMessage(json));
      }

      throw Exception('Gagal ganti password (HTTP ${res.statusCode}).');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /* ======================= WORKSHOP ======================= */

  Future<Workshop> createWorkshop({
    required String name,
    required String description,
    required String address,
    required String phone,
    required String email,
    required String city,
    required String province,
    required String country,
    required String postalCode,
    required double latitude,
    required double longitude,
    required String mapsUrl,
    required String openingTime,
    required String closingTime,
    required String operationalDays,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/workshops');
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'name': name,
        'description': description,
        'address': address,
        'phone': phone,
        'email': email,
        'city': city,
        'province': province,
        'country': country,
        'postal_code': postalCode,
        'latitude': latitude,
        'longitude': longitude,
        'maps_url': mapsUrl,
        'opening_time': openingTime,
        'closing_time': closingTime,
        'operational_days': operationalDays,
      });

      _debugRequest('CREATE_WORKSHOP', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('CREATE_WORKSHOP', res);

      if (res.statusCode == 201 && _isJsonResponse(res)) {
        final json = _tryDecodeJson(res.body);

        if (json is Map<String, dynamic> && json['data'] is Map<String, dynamic>) {
          return Workshop.fromJson(json['data'] as Map<String, dynamic>);
        }

        throw Exception('Respon create workshop tidak valid.');
      }

      final json = _tryDecodeJson(res.body);
      if (json is Map<String, dynamic>) {
        throw Exception(_getErrorMessage(json));
      }

      throw Exception('Gagal membuat bengkel (HTTP ${res.statusCode}).');
    } catch (e) {
      throw Exception('Gagal membuat bengkel: ${e.toString()}');
    }
  }

  Future<Workshop> updateWorkshop({
    required String id,
    required String name,
    File? photo,
    required String openingTime,
    required String closingTime,
    required String operationalDays,
    required bool isActive,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? mapsUrl,
    String? city,
    String? province,
    String? country,
    String? postalCode,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/workshops/$id');
      final token = await _getToken();
      if (token == null) throw Exception('Token not found');

      final request = http.MultipartRequest('POST', uri);

      // Method spoofing untuk Laravel
      request.fields['_method'] = 'PUT';

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.fields['name'] = name;
      request.fields['opening_time'] = openingTime;
      request.fields['closing_time'] = closingTime;
      request.fields['operational_days'] = operationalDays;
      request.fields['is_active'] = isActive ? '1' : '0';
      
      if (description != null) request.fields['description'] = description;
      if (address != null) request.fields['address'] = address;
      if (phone != null) request.fields['phone'] = phone;
      if (email != null) request.fields['email'] = email;
      if (mapsUrl != null) request.fields['maps_url'] = mapsUrl;
      if (city != null) request.fields['city'] = city;
      if (province != null) request.fields['province'] = province;
      if (country != null) request.fields['country'] = country;
      if (postalCode != null) request.fields['postal_code'] = postalCode;

      if (photo != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photo.path,
        ));
      }

      _debugRequest('UPDATE_WORKSHOP', uri, request.headers, 'Multipart fields: ${request.fields}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      _debugResponse('UPDATE_WORKSHOP', response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = _tryDecodeJson(response.body);
        if (json is Map<String, dynamic> && json['data'] is Map<String, dynamic>) {
          return Workshop.fromJson(json['data']);
        }
        throw Exception('Format respon tidak valid');
      } else {
        final json = _tryDecodeJson(response.body);
        if (json is Map<String, dynamic>) {
          throw Exception(_getErrorMessage(json));
        }
        throw Exception('Gagal update workshop (HTTP ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Gagal update workshop: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<WorkshopDocument> createDocument({
    required String workshopUuid,
    required String nib,
    required String npwp,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/documents');
      final headers = await _getAuthHeaders();
      final body =
      jsonEncode({'workshop_uuid': workshopUuid, 'nib': nib, 'npwp': npwp});

      _debugRequest('CREATE_DOCUMENT', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('CREATE_DOCUMENT', res);

      if (res.statusCode == 201 && _isJsonResponse(res)) {
        final json = _tryDecodeJson(res.body);

        if (json is Map<String, dynamic> && json['data'] is Map<String, dynamic>) {
          return WorkshopDocument.fromJson(
              json['data'] as Map<String, dynamic>);
        }

        throw Exception('Respon create document tidak valid.');
      }

      final json = _tryDecodeJson(res.body);
      if (json is Map<String, dynamic>) {
        throw Exception(_getErrorMessage(json));
      }

      throw Exception('Gagal menyimpan dokumen: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    } catch (e) {
      throw Exception('Gagal menyimpan dokumen: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /* ======================= EMPLOYEE ======================= */

  Future<Employment> createEmployee({
    required String name,
    required String username,
    required String email,
    required String role,
    required String workshopUuid,
    String? specialist,
    String? jobdesk,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/employee');
      final headers = await _getAuthHeaders();

      final bodyMap = <String, dynamic>{
        'name': name.trim(),
        'username': username.trim(),
        'email': email.trim(),
        'role': role,
        'workshop_uuid': workshopUuid,
        if (specialist != null && specialist.trim().isNotEmpty)
          'specialist': _sanitize(specialist),
        if (jobdesk != null && jobdesk.trim().isNotEmpty)
          'jobdesk': _sanitize(jobdesk),
      };
      final body = jsonEncode(bodyMap);

      _debugRequest('CREATE_EMPLOYEE', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('CREATE_EMPLOYEE', res);

      final ok = res.statusCode == 200 || res.statusCode == 201;
      if (!ok) {
        if (_isJsonResponse(res)) {
          final j = _tryDecodeJson(res.body);
          if (j is Map<String, dynamic>) {
            throw Exception(_getErrorMessage(j));
          }
        }
        throw Exception(
            'Gagal membuat karyawan (HTTP ${res.statusCode}). Body: ${_firstChars(res.body)}');
      }

      if (!_isJsonResponse(res)) throw Exception('Server mengembalikan non-JSON.');
      final decoded = _tryDecodeJson(res.body);

      final map =
      (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>)
          ? decoded['data'] as Map<String, dynamic>
          : decoded as Map<String, dynamic>;

      return Employment.fromJson(map);
    } catch (e) {
      throw Exception('Gagal membuat karyawan: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<List<Employment>> fetchOwnerEmployees({int page = 1, String? search}) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('${_baseUrl}owners/employee').replace(queryParameters: queryParams);
      final headers = await _getAuthHeaders();

      _debugRequest('FETCH_EMPLOYEES', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('FETCH_EMPLOYEES', res);

      if (res.statusCode == 401) {
        throw Exception('Akses ditolak. Silakan login kembali.');
      }

      final ok = res.statusCode == 200 || res.statusCode == 201;
      if (!ok) {
        throw Exception(
            'Gagal mengambil data employee. Status: ${res.statusCode}');
      }

      if (!_isJsonResponse(res)) throw Exception('Respon bukan JSON.');

      final decoded = _tryDecodeJson(res.body);

      // Handle pagination structure: { "data": { "data": [...] } }
      if (decoded is Map<String, dynamic>) {
        final dataWrapper = decoded['data'];

        // Case 1: Pagination wrapper
        if (dataWrapper is Map<String, dynamic> && dataWrapper.containsKey('data')) {
          final list = dataWrapper['data'];
          if (list is List) {
            return list
                .whereType<Map<String, dynamic>>()
                .map((e) => Employment.fromJson(e))
                .toList();
          }
        }

        // Case 2: Direct list (fallback)
        if (dataWrapper is List) {
          return dataWrapper
              .whereType<Map<String, dynamic>>()
              .map((e) => Employment.fromJson(e))
              .toList();
        }
      }

      // If decoded is List (old structure fallback)
      if (decoded is List) {
         return decoded
            .whereType<Map<String, dynamic>>()
            .map((e) => Employment.fromJson(e))
            .toList();
      }

      return <Employment>[];
    } catch (e) {
      throw Exception('Gagal mengambil data employee: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<Employment> updateEmployee(
      String id, {
        String? name,
        String? username,
        String? email,
        String? password,
        String? passwordConfirmation,
        String? role,
        String? specialist,
        String? jobdesk,
        String? status,
      }) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/employee/$id');
      final headers = await _getAuthHeaders();

      final map = <String, dynamic>{};
      if (name != null) map['name'] = name;
      if (username != null) map['username'] = username;
      if (email != null) map['email'] = email;
      if (password != null) map['password'] = password;
      if (passwordConfirmation != null) {
        map['password_confirmation'] = passwordConfirmation;
      }
      if (role != null) map['role'] = role;
      if (specialist != null) map['specialist'] = _sanitize(specialist);
      if (jobdesk != null) map['jobdesk'] = _sanitize(jobdesk);
      if (status != null) map['status'] = status;

      final body = jsonEncode(map);

      _debugRequest('UPDATE_EMPLOYEE', uri, headers, body);
      final res = await http.put(uri, headers: headers, body: body);
      _debugResponse('UPDATE_EMPLOYEE', res);

      if (!(res.statusCode == 200 || res.statusCode == 201)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          throw Exception(_getErrorMessage(j));
        }
        throw Exception('Gagal update karyawan (HTTP ${res.statusCode}).');
      }

      if (!_isJsonResponse(res)) throw Exception('Respon update bukan JSON.');
      final j = _tryDecodeJson(res.body);

      if (j is Map<String, dynamic> && j['data'] is Map<String, dynamic>) {
        return Employment.fromJson(j['data'] as Map<String, dynamic>);
      }

      throw Exception('Respon update bukan objek JSON.');
    } catch (e) {
      throw Exception('Gagal update karyawan: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<void> updateEmployeeStatus(String id, String status) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/employee/$id/status');
      final headers = await _getAuthHeaders();
      final body = jsonEncode({'status': status});

      _debugRequest('UPDATE_EMP_STATUS', uri, headers, body);
      final res = await http.patch(uri, headers: headers, body: body);
      _debugResponse('UPDATE_EMP_STATUS', res);

      if (!(res.statusCode == 200 || res.statusCode == 204)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          throw Exception(_getErrorMessage(j));
        }
        throw Exception('Gagal mengubah status (HTTP ${res.statusCode}).');
      }
    } catch (e) {
      throw Exception('Gagal mengubah status: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/employee/$id');
      final headers = await _getAuthHeaders();

      _debugRequest('DELETE_EMPLOYEE', uri, headers, null);
      final res = await http.delete(uri, headers: headers);
      _debugResponse('DELETE_EMPLOYEE', res);

      if (res.statusCode != 204) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          throw Exception(_getErrorMessage(j));
        }
        throw Exception('Gagal menghapus karyawan (HTTP ${res.statusCode}).');
      }
    } catch (e) {
      throw Exception('Gagal menghapus karyawan: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /* ======================== SERVICES ======================= */
  //
  // 1) fetchServicesRaw  -> dipakai untuk pagination (mengembalikan map lengkap Laravel paginator)
  // 2) fetchServices     -> kompatibel lama, hanya list<ServiceModel> (pakai owners/services)
  // 3) fetchServiceDetail, updateServiceStatus, createServiceDummy

  /// PANGGILAN BARU: untuk pagination (dipakai ServiceProvider di ListWorkPage)
  Future<Map<String, dynamic>> fetchServicesRaw({
    String? status,
    bool includeExtras = true,
    String? workshopUuid,
    String? code,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 10,
    String? type,
    String? dateColumn,
    String? search, // Added search param
    String? acceptanceStatus,
    bool useScheduleEndpoint = true, 
  }) async {
    try {
      final params = <String, String>{};
      if (includeExtras) params['include'] = 'extras';
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (workshopUuid != null && workshopUuid.isNotEmpty) {
        params['workshop_uuid'] = workshopUuid;
      }
      if (code != null && code.isNotEmpty) params['code'] = code;
      if (dateFrom != null && dateFrom.isNotEmpty) params['date_from'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) params['date_to'] = dateTo;
      if (type != null && type.isNotEmpty) params['type'] = type;
      if (dateColumn != null && dateColumn.isNotEmpty) params['date_column'] = dateColumn;
      if (dateColumn != null && dateColumn.isNotEmpty) params['date_column'] = dateColumn;
      if (search != null && search.isNotEmpty) params['search'] = search; // Handle search
      if (acceptanceStatus != null) params['filter[acceptance_status]'] = acceptanceStatus;

      params['page'] = page.toString();
      params['per_page'] = perPage.toString();

      // route: owners/services (sesuai backend yang Anda pakai)
      final uri = Uri.parse('${_baseUrl}owners/services')
          .replace(queryParameters: params);
      final headers = await _getAuthHeaders();

      _debugRequest('FETCH_SERVICES_RAW', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('FETCH_SERVICES_RAW', res);

      if (!(res.statusCode == 200 || res.statusCode == 201)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          throw Exception(_getErrorMessage(j));
        }
        throw Exception(
            'Gagal mengambil data service (HTTP ${res.statusCode}).');
      }

      if (!_isJsonResponse(res)) throw Exception('Respon bukan JSON.');

      final j = _tryDecodeJson(res.body);
      if (j is Map<String, dynamic>) {
        return j;
      }

      throw Exception('Respon layanan tidak valid.');
    } catch (e) {
      throw Exception('Gagal mengambil data service: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /// Fungsi lama: ambil list ServiceModel saja (tanpa paging di sisi client)
  Future<List<ServiceModel>> fetchServices({
    String? status,
    bool includeExtras = true,
    String? workshopUuid,
    String? code,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final params = <String, String>{};
      if (includeExtras) params['include'] = 'extras';
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (workshopUuid != null && workshopUuid.isNotEmpty) {
        params['workshop_uuid'] = workshopUuid;
      }
      if (code != null && code.isNotEmpty) params['code'] = code;
      if (dateFrom != null && dateFrom.isNotEmpty) params['date_from'] = dateFrom;
      if (dateTo != null && dateTo.isNotEmpty) params['date_to'] = dateTo;

      final uri = Uri.parse('${_baseUrl}owners/services')
          .replace(queryParameters: params);
      final headers = await _getAuthHeaders();

      _debugRequest('FETCH_SERVICES', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('FETCH_SERVICES', res);

      if (!(res.statusCode == 200 || res.statusCode == 201)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          throw Exception(_getErrorMessage(j));
        }
        throw Exception(
            'Gagal mengambil data service (HTTP ${res.statusCode}).');
      }

      if (!_isJsonResponse(res)) throw Exception('Respon bukan JSON.');

      final j = _tryDecodeJson(res.body);

      final list = (j is Map && j['data'] is List)
          ? (j['data'] as List)
          : (j is List ? j : const []);

      return list
          .whereType<Map<String, dynamic>>()
          .map(ServiceModel.fromJson)
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil data service: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<ServiceModel> fetchServiceDetail(String id) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/services/$id');
      final headers = await _getAuthHeaders();

      _debugRequest('SERVICE_DETAIL', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('SERVICE_DETAIL', res);

      if (!(res.statusCode == 200 || res.statusCode == 201)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          throw Exception(_getErrorMessage(j));
        }
        throw Exception(
            'Gagal mengambil detail service (HTTP ${res.statusCode}).');
      }

      if (!_isJsonResponse(res)) throw Exception('Respon bukan JSON.');

      final j = _tryDecodeJson(res.body);

      final map = (j is Map && j['data'] is Map)
          ? Map<String, dynamic>.from(j['data'])
          : Map<String, dynamic>.from(j as Map);

      return ServiceModel.fromJson(map);
    } catch (e) {
      throw Exception('Gagal mengambil detail service: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /* ================= OWNER SUBSCRIPTION ================ */

  // Checkout Subscription
  Future<Map<String, dynamic>> checkoutSubscription({
    required String planId,
    required String billingCycle,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}owner/subscription/checkout');
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'plan_id': planId,
        'billing_cycle': billingCycle,
      });

      _debugRequest('CHECKOUT_SUB', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('CHECKOUT_SUB', res);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final json = _tryDecodeJson(res.body);
        if (json is Map<String, dynamic> && json['data'] != null) {
          return json['data'];
        }
      }

      final json = _tryDecodeJson(res.body);
      if (json is Map<String, dynamic>) {
        throw Exception(_getErrorMessage(json));
      }
      throw Exception('Checkout gagal (HTTP ${res.statusCode}).');
    } catch (e) {
      throw Exception('Gagal checkout: ${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<void> updateServiceStatus(String id, String status) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/services/$id');
      final headers = await _getAuthHeaders();
      final body = jsonEncode({'status': status});

      _debugRequest('UPDATE_SERVICE', uri, headers, body);
      final res = await http.patch(uri, headers: headers, body: body);
      _debugResponse('UPDATE_SERVICE', res);

      if (!(res.statusCode == 200 || res.statusCode == 204)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          throw Exception(_getErrorMessage(j));
        }
        throw Exception('Gagal update status (HTTP ${res.statusCode}).');
      }
    } catch (e) {
      throw Exception('Gagal update status: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<ServiceModel> createServiceDummy({
    required String workshopUuid,
    String? customerUuid,
    String? vehicleUuid,
    required String name,
    String? description,
    num? price,
    required DateTime scheduledDate,
    DateTime? estimatedTime,
    String status = 'pending',
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/services');
      final headers = await _getAuthHeaders();
      final body = jsonEncode({
        'workshop_uuid': workshopUuid,
        if (customerUuid != null) 'customer_uuid': customerUuid,
        if (vehicleUuid != null) 'vehicle_uuid': vehicleUuid,
        'name': name,
        'description': description,
        'price': price,
        'scheduled_date': scheduledDate.toIso8601String(),
        if (estimatedTime != null)
          'estimated_time': estimatedTime.toIso8601String(),
        'status': status,
      });

      _debugRequest('CREATE_SERVICE', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('CREATE_SERVICE', res);

      if (!(res.statusCode == 200 || res.statusCode == 201)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          throw Exception(_getErrorMessage(j));
        }
        throw Exception('Gagal membuat service (HTTP ${res.statusCode}).');
      }

      if (!_isJsonResponse(res)) throw Exception('Respon bukan JSON.');
      final j = _tryDecodeJson(res.body);

      final map = (j is Map && j['data'] is Map)
          ? j['data'] as Map<String, dynamic>
          : j as Map<String, dynamic>;

      return ServiceModel.fromJson(map);
    } catch (e) {
      throw Exception('Gagal membuat service: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  /* ======================== VOUCHER ======================= */

  Future<List<Voucher>> fetchVouchers({String? status}) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/vouchers')
          .replace(queryParameters: status != null ? {'status': status} : {});

      final headers = await _getAuthHeaders();
      _debugRequest('FETCH_VOUCHERS', uri, headers, null);

      final res = await http.get(uri, headers: headers);
      _debugResponse('FETCH_VOUCHERS', res);

      if (res.statusCode == 200 && _isJsonResponse(res)) {
        final j = _tryDecodeJson(res.body);
        final list = (j is Map && j['data'] is List)
            ? (j['data'] as List)
            : (j is List ? j : const []);

        return list
            .whereType<Map<String, dynamic>>()
            .map(Voucher.fromJson)
            .toList();
      }
      throw Exception('Gagal mengambil data voucher (HTTP ${res.statusCode})');
    } catch (e) {
      throw Exception('Error fetch vouchers: $e');
    }
  }

  Future<bool> createVoucher({
    required String workshopUuid,
    required String title,
    required String codeVoucher,
    required String discountValue,
    required String quota,
    required String minTransaction,
    required String validFrom, // yyyy-MM-dd
    required String validUntil, // yyyy-MM-dd
    File? image,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/vouchers');
      final headers = await _getAuthHeaders();
      headers.remove('Content-Type'); // Multipart set boundary sendiri

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields['workshop_uuid'] = workshopUuid;
      request.fields['title'] = title;
      request.fields['code_voucher'] = codeVoucher;
      request.fields['discount_value'] = discountValue;
      request.fields['quota'] = quota;
      request.fields['min_transaction'] = minTransaction;
      request.fields['valid_from'] = validFrom;
      request.fields['valid_until'] = validUntil;
      request.fields['is_active'] = '1';

      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

      _debugRequest(
          'CREATE_VOUCHER', uri, headers, request.fields.toString());

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);
      _debugResponse('CREATE_VOUCHER', res);

      if (res.statusCode == 201) return true;

      final j = _tryDecodeJson(res.body);
      if (j is Map<String, dynamic>) {
        throw Exception(_getErrorMessage(j));
      }
      throw Exception('Gagal membuat voucher (HTTP ${res.statusCode})');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<bool> updateVoucher({
    required String id,
    required String title,
    required String codeVoucher,
    required String discountValue,
    required String quota,
    required String minTransaction,
    required String validFrom,
    required String validUntil,
    File? image,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/vouchers/$id');
      final headers = await _getAuthHeaders();
      headers.remove('Content-Type');

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.fields['_method'] = 'PATCH';
      request.fields['title'] = title;
      request.fields['code_voucher'] = codeVoucher;
      request.fields['discount_value'] = discountValue;
      request.fields['quota'] = quota;
      request.fields['min_transaction'] = minTransaction;
      request.fields['valid_from'] = validFrom;
      request.fields['valid_until'] = validUntil;

      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', image.path));
      }

      _debugRequest(
          'UPDATE_VOUCHER', uri, headers, request.fields.toString());

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);
      _debugResponse('UPDATE_VOUCHER', res);

      if (res.statusCode == 200) return true;

      final j = _tryDecodeJson(res.body);
      if (j is Map<String, dynamic>) {
        throw Exception(_getErrorMessage(j));
      }
      throw Exception('Gagal update voucher (HTTP ${res.statusCode})');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<bool> deleteVoucher(String id) async {
    try {
      final uri = Uri.parse('${_baseUrl}owners/vouchers/$id');
      final headers = await _getAuthHeaders();

      final res = await http.delete(uri, headers: headers);

      if (res.statusCode == 204) return true;
      throw Exception('Gagal menghapus voucher (HTTP ${res.statusCode})');
    } catch (e) {
      throw Exception('Error delete voucher: $e');
    }
  }

  /* ======================= SUBSCRIPTION ======================= */

  Future<void> cancelSubscription() async {
    try {
      final uri = Uri.parse('${_baseUrl}owner/subscription/cancel');
      final headers = await _getAuthHeaders();

      _debugRequest('CANCEL_SUBSCRIPTION', uri, headers, null);
      final res = await http.post(uri, headers: headers);
      _debugResponse('CANCEL_SUBSCRIPTION', res);

      if (res.statusCode != 200) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          throw Exception(_getErrorMessage(j));
        }
        throw Exception('Gagal membatalkan langganan (HTTP ${res.statusCode}).');
      }
    } catch (e) {
      throw Exception('Gagal membatalkan langganan: '
          '${e.toString().replaceFirst("Exception: ", "")}');
    }
  }

  Future<void> checkSubscriptionStatus() async {
    try {
      final uri = Uri.parse('${_baseUrl}owner/subscription/check-status');
      final headers = await _getAuthHeaders();

      _debugRequest('CHECK_SUB_STATUS', uri, headers, null);
      final res = await http.post(uri, headers: headers);
      _debugResponse('CHECK_SUB_STATUS', res);

      if (res.statusCode != 200) {
        throw Exception('Gagal memperbarui status (HTTP ${res.statusCode}).');
      }
    } catch (e) {
      throw Exception('Gagal cek status: ${e.toString()}');
    }
  }  // =======================================================================
  // ADMIN SERVICE METHODS (Proxies to generic endpoints with specific logic)
  // =======================================================================

  Future<Map<String, dynamic>> adminFetchServicesRaw({
    String? status,
    bool includeExtras = true,
    String? workshopUuid,
    String? code,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int perPage = 10,
    String? type,
    String? dateColumn,
    String? search, // Added search param
    String? acceptanceStatus,
    bool useScheduleEndpoint = true, // New param to control endpoint
  }) async {
    try {
      // Use /schedule for grouped format (scheduling page)
      // Use /services for flat pagination (history page)
      final endpoint = useScheduleEndpoint
          ? 'admins/services/schedule'
          : 'admins/services';

      final uri = Uri.parse('${_baseUrl}$endpoint').replace(
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
          if (status != null && status != 'all') 'filter[status]': status,
          if (workshopUuid != null) 'filter[workshop_uuid]': workshopUuid,
          if (code != null) 'filter[code]': code,
          if (dateFrom != null) 'date_from': dateFrom,
          if (dateTo != null) 'date_to': dateTo,
          if (type != null) 'filter[type]': type,
          if (dateColumn != null) 'date_column': dateColumn,
          if (dateColumn != null) 'date_column': dateColumn,
          if (search != null && search.isNotEmpty) 'filter[search]': search, // Send filter[search]
          if (acceptanceStatus != null) 'filter[acceptance_status]': acceptanceStatus,
        },
      );

      final headers = await _getAuthHeaders();
      _debugRequest('ADMIN_FETCH_SERVICES', uri, headers, null);

      final res = await http.get(uri, headers: headers);
      _debugResponse('ADMIN_FETCH_SERVICES', res);

      if (res.statusCode == 200) {
        final json = _tryDecodeJson(res.body);
        if (json is Map<String, dynamic>) return json;
        throw Exception('Response is not valid JSON');
      }

      final json = _tryDecodeJson(res.body);
      if (json is Map<String, dynamic>) {
        throw Exception(_getErrorMessage(json));
      }
      throw Exception('Failed to fetch admin services (HTTP ${res.statusCode})');
    } catch (e) {
      throw Exception('Failed to fetch admin services: ${e.toString()}');
    }
  }

  /// Fetch ACTIVE (in-progress + completed) services for logging/pencatatan
  /// GET /v1/admins/services/active
  Future<Map<String, dynamic>> adminFetchActiveServices({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}admins/services/active').replace(queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      });

      final res = await http.get(uri, headers: await _getAuthHeaders());

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      throw Exception('Failed to fetch active services (HTTP ${res.statusCode})');
    } catch (e) {
      throw Exception('Failed to fetch active services: ${e.toString()}');
    }
  }

  /// Complete service (mark as completed)
  /// PATCH /v1/admins/services/{id}/complete
  Future<Map<String, dynamic>> adminCompleteService(String serviceId) async {
    try {
      final uri = Uri.parse('${_baseUrl}admins/services/$serviceId/complete');
      final res = await http.patch(uri, headers: await _getAuthHeaders());

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      throw Exception('Failed to complete service (HTTP ${res.statusCode})');
    } catch (e) {
      throw Exception('Failed to complete service: ${e.toString()}');
    }
  }

  /// Create invoice for service
  /// POST /v1/admins/services/{id}/invoice
  Future<Map<String, dynamic>> adminCreateInvoice(
    String serviceId, {
    required List<Map<String, dynamic>> items,
    double? tax,
    double? discount,
    String? notes,
  }) async {
    try {
      final uri = Uri.parse('${_baseUrl}admins/services/$serviceId/invoice');
      final body = {
        'items': items,
        if (tax != null) 'tax': tax,
        if (discount != null) 'discount': discount,
        if (notes != null) 'notes': notes,
      };

      final res = await http.post(
        uri,
        headers: await _getAuthHeaders(),
        body: jsonEncode(body),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      throw Exception('Failed to create invoice (HTTP ${res.statusCode}): ${res.body}');
    } catch (e) {
      throw Exception('Failed to create invoice: ${e.toString()}');
    }
  }

  /// Process cash payment for invoice
  /// POST /v1/admins/invoices/{id}/cash-payment
  Future<Map<String, dynamic>> adminProcessCashPayment(
    String invoiceId,
    double amountPaid,
  ) async {
    try {
      final uri = Uri.parse('${_baseUrl}admins/invoices/$invoiceId/cash-payment');
      final body = {'amount_paid': amountPaid};

      final res = await http.post(
        uri,
        headers: await _getAuthHeaders(),
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
      throw Exception('Failed to process payment (HTTP ${res.statusCode}): ${res.body}');
    } catch (e) {
      throw Exception('Failed to process payment: ${e.toString()}');
    }
  }

  Future<ServiceModel> adminFetchServiceDetail(String id) {
    return fetchServiceDetail(id);
  }

  Future<void> adminAcceptService(String id, {String? mechanicUuid}) async {
    final body = {
      if (mechanicUuid != null) 'mechanic_uuid': mechanicUuid,
    };
    
    final uri = Uri.parse('${_baseUrl}admins/services/$id/accept');
    final response = await http.post(
      uri,
      headers: await _getAuthHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(jsonDecode(response.body)));
    }
  }

  Future<void> adminDeclineService(String id, {required String reason, String? reasonDescription}) async {
    final body = {
      'reason': reason, // Backend expects 'reason'
      if (reasonDescription != null) 'reason_description': reasonDescription,
    };

    final uri = Uri.parse('${_baseUrl}admins/services/$id/decline');
    final response = await http.post(
      uri,
      headers: await _getAuthHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(jsonDecode(response.body)));
    }
  }

  Future<void> adminAssignMechanic(String id, {required String mechanicUuid}) async {
    final body = {
      'mechanic_uuid': mechanicUuid,
    };

    final uri = Uri.parse('${_baseUrl}admins/services/$id/assign-mechanic');
    
    // Fix: Use POST and correct endpoint
    final response = await http.post(
      uri,
      headers: await _getAuthHeaders(), // Use auth headers
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(_getErrorMessage(jsonDecode(response.body)));
    }
  }

  // Updated signature to inclue vehicle details
  Future<void> adminCreateWalkInService({
    required String customerName,
    required String customerPhone,
    required String vehicleBrand,
    required String vehicleModel,
    required String vehiclePlate,
    required String vehicleYear,
    required String vehicleColor,
    required String vehicleCategory, // 'motor' or 'mobil'
    required String serviceName,
    String? serviceDescription,
    File? image,
  }) async {
    final uri = Uri.parse('${_baseUrl}admins/services/walk-in');
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    request.fields['customer_name'] = customerName;
    request.fields['customer_phone'] = customerPhone;
    request.fields['vehicle_brand'] = vehicleBrand;
    request.fields['vehicle_model'] = vehicleModel;
    request.fields['vehicle_plate'] = vehiclePlate;
    request.fields['vehicle_year'] = vehicleYear;
    request.fields['vehicle_color'] = vehicleColor;
    request.fields['vehicle_category'] = vehicleCategory.toLowerCase();
    request.fields['service_name'] = serviceName;
    request.fields['service_description'] = serviceDescription ?? '';
    request.fields['status'] = 'pending';
    // Use Jakarta timezone (UTC+7 / WIB)
    final jakartaTime = DateTime.now().toUtc().add(const Duration(hours: 7));
    request.fields['scheduled_date'] = jakartaTime.toIso8601String();

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        image.path,
      ));
    }

    _debugRequest('CREATE_WALKIN', uri, request.headers, 'Multipart body: ${request.fields}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    _debugResponse('CREATE_WALKIN', response);

    if (response.statusCode != 201 && response.statusCode != 200) {
       throw Exception(_getErrorMessage(jsonDecode(response.body)));
    }
  }

  Future<void> adminDeleteService(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/services/$id'),
      headers: await _getAuthHeaders(),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      // 204 No Content is typical for delete, but sometimes 200
      throw Exception(_getErrorMessage(jsonDecode(response.body)));
    }
  }



  /* ====================== NOTIFICATIONS ====================== */

  Future<Map<String, dynamic>> fetchNotifications({int page = 1}) async {
    try {
      final uri = Uri.parse('${_baseUrl}notifications?page=$page');
      final headers = await _getAuthHeaders();

      _debugRequest('FETCH_NOTIFICATIONS', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('FETCH_NOTIFICATIONS', res);

      if (res.statusCode == 200 && _isJsonResponse(res)) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          return j; 
        }
      }
      throw Exception('Gagal mengambil notifikasi (HTTP ${res.statusCode})');
    } catch (e) {
      throw Exception('Gagal mengambil notifikasi: ${e.toString()}');
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final uri = Uri.parse('${_baseUrl}notifications/unread-count');
      final headers = await _getAuthHeaders();

      final res = await http.get(uri, headers: headers);
      
      if (res.statusCode == 200) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic> && j['data'] is Map) {
          return j['data']['count'] ?? 0;
        }
      }
      return 0;
    } catch (e) {
      return 0; 
    }
  }

  Future<void> markNotificationRead(String id) async {
    try {
      final uri = Uri.parse('${_baseUrl}notifications/mark-read');
      final headers = await _getAuthHeaders();
      final body = jsonEncode({'id': id});

      _debugRequest('MARK_READ', uri, headers, body);
      final res = await http.post(uri, headers: headers, body: body);
      _debugResponse('MARK_READ', res);

      if (res.statusCode != 200) {
        throw Exception('Gagal mengubah status notifikasi');
      }
    } catch (e) {
      throw Exception('Gagal mark read: ${e.toString()}');
    }
  }

  /// ADMIN: Fetch mechanics (employees with mechanic role)
  /// GET /admins/mechanics
  Future<Map<String, dynamic>> adminFetchMechanics() async {
    try {
      final uri = Uri.parse('${_baseUrl}admins/mechanics');
      final headers = await _getAuthHeaders();

      _debugRequest('ADMIN_FETCH_MECHANICS', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('ADMIN_FETCH_MECHANICS', res);

      if (res.statusCode == 200) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          return j;
        }
      }
      
      final j = _tryDecodeJson(res.body);
      if (j is Map<String, dynamic>) {
          throw Exception(_getErrorMessage(j));
      }
    throw Exception('Gagal mengambil data mekanik (HTTP ${res.statusCode})');
    } catch (e) {
      throw Exception('Gagal mengambil data mekanik: $e');
    }
  }

  /// ADMIN: Fetch mechanic performance
  /// GET /admins/mechanics/performance?range=today
  Future<Map<String, dynamic>> adminFetchMechanicPerformance({String range = 'today'}) async {
    try {
      final uri = Uri.parse('${_baseUrl}admins/mechanics/performance').replace(queryParameters: {'range': range});
      final headers = await _getAuthHeaders();

      _debugRequest('ADMIN_FETCH_MECH_PERF', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('ADMIN_FETCH_MECH_PERF', res);

      if (res.statusCode == 200) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          return j;
        }
      }

      throw Exception('Gagal mengambil performa mekanik (HTTP ${res.statusCode})');
    } catch (e) {
      throw Exception('Gagal mengambil performa mekanik: $e');
    }
  }

  Future<Map<String, dynamic>> adminFetchInvoiceByServiceId(String serviceId) async {
    try {
      // Endpoint: GET /api/v1/admins/services/{id}/invoice
      // Note: Make sure backend route uses 'admins' or 'admin' correctly.
      // Based on ServiceLoggingController it is usually under 'admin' prefix but user used 'admins' in other calls.
      // Let's try 'admins' consistent with other admin methods here first.
      // Wait, ServiceLoggingController usually maps to /admin/services...
      // I'll check route list if possible, but let's guess 'admins' based on ApiService trend.
      // Actually ServiceLoggingController usually is under `apiResource('services')`.
      final uri = Uri.parse('${_baseUrl}admins/services/$serviceId/invoice');
      final headers = await _getAuthHeaders();

      final res = await http.get(uri, headers: headers);
      
      if (res.statusCode == 200) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic> && j['data'] is Map) {
             return j['data'];
        }
      }
      throw Exception('Invoice tidak ditemukan');
    } catch (e) {
      rethrow;
    }
  }

  /* ================= ADMIN DASHBOARD ================= */

  /// GET /api/v1/admins/dashboard
  Future<Map<String, dynamic>> adminFetchDashboard() async {
    try {
      final uri = Uri.parse('${_baseUrl}admins/dashboard');
      final headers = await _getAuthHeaders();
      
      _debugRequest('ADMIN_DASHBOARD', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('ADMIN_DASHBOARD', res);

      if (res.statusCode == 200) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          return j;
        }
      }
      throw Exception('Failed to fetch dashboard (HTTP ${res.statusCode})');
    } catch (e) {
      throw Exception('Failed to fetch dashboard: $e');
    }
  }

  /// GET /api/v1/admins/dashboard/stats
  Future<Map<String, dynamic>> adminFetchDashboardStats({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final params = <String, String>{};
      if (dateFrom != null) params['date_from'] = dateFrom;
      if (dateTo != null) params['date_to'] = dateTo;

      final uri = Uri.parse('${_baseUrl}admins/dashboard/stats')
          .replace(queryParameters: params);
      final headers = await _getAuthHeaders();
      
      _debugRequest('ADMIN_DASHBOARD_STATS', uri, headers, null);
      final res = await http.get(uri, headers: headers);
      _debugResponse('ADMIN_DASHBOARD_STATS', res);

      if (res.statusCode == 200) {
        final j = _tryDecodeJson(res.body);
        if (j is Map<String, dynamic>) {
          return j;
        }
      }
      throw Exception('Failed to fetch dashboard stats (HTTP ${res.statusCode})');
    } catch (e) {
      throw Exception('Failed to fetch dashboard stats: $e');
    }
  }

}
