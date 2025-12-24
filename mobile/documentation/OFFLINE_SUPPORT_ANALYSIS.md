# Offline Support & Local Storage - Analysis Report

**Application**: BBIHUB Mobile App  
**Date**: 2025-12-23  
**Status**: ⚠️ **Partially Implemented**

---

## 📊 Executive Summary

| Feature | Status | Coverage | Priority |
|---------|--------|----------|----------|
| **Connectivity Detection** | ✅ **Complete** | 100% | HIGH |
| **Offline UI Indication** | ✅ **Complete** | 100% | HIGH |
| **Local Data Storage** | ⚠️ **Minimal** | ~10% | HIGH |
| **Data Persistence** | ❌ **Not Implemented** | 0% | HIGH |
| **Offline-First Architecture** | ❌ **Not Implemented** | 0% | MEDIUM |
| **Data Synchronization** | ❌ **Not Implemented** | 0% | HIGH |
| **Retry Mechanism** | ✅ **Complete** | 100% | MEDIUM |

**Overall Offline Support**: ⚠️ **~40% Complete**

---

## ✅ What's Already Implemented

### 1. Connectivity Detection (100% ✅)

**File**: `lib/core/services/connectivity_service.dart`

**Features**:
- ✅ Real-time network monitoring using `connectivity_plus`
- ✅ Detects WiFi, Mobile Data, and No Connection
- ✅ Callbacks for offline/online state changes
- ✅ Manual connection check for retry

**Code**:
```dart
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  bool _isOffline = false;
  bool get isOffline => _isOffline;
  
  VoidCallback? onOffline;
  VoidCallback? onOnline;
  
  Future<void> startMonitoring({
    VoidCallback? onOffline,
    VoidCallback? onOnline,
  }) async {
    this.onOffline = onOffline;
    this.onOnline = onOnline;
    
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
  }
  
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final isConnected = results.any((result) => result != ConnectivityResult.none);
    
    if (!isConnected && !_isOffline) {
      _isOffline = true;
      onOffline?.call();
    } else if (isConnected && _isOffline) {
      _isOffline = false;
      onOnline?.call();
    }
  }
}
```

**Usage**: ✅ App-wide via `ConnectivityWrapper` in `main.dart`

---

### 2. Offline UI Indication (100% ✅)

**Files**:
- `lib/core/widgets/connectivity_wrapper.dart` - Auto-detect wrapper
- `lib/core/screens/offline_screen.dart` - Offline UI
- `lib/core/utils/offline_helper.dart` - Helper utilities

**Features**:
- ✅ Full-screen offline notification
- ✅ Bottom sheet offline alert
- ✅ Dialog offline warning
- ✅ Snackbar offline messages
- ✅ Automatic show/hide based on connectivity
- ✅ Retry button with callback

**Example**:
```dart
// App wrapper
ConnectivityWrapper(
  navigatorKey: _navigatorKey,
  child: MaterialApp(...),
)

// Offline screen shown automatically when disconnected
// User can tap "Retry" to check connection again
```

**Status**: ✅ **Production Ready**

---

### 3. Basic Local Storage (10% ⚠️)

**Package**: `shared_preferences: ^2.0.0`

**Current Usage**:
- ⚠️ Only for simple prefs (onboarding completed, etc.)
- ❌ NOT used for data persistence
- ❌ NOT used for caching API responses

**Found in**:
```dart
// splash_screen.dart
final prefs = await SharedPreferences.getInstance();

// on_boarding.dart
final prefs = await SharedPreferences.getInstance();
```

**What's Missing**:
- ❌ No service data caching
- ❌ No dashboard data persistence
- ❌ No staff list caching
- ❌ No report data offline storage

---

### 4. Retry Mechanism (100% ✅)

**Features**:
- ✅ Retry button on offline screen
- ✅ Check connection before retry
- ✅ User feedback (snackbar/dialog)
- ✅ Callback support

**Code**:
```dart
Future<void> _handleRetry() async {
  final isConnected = await _connectivityService.checkConnection();
  
  if (isConnected) {
    _isOfflineScreenShown = false;
    Navigator.of(context).pop();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Masih offline. Silakan coba lagi.')),
    );
  }
}
```

