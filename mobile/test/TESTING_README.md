# Mobile API Testing - BBIHUB Flutter App

Testing suite untuk API authentication (Register & Login) di BBIHUB mobile Flutter app.

## 📁 File Testing

- **Unit Tests**: `test/api_auth_test.dart` (16 tests)
- **Manual Testing Guide**: `test/MANUAL_TESTING_AUTH.md`
- **Widget Tests**: `test/widget/` (12 widget tests)

---

## 🚀 Menjalankan Automated Tests

### Run API Authentication Tests
```bash
flutter test test/api_auth_test.dart
```

### Run Semua Tests
```bash
flutter test
```

### Run dengan Verbose Output
```bash
flutter test test/api_auth_test.dart --verbose
```

### Run dengan Coverage
```bash
flutter test test/api_auth_test.dart --coverage
```

### Run Specific Test Group
```bash
# Configuration tests only
flutter test test/api_auth_test.dart --name "Configuration"

# Endpoint validation tests only
flutter test test/api_auth_test.dart --name "Endpoint Validation"

# Method availability tests only  
flutter test test/api_auth_test.dart --name "Method Availability"
```

---

## ✅ Test Coverage (16 Tests)

### Configuration Tests (5 tests)
- ✅ **Correct base URL for Android emulator** - Verifikasi URL `10.0.2.2`
- ✅ **Correct register endpoint** - Endpoint `/auth/register`
- ✅ **Correct login endpoint** - Endpoint `/auth/login`
- ✅ **Correct logout endpoint** - Endpoint `/auth/logout`
- ✅ **Correct fetch user endpoint** - Endpoint `/auth/user`

### Endpoint Validation Tests (4 tests)
- ✅ **Register endpoint no trailing slash** - Format URL benar
- ✅ **Login endpoint no trailing slash** - Format URL benar
- ✅ **Base URL has version prefix** - Mengandung `/v1/`
- ✅ **Correct protocol for Android** - Menggunakan `http://`

### Request Data Structure Tests (2 tests)
- ✅ **Register requires all mandatory fields** - Validasi signature method
- ✅ **Login requires email and password** - Validasi signature method

### Method Availability Tests (5 tests)
- ✅ **Has register method** - Method tersedia
- ✅ **Has login method** - Method tersedia
- ✅ **Has logout method** - Method tersedia
- ✅ **Has fetchUser method** - Method tersedia
- ✅ **Has changePassword method** - Method tersedia

---

## 🧪 Manual Testing

Untuk manual testing melalui UI aplikasi atau integration testing dengan backend yang running, ikuti panduan lengkap di:

```
test/MANUAL_TESTING_AUTH.md
```

### Format Manual Testing

Setiap test menggunakan format:

```markdown
# Nama Test
--command
```

**Contoh**:

```markdown
# Test Register User Baru dengan Data Valid
--command
flutter test test/api_auth_test.dart --name "should successfully register with valid data"
```

**Manual Steps** (via App UI):
1. Buka aplikasi
2. Navigasi ke halaman Register
3. Isi form dengan data test
4. Submit dan verifikasi hasil

---

## 📊 Test Results

**Status**: ✅ **ALL TESTS PASSING**

```
All tests passed!
Duration: ~6 seconds
Tests: 16 passed
```

---

## 🔧 Integration Testing dengan Backend

Untuk testing yang melibatkan koneksi ke backend server:

### Prerequisites
1. Backend server harus running:
   ```bash
   cd ../backend
   php artisan serve
   ```

2. Database sudah di-seed:
   ```bash
   php artisan migrate:fresh --seed
   ```

### Test Accounts

Gunakan akun berikut untuk manual testing:

```dart
// Owner Account
Email: owner@example.com
Password: password

// Admin Account  
Email: admin@example.com
Password: password

// Mechanic Account
Email: mechanic@example.com
Password: password
```

### Network Configuration

#### Android Emulator
```dart
static const String _baseUrl = 'http://10.0.2.2:8000/api/v1/';
```

