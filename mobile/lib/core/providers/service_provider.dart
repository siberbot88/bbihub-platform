import 'package:flutter/foundation.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';

/// Provider untuk Work Order / Service (OWNER base)
/// Admin akan extend ini lewat AdminServiceProvider.
class ServiceProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // ---- state dasar ----
  bool _loading = false;
  String? _lastError;
  List<ServiceModel> _items = [];
  ServiceModel? _selected; // untuk halaman detail

  // ---- filter & search ----
  String? _statusFilter; // 'pending' | 'accept' | 'in progress' | 'completed' | 'cancelled' | null
  String _search = '';

  // ---- pagination ----
  int _currentPage = 1;
  int _totalPages = 1;
  int _perPage = 10;

  // ---- getters ----
  bool get loading => _loading;
  String? get lastError => _lastError;
  String? get error => _lastError; // alias jika UI lama masih pakai 'error'
  List<ServiceModel> get items => List.unmodifiable(_items);
  ServiceModel? get selected => _selected;

  String? get statusFilter => _statusFilter;
  String get search => _search;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasNextPage => _currentPage < _totalPages;
  bool get hasPrevPage => _currentPage > 1;

  /// List sudah difilter status dan teks (kalau mau pakai client-side)
  List<ServiceModel> get filteredItems {
    Iterable<ServiceModel> list = _items;

    if (_statusFilter != null && _statusFilter!.isNotEmpty) {
      final want = _statusFilter!.toLowerCase();
      list = list.where((e) => e.status.toLowerCase() == want);
    }

    final q = _search.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((e) => e.searchKeywords.contains(q));
    }

    return List.unmodifiable(list);
  }

  /* =================== HOOKS UNTUK SUBCLASS =================== */

  /// Hook yang boleh dioverride oleh subclass (misal: AdminServiceProvider)
  /// Default: pakai endpoint owners/services (via fetchServicesRaw).
  @protected
  Future<Map<String, dynamic>> performFetchServicesRaw({
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
    bool useScheduleEndpoint = true, // Control endpoint selection
  }) {
    return _api.fetchServicesRaw(
      status: status ?? _statusFilter,
      includeExtras: includeExtras,
      workshopUuid: workshopUuid,
      code: code,
      dateFrom: dateFrom,
      dateTo: dateTo,
      page: page,
      perPage: perPage,
      type: type,
      dateColumn: dateColumn,
      search: search, // Pass search
      useScheduleEndpoint: useScheduleEndpoint, // Note: Base ServiceProvider uses owner endpoint, not admin // So useScheduleEndpoint doesn't apply here, but needed for signature
    );
  }

  /// Hook detail: default pakai owners/services/{id}
  @protected
  Future<ServiceModel> performFetchServiceDetail(String id) {
    return _api.fetchServiceDetail(id);
  }

  /* =================== Actions =================== */

  /// Ganti filter status. Sekarang akan reset ke page 1 dan fetch lagi.
  Future<void> setStatusFilter(
      String? status, {
        bool fetch = true,
        String? workshopUuid,
      }) async {
    _statusFilter = status;
    notifyListeners();
    if (fetch) {
      await fetchServices(
        status: status,
        workshopUuid: workshopUuid,
        page: 1,
      );
    }
  }

  /// Set kata kunci pencarian (client-side)
  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  /// GET /services (dengan pagination)
  Future<void> fetchServices({
    String? status,
    bool includeExtras = true,
    String? workshopUuid,
    String? code,
    String? dateFrom, // 'YYYY-MM-DD'
    String? dateTo, // 'YYYY-MM-DD'
    int page = 1,
    int? perPage,
    String? type, // Added type param
    String? dateColumn,
    String? search, // Added search param
    bool useScheduleEndpoint = true, // Control endpoint type
  }) async {
    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print(
          '[ServiceProvider($runtimeType)] fetchServices '
              'page=$page, status=$status, ws=$workshopUuid',
        );
      }

      final res = await performFetchServicesRaw(
        status: status ?? _statusFilter,
        includeExtras: includeExtras,
        workshopUuid: workshopUuid,
        code: code,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        perPage: perPage ?? _perPage,
        type: type, // Pass type
        dateColumn: dateColumn,
        search: search, // Pass search
        useScheduleEndpoint: useScheduleEndpoint, // Pass through to API
      );

      final data = res['data'];
      final listJson = data is List ? data : const <dynamic>[];

      _items = listJson
          .whereType<Map<String, dynamic>>()
          .map(ServiceModel.fromJson)
          .toList();

      // meta pagination
      _currentPage = _parseInt(res['current_page'], fallback: page);
      _totalPages = _parseInt(res['last_page'], fallback: 1);
      _perPage = _parseInt(res['per_page'], fallback: perPage ?? _perPage);

      if (kDebugMode) {
        print(
          '[ServiceProvider($runtimeType)] loaded items=${_items.length}, '
              'currentPage=$_currentPage / $_totalPages',
        );
      }
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('[ServiceProvider($runtimeType)] fetchServices error: $e');
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Alias agar kompatibel dengan pemanggilan lama
  Future<void> fetch({String? status, bool? includeExtras}) =>
      fetchServices(status: status, includeExtras: includeExtras ?? true);

  /// Pindah halaman (dipakai ListWorkPage)
  Future<void> goToPage(int page, {String? workshopUuid}) async {
    if (page < 1 || page > _totalPages) return;
    await fetchServices(
      status: _statusFilter,
      workshopUuid: workshopUuid,
      page: page,
    );
  }

  /// GET /services/{id}
  Future<ServiceModel?> fetchDetail(String id) async {
    _loading = true;
    _lastError = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('[ServiceProvider($runtimeType)] fetchDetail id=$id');
      }

      final detail = await performFetchServiceDetail(id);
      _selected = detail;

      // sinkronkan dengan list kalau sudah ada
      final idx = _items.indexWhere((e) => e.id == detail.id);
      if (idx >= 0) {
        _items[idx] = detail;
      } else {
        _items.insert(0, detail);
      }

      return detail;
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('[ServiceProvider($runtimeType)] fetchDetail error: $e');
      }
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// PATCH /services/{id}  {status: ...}
  Future<void> updateStatus({
    required String id,
    required String status,
  }) async {
    _lastError = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('[ServiceProvider($runtimeType)] updateStatus id=$id -> $status');
      }

      await _api.updateServiceStatus(id, status);

      // Update lokal secara optimis
      final idx = _items.indexWhere((e) => e.id == id);
      if (idx >= 0) {
        final s = _items[idx];
        _items[idx] = ServiceModel(
          id: s.id,
          code: s.code,
          name: s.name,
          description: s.description,
          price: s.price,
          scheduledDate: s.scheduledDate,
          estimatedTime: s.estimatedTime,
          status: status,
          customerUuid: s.customerUuid,
          workshopUuid: s.workshopUuid,
          vehicleId: s.vehicleId,
          customer: s.customer,
          vehicle: s.vehicle,
          workshopName: s.workshopName,
          mechanic: s.mechanic,
          items: s.items,
          note: s.note,
          categoryName: s.categoryName,
        );
      }
      if (_selected?.id == id) {
        final s = _selected!;
        _selected = ServiceModel(
          id: s.id,
          code: s.code,
          name: s.name,
          description: s.description,
          price: s.price,
          scheduledDate: s.scheduledDate,
          estimatedTime: s.estimatedTime,
          status: status,
          customerUuid: s.customerUuid,
          workshopUuid: s.workshopUuid,
          vehicleId: s.vehicleId,
          customer: s.customer,
          vehicle: s.vehicle,
          workshopName: s.workshopName,
          mechanic: s.mechanic,
          items: s.items,
          note: s.note,
          categoryName: s.categoryName,
        );
      }

      notifyListeners();
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('[ServiceProvider($runtimeType)] updateStatus error: $e');
      }
      notifyListeners();
      rethrow;
    }
  }

  /// POST /services  (buat dummy)
  Future<ServiceModel> createDummy({
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
    _lastError = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('[ServiceProvider($runtimeType)] createDummy "$name"');
      }

      final created = await _api.createServiceDummy(
        workshopUuid: workshopUuid,
        customerUuid: customerUuid,
        vehicleUuid: vehicleUuid,
        name: name,
        description: description,
        price: price,
        scheduledDate: scheduledDate,
        estimatedTime: estimatedTime,
        status: status,
      );
      _items.insert(0, created);
      notifyListeners();
      return created;
    } catch (e) {
      _lastError = e.toString();
      if (kDebugMode) {
        print('[ServiceProvider($runtimeType)] createDummy error: $e');
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Bersihkan state
  void clear() {
    _items = [];
    _selected = null;
    _lastError = null;
    _statusFilter = null;
    _search = '';
    _currentPage = 1;
    _totalPages = 1;
    notifyListeners();
  }

  /// Hitung jumlah item per status (dari list lokal)
  int countByStatus(String s) =>
      _items.where((e) => e.status.toLowerCase() == s.toLowerCase()).length;

  // helper parse int dari json dynamic
  int _parseInt(dynamic v, {required int fallback}) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) {
      final n = int.tryParse(v);
      if (n != null) return n;
    }
    return fallback;
  }
}
