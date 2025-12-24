# Manual Testing Guide - Mobile API Authentication

Panduan manual testing untuk API Register dan Login di mobile app BBIHUB Flutter.

**Base URL**: `http://10.0.2.2:8000/api/v1/`  
**Platform**: Android Emulator / iOS Simulator / Physical Device

---

## Prerequisites

Sebelum testing, pastikan:
- Backend server sudah running di `localhost:8000`
- Mobile app sudah terinstall di device/emulator
- Database backend sudah di-seed dengan data test
- Network dari emulator/device bisa akses backend

---

## 1. Testing - Register User Baru (Success)

### # Test Register User Baru dengan Data Valid
```bash
flutter test test/api_auth_test.dart --name "should successfully register with valid data"
```

**Expected Result**:
- ✅ Status code = 201
- ✅ Response memiliki `access_token`
- ✅ Response memiliki `token_type` = "Bearer"
- ✅ User data sesuai dengan input
- ✅ User memiliki role "owner"

**Manual Steps** (via App UI):
1. Buka aplikasi BBIHUB
2. Tap "Daftar" atau "Register"
3. Isi form:
   - Nama: `Test User Mobile`
   - Username: `testmobile`
   - Email: `testmobile@example.com`
   - Password: `SecurePassword123!`
   - Konfirmasi Password: `SecurePassword123!`
4. Tap "Daftar"
5. Verifikasi redirect ke halaman onboarding/dashboard

---

## 2. Testing - Register dengan Email Invalid (Failed)

### # Test Register dengan Email Format Salah
```bash
flutter test test/api_auth_test.dart --name "should fail registration with invalid email"
```

**Expected Result**:
- ❌ Throw exception
- ❌ Error message: "The email field must be a valid email address"

**Manual Steps** (via App UI):
1. Buka aplikasi BBIHUB
2. Tap "Daftar"
3. Isi form dengan email invalid: `invalid-email`
4. Tap "Daftar"
5. Verifikasi muncul error message

---

## 3. Testing - Register dengan Password Lemah (Failed)

### # Test Register dengan Password Tidak Memenuhi Kriteria
```bash
flutter test test/api_auth_test.dart --name "should fail registration with weak password"
```

**Expected Result**:
- ❌ Throw exception
- ❌ Error message validation password

**Manual Steps** (via App UI):
1. Buka aplikasi BBIHUB
2. Tap "Daftar"
3. Isi form dengan password lemah: `weak`
4. Tap "Daftar"
5. Verifikasi muncul error:
   - "Password minimal 8 karakter"
   - "Password harus mengandung huruf besar"
   - "Password harus mengandung angka"
   - "Password harus mengandung symbol"

---

## 4. Testing - Register dengan Password Mismatch (Failed)

### # Test Register dengan Konfirmasi Password Tidak Sama
```bash
flutter test test/api_auth_test.dart --name "should fail registration with mismatched passwords"
```

**Expected Result**:
- ❌ Throw exception
- ❌ Error message: "Password confirmation does not match"

**Manual Steps** (via App UI):
1. Buka aplikasi BBIHUB
2. Tap "Daftar"
3. Isi form:
   - Password: `SecurePassword123!`
   - Konfirmasi Password: `DifferentPassword123!`
4. Tap "Daftar"
5. Verifikasi muncul error message

---

## 5. Testing - Register dengan Email Duplikat (Failed)

### # Test Register dengan Email yang Sudah Terdaftar
```bash
flutter test test/api_auth_test.dart --name "should fail registration with duplicate email"
```

**Expected Result**:
- ❌ Throw exception
- ❌ Error message: "The email has already been taken"

**Manual Steps** (via App UI):
1. Buka aplikasi BBIHUB
2. Tap "Daftar"
3. Isi form dengan email yang sudah ada: `owner@example.com`
4. Tap "Daftar"
5. Verifikasi muncul error message

---

## 6. Testing - Login User (Success)