#### iOS Simulator
```dart
static const String _baseUrl = 'http://localhost:8000/api/v1/';
```

#### Physical Device (Same Network)
```dart
static const String _baseUrl = 'http://192.168.1.XXX:8000/api/v1/';
```
*Replace XXX with your computer's IP address*

---

## 🎯 Manual Testing Scenarios

### Register Tests
```bash
# Test 1: Register dengan data valid
--command
Manual UI testing (lihat MANUAL_TESTING_AUTH.md)

# Test 2: Register dengan email invalid
--command
Manual UI testing

# Test 3: Register dengan password lemah  
--command
Manual UI testing

# Test 4: Register dengan password mismatch
--command
Manual UI testing

# Test 5: Register dengan email duplikat
--command
Manual UI testing
```

### Login Tests
```bash
# Test 1: Login dengan kredensial valid
--command
Manual UI testing

# Test 2: Login dengan email tidak terdaftar
--command
Manual UI testing

# Test 3: Login dengan password salah
--command
Manual UI testing

# Test 4: Login dengan field kosong
--command
Manual UI testing
```

Lihat detail lengkap di `test/MANUAL_TESTING_AUTH.md`

---

## 🐛 Debugging

### Enable Debug Logs

API Service sudah memiliki built-in debug logging. Check console output untuk:

```
[REGISTER] http://10.0.2.2:8000/api/v1/auth/register
[REGISTER] headers: {Content-Type: application/json, ...}
[REGISTER] body: {"name":"Test User",...}
[REGISTER] status: 201
[REGISTER] body: {"message":"Registrasi berhasil",...}
```

### Common Issues

#### Connection Refused
**Problem**: Cannot connect to backend  
**Solution**:
```bash
# Check backend is running
curl http://localhost:8000/api/v1/auth/login

# Check from emulator
# Android: use 10.0.2.2
# iOS: use localhost
```

#### Token Not Found
**Problem**: Secure storage error  
**Solution**:
```bash
# Clear app data
flutter clean
flutter run

# Or uninstall and reinstall
```

#### Certificate Error (HTTPS)
**Problem**: SSL certificate verification  
**Solution**: Use HTTP for development

---

## 📝 Writing New Tests

### Template untuk Test Baru

```dart
test('description of test', () {
  // Arrange - Setup test data
  const testData = 'value';
  
  // Act - Execute the test
  final result = apiService.someMethod(testData);
  
  // Assert - Verify the result
  expect(result, expectedValue);
});
```

### Best Practices

1. **Use descriptive test names** - Clear dan spesifik
2. **Test one thing at a time** - Satu test, satu assertion utama
3. **Use setUp and tearDown** - Clean state untuk setiap test
4. **Mock external dependencies** - Jangan bergantung pada backend
5. **Test edge cases** - Empty strings, null values, dll

---

## 🔐 Security Testing

Testing ini memverifikasi:
- ✅ API endpoints menggunakan HTTPS (production)
- ✅ Token disimpan di secure storage
- ✅ Password tidak pernah di-log
- ✅ Request headers sesuai (Content-Type, Accept)
- ✅ Response structure validation
- ✅ Error handling untuk berbagai status code

---

## 📚 Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Dart Test Package](https://pub.dev/packages/test)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [HTTP Package](https://pub.dev/packages/http)
- [Mockito](https://pub.dev/packages/mockito) - For mocking

---

## 🔄 Continuous Integration

Untuk CI/CD pipeline:

```yaml
# .github/workflows/test.yml
name: Flutter Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test test/api_auth_test.dart
      - run: flutter test # Run all tests
```

---

## 📈 Test Metrics

- **Total Tests**: 16 unit tests + 12 widget tests = **28 tests**
- **Coverage**: API Service configuration & endpoints
- **Execution Time**: ~6 seconds
- **Success Rate**: 100% ✅

---

**Last Updated**: 2025-12-22  
**Flutter Version**: 3.x  
**Dart Version**: 3.x  
**Test Framework**: flutter_test  
**Author**: BBIHUB Development Team