---

## ❌ What's NOT Implemented

### 1. Local Data Persistence (0% ❌)

**Missing Features**:
- ❌ No local database (Hive, Isar, SQLite)
- ❌ No data caching layer
- ❌ No offline-first architecture
- ❌ Data lost when app closes offline

**Impact**:
- User loses all data if connection drops
- Cannot view previously loaded data offline
- Poor user experience during network issues

---

### 2. Data Synchronization (0% ❌)

**Missing Features**:
- ❌ No sync queue for offline actions
- ❌ No conflict resolution
- ❌ No background sync when connection restored
- ❌ No retry for failed API calls

**Impact**:
- User actions lost if offline (e.g., add staff, update service)
- No auto-sync when back online
- Data inconsistency issues

---

### 3. Offline-Capable Features (0% ❌)

**Missing**:
- ❌ View dashboard offline (from cache)
- ❌ View staff list offline
- ❌ View service history offline
- ❌ View reports offline
- ❌ Draft mode for forms (save locally, submit later)

---

## 🎯 Recommended Implementation

### Architecture: **Offline-First with Repository Pattern**

```
┌─────────────────────────────────────────────────┐
│               PRESENTATION LAYER                │
│  (Screens, Widgets, Providers)                  │
└────────────────┬────────────────────────────────┘
                 │
┌────────────────▼────────────────────────────────┐
│              REPOSITORY LAYER                   │
│  - Handles online/offline logic                 │
│  - Returns cached data if offline               │
│  - Syncs when online                            │
└────────┬───────────────────────┬────────────────┘
         │                       │
┌────────▼──────────┐   ┌────────▼──────────────┐
│  REMOTE SOURCE    │   │   LOCAL SOURCE        │
│  (API Service)    │   │   (Hive/Isar DB)      │
└───────────────────┘   └───────────────────────┘
```

---

## 📦 Implementation Plan

### Phase 1: Local Storage Setup (HIGH Priority)

**Duration**: 2-3 days

#### 1.1 Add Dependencies

```yaml
# pubspec.yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.6
```

**Why Hive?**
- ✅ Fast & lightweight
- ✅ No native dependencies
- ✅ Type-safe with code generation
- ✅ Supports encryption
- ✅ Better than SharedPreferences for complex data

---

#### 1.2 Create Data Models

**File**: `lib/core/models/cached_*.dart`

```dart
import 'package:hive/hive.dart';

part 'cached_service.g.dart';

@HiveType(typeId: 0)
class CachedService {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String customerName;
  
  @HiveField(2)
  final String vehiclePlate;
  
  @HiveField(3)
  final String status;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final DateTime cachedAt;
  
  CachedService({
    required this.id,
    required this.customerName,
    required this.vehiclePlate,
    required this.status,
    required this.createdAt,
    required this.cachedAt,
  });
  
  factory CachedService.fromJson(Map<String, dynamic> json) {
    return CachedService(
      id: json['id'],
      customerName: json['customer']['name'],
      vehiclePlate: json['vehicle']['plate_number'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      cachedAt: DateTime.now(),
    );
  }
}
```

Similar models for:
- `CachedDashboard`
- `CachedStaff`
- `CachedReport`

---

#### 1.3 Create Local Storage Service