### # Test Login dengan Kredensial Valid
```bash
flutter test test/api_auth_test.dart --name "should successfully login with valid credentials"
```

**Expected Result**:
- ✅ Status code = 200
- ✅ Response memiliki `access_token`
- ✅ Response memiliki `token_type` = "Bearer"
- ✅ Response memiliki `user` data
- ✅ Response memiliki `roles` array
- ✅ Token disimpan di secure storage

**Manual Steps** (via App UI):
1. Buka aplikasi BBIHUB
2. Tap "Masuk" atau "Login"
3. Isi form:
   - Email: `owner@example.com`
   - Password: `password`
4. Tap "Masuk"
5. Verifikasi redirect ke dashboard
6. Verifikasi user info muncul di drawer/profile

**Test Accounts**:
```
Owner Account:
Email: owner@example.com
Password: password

Admin Account:
Email: admin@example.com  
Password: password

Mechanic Account:
Email: mechanic@example.com
Password: password
```

---

## 7. Testing - Login dengan Email Tidak Terdaftar (Failed)

### # Test Login dengan Email yang Tidak Ada
```bash
flutter test test/api_auth_test.dart --name "should fail login with invalid email"
```

**Expected Result**:
- ❌ Throw exception
- ❌ Error message: "These credentials do not match our records"

**Manual Steps** (via App UI):
1. Buka aplikasi BBIHUB
2. Tap "Masuk"
3. Isi form:
   - Email: `notexist@example.com`
   - Password: `anypassword`
4. Tap "Masuk"
5. Verifikasi muncul error message

---

## 8. Testing - Login dengan Password Salah (Failed)

### # Test Login dengan Password Incorrect
```bash
flutter test test/api_auth_test.dart --name "should fail login with wrong password"
```

**Expected Result**:
- ❌ Throw exception
- ❌ Error message: "These credentials do not match our records"

**Manual Steps** (via App UI):
1. Buka aplikasi BBIHUB
2. Tap "Masuk"
3. Isi form:
   - Email: `owner@example.com`
   - Password: `wrongpassword`
4. Tap "Masuk"
5. Verifikasi muncul error message

---

## 9. Testing - Login dengan Field Kosong (Failed)

### # Test Login dengan Email dan Password Kosong
```bash
flutter test test/api_auth_test.dart --name "should fail login with empty credentials"
```

**Expected Result**:
- ❌ Throw exception
- ❌ Validation error

**Manual Steps** (via App UI):
1. Buka aplikasi BBIHUB
2. Tap "Masuk"
3. Biarkan field kosong
4. Tap "Masuk"
5. Verifikasi muncul error message atau button disabled

---

## 10. Testing - API Configuration

### # Test Base URL Configuration
```bash
flutter test test/api_auth_test.dart --name "should have correct base URL"
```

**Expected Result**:
- ✅ Base URL = `http://10.0.2.2:8000/api/v1/`

### # Test Register Endpoint
```bash
flutter test test/api_auth_test.dart --name "should construct correct register endpoint"
```

**Expected Result**:
- ✅ Register endpoint = `http://10.0.2.2:8000/api/v1/auth/register`

### # Test Login Endpoint
```bash
flutter test test/api_auth_test.dart --name "should construct correct login endpoint"
```

**Expected Result**:
- ✅ Login endpoint = `http://10.0.2.2:8000/api/v1/auth/login`

---

## 11. Testing - Response Structure Validation

### # Test Register Response Structure
```bash
flutter test test/api_auth_test.dart --name "register response should have required structure"
```

**Expected Structure**:
```json
{
  "message": "Registrasi berhasil...",
  "data": {
    "access_token": "string",
    "token_type": "Bearer",
    "user": {
      "id": "uuid",
      "name": "string",
      "email": "string",
      "username": "string",
      "roles": [
        {
          "name": "owner"
        }
      ]
    }
  }
}
```

### # Test Login Response Structure
```bash
flutter test test/api_auth_test.dart --name "login response should have required structure"
```

