import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/services/fcm_service.dart';
import 'package:bengkel_online_flutter/core/models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();

  User? _user;
  String? _token;
  bool _isLoggedIn = false;
  String? _authError;
  bool _mustChangePassword = false; 

  // --- GETTERS (Untuk dibaca UI) ---
  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  String? get token => _token;
  String? get authError => _authError;
  String get role => _user?.role ?? 'guest';
  bool hasRole(String r) => _user?.role == r;
  bool get mustChangePassword => _mustChangePassword;

  // Verification Getters
  bool get isEmailVerified => _user?.emailVerifiedAt != null;
  bool get isWorkshopVerified {
    // If not owner, assume true
    if (!hasRole('owner')) return true; 
    
    // Check user's first workshop status
    if (_user?.workshops == null || _user!.workshops!.isEmpty) return false; // No workshop = not verified
    
    // Suspended workshops are still "verified", just temporarily blocked
    // Only pending/rejected are considered not verified
    final status = _user!.workshops!.first.status;
    return status == 'active' || status == 'suspended';
  }
  String get workshopStatus {
      if (_user?.workshops == null || _user!.workshops!.isEmpty) return 'none';
      return _user!.workshops!.first.status;
  }
  
  /// Check if owner's workshop is suspended
  bool get isSuspended {
    if (!hasRole('owner')) return false;
    return workshopStatus == 'suspended';
  }


  /* ================= AUTH ================ */

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _authError = null;
    try {
      final response = await _apiService.register(
        name: name,
        username: username,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      final data = response['data'];
      if (data is Map<String, dynamic>) {
        _token = data['access_token'] as String?;
        final userJson = data['user'];
        if (userJson is Map<String, dynamic>) {
          _user = User.fromJson(userJson);
        }
        _mustChangePassword = _extractMustChangePassword(data, userJson);
      }
      // --- AKHIR PERBAIKAN ---

      _isLoggedIn = _token != null && _user != null;

      if (_token != null) {
        await _storage.write(key: 'auth_token', value: _token);
        FcmService.saveTokenToBackend(_token!);
      }

      notifyListeners();
      return _isLoggedIn;
    } catch (e) {
      _isLoggedIn = false;
      _authError = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      throw Exception(_authError);
    }
  }

  Future<bool> login(String email, String password) async {
    _authError = null;
    try {
      final response = await _apiService.login(email, password);

      // --- PERBAIKAN ---
      // Ambil 'data' dari response
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        _token = data['access_token'] as String?;
        final userJson = data['user'];
        if (userJson is Map<String, dynamic>) {
          _user = User.fromJson(userJson);
        }
        _mustChangePassword = _extractMustChangePassword(data, userJson);
      }
      // --- AKHIR PERBAIKAN ---

      _isLoggedIn = _token != null && _user != null;

      if (_token != null) {
        await _storage.write(key: 'auth_token', value: _token);
      }

      notifyListeners();
      return _isLoggedIn;
    } catch (e) {
      _isLoggedIn = false;
      _authError = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      throw Exception(_authError);
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _apiService.logout();
      }
    } catch (e) {
      // abaikan error logout server
    }

    _token = null;
    _user = null;
    _isLoggedIn = false;
    _authError = null;
    _mustChangePassword = false;
    await _storage.delete(key: 'auth_token');

    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final storedToken = await _storage.read(key: 'auth_token');
    if (storedToken == null) {
      _isLoggedIn = false;
      _user = null;
      _token = null;
      _mustChangePassword = false;
      notifyListeners();
      return;
    }

    _token = storedToken;
    try {
      final fetchedUser = await _apiService.fetchUser();
      _user = fetchedUser;
      _isLoggedIn = true;
      _authError = null;

      // Cek flag mustChangePassword dari data user
      _mustChangePassword = fetchedUser.mustChangePassword;

      FcmService.saveTokenToBackend(_token!); // Update FCM Token

      notifyListeners();
    } catch (e) {
      await logout(); // token invalid → bersihkan
    }
  }

  /// Dipanggil dari UbahPasswordPage setelah API sukses
  void clearMustChangePassword() {
    _mustChangePassword = false;
    notifyListeners();
  }

  Future<void> sendVerificationEmail() async {
      try {
          await _apiService.post('email/resend', {}); // Asumsi ApiService punya method helper atau pakai dio langsung
      } catch (e) {
         throw Exception("Gagal mengirim ulang email: $e");
      }
  }

  /* ============== Helpers ============== */

  bool _extractMustChangePassword(Map data, dynamic userJson) {
    // Cek di dalam 'user' object dulu
    if (userJson is Map<String, dynamic>) {
      final u1 = userJson['must_change_password'];
      if (u1 is bool) return u1;
      final u2 = userJson['mustChangePassword'];
      if (u2 is bool) return u2;
    }
    // Fallback ke top-level 'data'
    final top1 = data['must_change_password'];
    if (top1 is bool) return top1;
    final top2 = data['mustChangePassword'];
    if (top2 is bool) return top2;
    return false;
  }
}