**File**: `lib/core/services/local_storage_service.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  LocalStorageService._();
  
  static final LocalStorageService instance = LocalStorageService._();
  
  static const String servicesBox = 'services';
  static const String dashboardBox = 'dashboard';
  static const String staffBox = 'staff';
  
  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(CachedServiceAdapter());
    Hive.registerAdapter(CachedDashboardAdapter());
    Hive.registerAdapter(CachedStaffAdapter());
    
    // Open boxes
    await Hive.openBox<CachedService>(servicesBox);
    await Hive.openBox<CachedDashboard>(dashboardBox);
    await Hive.openBox<CachedStaff>(staffBox);
  }
  
  // Services
  Future<void> cacheServices(List<CachedService> services) async {
    final box = Hive.box<CachedService>(servicesBox);
    await box.clear();
    await box.addAll(services);
  }
  
  List<CachedService> getCachedServices() {
    final box = Hive.box<CachedService>(servicesBox);
    return box.values.toList();
  }
  
  // Dashboard
  Future<void> cacheDashboard(CachedDashboard dashboard) async {
    final box = Hive.box<CachedDashboard>(dashboardBox);
    await box.put('latest', dashboard);
  }
  
  CachedDashboard? getCachedDashboard() {
    final box = Hive.box<CachedDashboard>(dashboardBox);
    return box.get('latest');
  }
  
  // Staff
  Future<void> cacheStaff(List<CachedStaff> staff) async {
    final box = Hive.box<CachedStaff>(staffBox);
    await box.clear();
    await box.addAll(staff);
  }
  
  List<CachedStaff> getCachedStaff() {
    final box = Hive.box<CachedStaff>(staffBox);
    return box.values.toList();
  }
  
  // Clear all cache
  Future<void> clearAllCache() async {
    await Hive.box<CachedService>(servicesBox).clear();
    await Hive.box<CachedDashboard>(dashboardBox).clear();
    await Hive.box<CachedStaff>(staffBox).clear();
  }
}
```

---

### Phase 2: Repository Pattern (HIGH Priority)

**Duration**: 3-4 days

#### 2.1 Create Base Repository

**File**: `lib/core/repositories/base_repository.dart`

```dart
import 'package:bengkel_online_flutter/core/services/connectivity_service.dart';
import 'package:bengkel_online_flutter/core/services/local_storage_service.dart';

abstract class BaseRepository<T> {
  final ConnectivityService _connectivity = ConnectivityService.instance;
  final LocalStorageService _localStorage = LocalStorageService.instance;
  
  /// Fetch data with offline support
  /// 
  /// Strategy:
  /// 1. If online: fetch from API, cache, return
  /// 2. If offline: return cached data
  Future<List<T>> fetchWithCache({
    required Future<List<T>> Function() fetchFromApi,
    required Future<void> Function(List<T>) cacheData,
    required List<T> Function() getCachedData,
  }) async {
    try {
      if (!_connectivity.isOffline) {
        // Online: fetch fresh data
        final data = await fetchFromApi();
        
        // Cache for offline use
        await cacheData(data);
        
        return data;
      } else {
        // Offline: return cached data
        final cached = getCachedData();
        
        if (cached.isEmpty) {
          throw Exception('No cached data available. Please connect to internet.');
        }
        
        return cached;
      }
    } catch (e) {
      // Error fetching: fallback to cache
      final cached = getCachedData();
      
      if (cached.isNotEmpty) {
        return cached;
      }
      
      rethrow;
    }
  }
}
```

---

#### 2.2 Implement Service Repository

**File**: `lib/feature/owner/repositories/service_repository.dart`

```dart
import 'package:bengkel_online_flutter/core/repositories/base_repository.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/services/local_storage_service.dart';
import 'package:bengkel_online_flutter/core/models/cached_service.dart';

class ServiceRepository extends BaseRepository<CachedService> {
  final ApiService _api = ApiService();
  final LocalStorageService _storage = LocalStorageService.instance;
  
  Future<List<CachedService>> getServices() async {
    return fetchWithCache(
      fetchFromApi: () async {
        final response = await _api.get('/api/v1/services');
        final services = (response['data'] as List)
            .map((json) => CachedService.fromJson(json))
            .toList();
        return services;
      },
      cacheData: (services) => _storage.cacheServices(services),
      getCachedData: () => _storage.getCachedServices(),
    );
  }
}
```

Similarly for:
- `DashboardRepository`
- `StaffRepository`
- `ReportRepository`

---

#### 2.3 Update Providers to Use Repository

**File**: `lib/feature/owner/providers/service_provider.dart`