**Expected Structure**:
```json
{
  "message": "Login berhasil",
  "data": {
    "access_token": "string",
    "token_type": "Bearer",
    "remember": false,
    "expires_in": "session",
    "user": {
      "id": "uuid",
      "name": "string",
      "email": "string",
      "username": "string",
      "roles": []
    }
  }
}
```

---

## 12. Testing - Run All API Auth Tests

### # Run All Authentication Tests
```bash
flutter test test/api_auth_test.dart
```

**Expected Result**:
- ✅ All tests passed
- ✅ No errors or exceptions

### # Run All Tests dengan Verbose Output
```bash
flutter test test/api_auth_test.dart --verbose
```

### # Run All Tests dengan Coverage
```bash
flutter test test/api_auth_test.dart --coverage
```

---

## Network Configuration

### Android Emulator
Base URL menggunakan `10.0.2.2` untuk mengakses `localhost` dari emulator.

```dart
static const String _baseUrl = 'http://10.0.2.2:8000/api/v1/';
```

### iOS Simulator
Gunakan `localhost` langsung:

```dart
static const String _baseUrl = 'http://localhost:8000/api/v1/';
```

### Physical Device
Gunakan IP address komputer di network yang sama:

```dart
static const String _baseUrl = 'http://192.168.1.XXX:8000/api/v1/';
```

---

## Debugging Tips

### Enable Debug Logs
API Service sudah memiliki debug logging. Cek console untuk melihat:
- Request URL
- Request headers
- Request body
- Response status
- Response body

### Check Backend Server
```bash
# Pastikan backend running
php artisan serve

# Check endpoint manually
curl http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"owner@example.com","password":"password"}'
```

### Clear App Data
Jika ada masalah dengan token atau state:

```bash
# Android
flutter clean
flutter build apk
adb uninstall com.bengkelbi.bengkel_online_flutter
flutter run

# iOS
flutter clean
flutter build ios
# Uninstall from simulator manually
flutter run
```

---

## Test Summary Checklist

Gunakan checklist ini untuk memastikan semua test manual sudah dilakukan:

### Register Tests
- [ ] ✅ Register dengan data valid
- [ ] ❌ Register dengan email invalid
- [ ] ❌ Register dengan password lemah
- [ ] ❌ Register dengan password mismatch
- [ ] ❌ Register dengan email duplikat

### Login Tests
- [ ] ✅ Login dengan kredensial valid (Owner)
- [ ] ✅ Login dengan kredensial valid (Admin)
- [ ] ✅ Login dengan kredensial valid (Mechanic)
- [ ] ❌ Login dengan email tidak terdaftar
- [ ] ❌ Login dengan password salah
- [ ] ❌ Login dengan field kosong

### Configuration Tests
- [ ] ✅ Base URL configuration
- [ ] ✅ Register endpoint configuration
- [ ] ✅ Login endpoint configuration

### Response Structure Tests
- [ ] ✅ Register response structure
- [ ] ✅ Login response structure

### UI/UX Tests (Manual Only)
- [ ] UI menampilkan loading indicator saat request
- [ ] Error message ditampilkan dengan jelas
- [ ] Success redirect ke halaman yang benar
- [ ] Token tersimpan di secure storage
- [ ] User bisa logout
- [ ] Tombol disabled saat field kosong

---

## Troubleshooting

### Error: Connection Refused
**Problem**: Cannot connect to backend  
**Solution**: 
- Pastikan backend server running
- Cek firewall/antivirus
- Gunakan IP address yang benar

### Error: Certificate Verification Failed
**Problem**: SSL/TLS error  
**Solution**: 
- Gunakan HTTP untuk development
- Atau tambahkan SSL certificate bypass (development only)

### Error: Token Not Found
**Problem**: App tidak bisa akses protected routes  
**Solution**: 
- Login ulang
- Clear app data
- Check secure storage

---

**Last Updated**: 2025-12-22  
**Flutter Version**: 3.x  
**Dart Version**: 3.x  
**Test Framework**: flutter_test
