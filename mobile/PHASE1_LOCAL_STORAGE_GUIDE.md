# 🚀 Phase 1: Local Storage Implementation Guide

## Step 1: ✅ Dependencies Added

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  uuid: ^4.3.3

dev_dependencies:
  build_runner: ^2.4.8
  hive_generator: ^2.0.1
```

## Step 2: ✅ Models Created

- `lib/core/models/cached_service.dart`
- `lib/core/models/cached_dashboard.dart`
- `lib/core/models/cached_staff.dart`

## Step 3: ✅ Service Created

- `lib/core/services/local_storage_service.dart`

---

## Step 4: Generate Hive Type Adapters

Run this command to generate `.g.dart` files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will create:
- `cached_service.g.dart`
- `cached_dashboard.g.dart`
- `cached_staff.g.dart`

**IMPORTANT**: Run this command NOW before continuing!

---

## Step 5: Initialize in main.dart

Add to `main.dart`:

```dart
import 'package:bengkel_online_flutter/core/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Initialize Hive BEFORE runApp()
  await LocalStorageService.instance.init();
  
  runApp(MyApp());
}
```

---

## Step 6: Usage Examples

### Example 1: Cache Services (in Provider or Screen)

```dart
import 'package:bengkel_online_flutter/core/services/local_storage_service.dart';
import 'package:bengkel_online_flutter/core/models/cached_service.dart';
import 'package:bengkel_online_flutter/core/services/connectivity_service.dart';

Future<List<CachedService>> fetchServices() async {
  final localStorage = LocalStorageService.instance;
  final connectivity = ConnectivityService.instance;
  
  try {
    if (!connectivity.isOffline) {
      // ONLINE: Fetch from API
      final response = await apiService.get('/api/v1/services');
      final services = (response['data'] as List)
          .map((json) => CachedService.fromJson(json))
          .toList();
      
      // Cache for offline use
      await localStorage.cacheServices(services);
      
      return services;
    } else {
      // OFFLINE: Return cached data
      final cached = localStorage.getCachedServices();
      
      if (cached.isEmpty) {
        throw Exception('No offline data. Connect to internet.');
      }
      
      return cached;
    }
  } catch (e) {
    // Error fetching: Try cache as fallback
    final cached = localStorage.getCachedServices();
    if (cached.isNotEmpty) {
      return cached;
    }
    rethrow;
  }
}
```

### Example 2: Cache Dashboard

```dart
import 'package:bengkel_online_flutter/core/models/cached_dashboard.dart';

Future<CachedDashboard> fetchDashboard() async {
  final localStorage = LocalStorageService.instance;
  final connectivity = ConnectivityService.instance;
  
  if (!connectivity.isOffline) {
    // ONLINE: Fetch fresh
    final response = await apiService.get('/api/v1/admins/dashboard');
    final dashboard = CachedDashboard.fromJson(response);
    
    // Cache it
    await localStorage.cacheDashboard(dashboard);
    
    return dashboard;
  } else {
    // OFFLINE: Load from cache
    final cached = localStorage.getCachedDashboard();
    if (cached == null) {
      throw Exception('No cached dashboard');
    }
    return cached;
  }
}
```

### Example 3: Show Cache Age Indicator

```dart
Widget buildCacheIndicator() {
  final localStorage = LocalStorageService.instance;
  final dashboard = localStorage.getCachedDashboard();
  
  if (dashboard != null && dashboard.isStale) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16),
          SizedBox(width: 4),
          Text('Data dari cache (${dashboard.cacheAgeText})'),
        ],
      ),
    );
  }
  
  return SizedBox.shrink();
}
```

---

## Step 7: Testing

### Test Cache Functionality

```dart
void testCaching() async {
  final storage = LocalStorageService.instance;
  
  // Test services
  final testServices = [
    CachedService(
      id: '1',
      customerName: 'John Doe',
      status: 'in progress',
      createdAt: DateTime.now(),
      cachedAt: DateTime.now(),
    ),
  ];
  
  await storage.cacheServices(testServices);
  final cached = storage.getCachedServices();
  
  print('Cached services: ${cached.length}'); // Should be 1
  print('Cache age: ${cached.first.cacheAgeText}');
  
  // Test dashboard
  final testDashboard = CachedDashboard(
    servicesToday: 5,
    inProgress: 2,
    completed: 3,
    cachedAt: DateTime.now(),
  );
  
  await storage.cacheDashboard(testDashboard);
  final cachedDash = storage.getCachedDashboard();
  
  print('Dashboard cached: ${cachedDash != null}');
  
  // Get cache info
  final info = storage.getCacheInfo();
  print('Cache info: $info');
}
```

---

## Benefits

✅ **Offline Viewing**: Users can view services, dashboard, staff even offline  
✅ **Faster Loading**: Cached data loads instantly  
✅ **Better UX**: No blank screens during network issues  
✅ **Auto Fallback**: API fails → falls back to cache  
✅ **Cache Age Tracking**: Know when data is stale  

---

## Next Steps (Phase 2)

After Phase 1 is complete:

1. **Create Repository Pattern** - Centralize online/offline logic
2. **Update Providers** - Use repositories instead of direct API calls
3. **Add Sync Queue** - Queue actions when offline
4. **Auto Sync** - Sync when connection restored

---

## Commands Summary

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate type adapters
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run app
flutter run
```

---

**Status**: Phase 1 Ready ✅  
**Next**: Run `build_runner` command!