```dart
class ServiceProvider extends ChangeNotifier {
  final ServiceRepository _repository = ServiceRepository();
  
  List<CachedService> _services = [];
  bool _isLoading = false;
  bool _isFromCache = false;
  String? _error;
  
  List<CachedService> get services => _services;
  bool get isLoading => _isLoading;
  bool get isFromCache => _isFromCache;
  String? get error => _error;
  
  Future<void> fetchServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _services = await _repository.getServices();
      
      // Check if data is from cache
      if (_services.isNotEmpty) {
        final firstService = _services.first;
        final cacheAge = DateTime.now().difference(firstService.cachedAt);
        _isFromCache = cacheAge.inMinutes > 0; // Older than 0 min = from cache
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

### Phase 3: Offline Actions Queue (MEDIUM Priority)

**Duration**: 2-3 days

#### 3.1 Create Pending Action Model

**File**: `lib/core/models/pending_action.dart`

```dart
@HiveType(typeId: 10)
class PendingAction {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String type; // 'add_staff', 'update_service', etc.
  
  @HiveField(2)
  final Map<String, dynamic> payload;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final int retryCount;
  
  PendingAction({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.retryCount = 0,
  });
}
```

---

#### 3.2 Create Sync Service

**File**: `lib/core/services/sync_service.dart`

```dart
class SyncService {
  static final SyncService instance = SyncService._();
  SyncService._();
  
  final ConnectivityService _connectivity = ConnectivityService.instance;
  final LocalStorageService _storage = LocalStorageService.instance;
  final ApiService _api = ApiService();
  
  /// Queue an action for later execution
  Future<void> queueAction(String type, Map<String, dynamic> payload) async {
    final action = PendingAction(
      id: Uuid().v4(),
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
    );
    
    final box = await Hive.openBox<PendingAction>('pending_actions');
    await box.add(action);
    
    // Try to sync immediately if online
    if (!_connectivity.isOffline) {
      await syncPendingActions();
    }
  }
  
  /// Sync all pending actions
  Future<void> syncPendingActions() async {
    if (_connectivity.isOffline) {
      debugPrint('Cannot sync: offline');
      return;
    }
    
    final box = await Hive.openBox<PendingAction>('pending_actions');
    final actions = box.values.toList();
    
    for (var action in actions) {
      try {
        await _executeAction(action);
        await box.delete(action.key); // Remove from queue on success
      } catch (e) {
        debugPrint('Failed to sync action ${action.id}: $e');
        // Keep in queue for next sync attempt
      }
    }
  }
  
  Future<void> _executeAction(PendingAction action) async {
    switch (action.type) {
      case 'add_staff':
        await _api.post('/api/v1/employments', body: action.payload);
        break;
      case 'update_service':
        await _api.put('/api/v1/services/${action.payload['id']}', body: action.payload);
        break;
      // Add more action types...
    }
  }
  
