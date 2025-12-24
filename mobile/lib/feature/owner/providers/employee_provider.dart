import 'package:flutter/foundation.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';

class EmployeeProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _loading = false;
  String? _lastError;
  List<Employment> _items = [];

  bool get loading => _loading;
  String? get lastError => _lastError;
  List<Employment> get items => List.unmodifiable(_items);

  Future<void> fetchOwnerEmployees({int page = 1, String? search}) async {
    _loading = true;
    _lastError = null;
    notifyListeners();
    try {
      final list = await _api.fetchOwnerEmployees(page: page, search: search);
      // Jika page > 1, mungkin perlu append. Tapi untuk sekarang replace dulu sesuai request "ambil list dari page 1"
      // Atau jika user implement infinite scroll nanti, logic ini bisa diubah.
      _items = list;
    } catch (e) {
      if (e.toString().contains('403')) {
        // Suppress 403 errors (Premium access required)
        _items = [];
        _lastError = null; // Don't expose error to UI
        debugPrint('fetchOwnerEmployees: blocked by premium check (403)');
      } else {
        _lastError = e.toString();
        debugPrint('fetchOwnerEmployees error: $e');
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<Employment> createEmployee({
    required String name,
    required String username,
    required String email,
    required String role,
    required String workshopUuid,
    String? specialist,
    String? jobdesk,
  }) async {
    _lastError = null;
    try {
      final emp = await _api.createEmployee(
        name: name,
        username: username,
        email: email,
        role: role,
        workshopUuid: workshopUuid,
        specialist: specialist,
        jobdesk: jobdesk,
      );
      upsert(emp);
      return emp;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
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
        String? status, // 'active' / 'inactive'
      }) async {
    _lastError = null;
    try {
      final emp = await _api.updateEmployee(
        id,
        name: name,
        username: username,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
        specialist: specialist,
        jobdesk: jobdesk,
        status: status,
      );
      upsert(emp);
      return emp;
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    }
  }

  Future<void> toggleStatus(String id, bool active) async {
    _lastError = null;
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final prev = _items[idx];
    final optimistic = prev.copyWith(status: active ? 'active' : 'inactive');
    _items[idx] = optimistic;
    notifyListeners();

    try {
      await _api.updateEmployeeStatus(id, active ? 'active' : 'inactive');
    } catch (e) {
      // rollback
      _items[idx] = prev;
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEmployee(String id) async {
    _lastError = null;
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;

    final removed = _items.removeAt(idx);
    notifyListeners();

    try {
      await _api.deleteEmployee(id);
    } catch (e) {
      // rollback
      _items.insert(idx, removed);
      _lastError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void upsert(Employment e) {
    final idx = _items.indexWhere((x) => x.id == e.id);
    if (idx >= 0) {
      _items[idx] = e;
    } else {
      _items.insert(0, e);
    }
    notifyListeners();
  }

  void clear() {
    _items = [];
    _lastError = null;
    notifyListeners();
  }
}