  /// Auto-sync when connection restored
  void startAutoSync() {
    _connectivity.startMonitoring(
      onOnline: () async {
        debugPrint('Connection restored - starting auto-sync');
        await syncPendingActions();
      },
    );
  }
}
```

---

#### 3.3 Update UI to Use Sync Queue

**Example**: Add Staff Screen

```dart
Future<void> _addStaff() async {
  final connectivity = ConnectivityService.instance;
  
  if (connectivity.isOffline) {
    // Queue for later
    await SyncService.instance.queueAction('add_staff', {
      'email': emailController.text,
      'role': selectedRole,
      'status': 'active',
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Offline: Staff will be added when connection restored'),
        backgroundColor: Colors.orange,
      ),
    );
    
    Navigator.pop(context);
  } else {
    // Add immediately
    await _api.post('/api/v1/employments', body: {...});
  }
}
```

---

### Phase 4: UI Enhancements (LOW Priority)

**Duration**: 1-2 days

#### 4.1 Offline Indicator in App Bar

```dart
Widget _buildOfflineIndicator() {
  return Consumer<ConnectivityProvider>(
    builder: (context, connectivity, child) {
      if (!connectivity.isOffline) return SizedBox.shrink();
      
      return Container(
        color: Colors.orange,
        padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 16, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Mode Offline',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      );
    },
  );
}
```

---

#### 4.2 Cache Age Indicator

```dart
Widget _buildCacheAgeIndicator(DateTime cachedAt) {
  final age = DateTime.now().difference(cachedAt);
  final ageText = age.inMinutes < 60
      ? '${age.inMinutes} menit lalu'
      : '${age.inHours} jam lalu';
  
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, size: 16, color: Colors.blue),
        SizedBox(width: 4),
        Text(
          'Data dari cache ($ageText)',
          style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
        ),
      ],
    ),
  );
}
```

---

## 📊 Implementation Summary

### Files to Create (New)

```
lib/
├── core/
│   ├── models/
│   │   ├── cached_service.dart ✨
│   │   ├── cached_dashboard.dart ✨
│   │   ├── cached_staff.dart ✨
│   │   ├── cached_report.dart ✨
│   │   └── pending_action.dart ✨
│   ├── repositories/
│   │   ├── base_repository.dart ✨
│   │   ├── service_repository.dart ✨
│   │   ├── dashboard_repository.dart ✨
│   │   └── staff_repository.dart ✨
│   └── services/
│       ├── local_storage_service.dart ✨
│       └── sync_service.dart ✨
```

### Files to Update (Existing)

```
lib/
├── main.dart
│   └── Add Hive.initFlutter()
├── feature/owner/
│   ├── providers/
│   │   ├── service_provider.dart
│   │   ├── dashboard_provider.dart
│   │   └── employee_provider.dart
│   └── screens/
│       ├── homepage_owner.dart
│       ├── staff_management_screen.dart
│       └── add_staff.dart
```

---

## ✅ Testing Plan

### 1. Unit Tests

```dart
// test/services/local_storage_service_test.dart
void main() {
  group('LocalStorageService', () {
    test('should cache services correctly', () async {
      final service = LocalStorageService.instance;
      final mockServices = [CachedService(...)];
      
      await service.cacheServices(mockServices);
      final cached = service.getCachedServices();
      
      expect(cached.length, equals(1));
    });
  });
}
```

### 2. Integration Tests

```dart
// test/integration/offline_flow_test.dart
void main() {
  testWidgets('should show cached data when offline', (tester) async {
    // 1. Load data while online
    // 2. Go offline
    // 3. Verify cached data still shows
    // 4. Go online
    // 5. Verify data refreshes
  });
}
```

### 3. Manual Testing

See: `test/MANUAL_TESTING_OFFLINE.md` (to be created)

---

## 📈 Expected Impact

### Before Implementation

**Current State**:
- ❌ No offline support for data
- ❌ User cannot view anything when offline
- ❌ Poor UX during network issues

**User Experience**: ⭐⭐ (2/5)

---

### After Implementation

**Target State**:
- ✅ Cached data available offline
- ✅ Smooth offline experience
- ✅ Auto-sync when back online
- ✅ Queued actions executed automatically

**User Experience**: ⭐⭐⭐⭐⭐ (5/5)

---

## ⏱️ Timeline

| Phase | Duration | Priority | Deliverables |
|-------|----------|----------|--------------|
| **Phase 1** | 2-3 days | HIGH | Local storage setup |
| **Phase 2** | 3-4 days | HIGH | Repository pattern |
| **Phase 3** | 2-3 days | MEDIUM | Sync queue |
| **Phase 4** | 1-2 days | LOW | UI enhancements |
| **Testing** | 2-3 days | HIGH | All tests pass |
| **Total** | **10-15 days** | | Full offline support |

---

## 🎯 Success Criteria

- [ ] Dashboard viewable offline (from cache)
- [ ] Services list viewable offline
- [ ] Staff list viewable offline
- [ ] Actions queued when offline
- [ ] Auto-sync on connection restore
- [ ] Cache age <24 hours shows warning
- [ ] All tests pass (unit + integration)
- [ ] User can complete workflows offline

---

**Report Created**: 2025-12-23  
**Next Steps**: Review & approve implementation plan  
**Estimated Completion**: 2-3 weeks with 1 developer
