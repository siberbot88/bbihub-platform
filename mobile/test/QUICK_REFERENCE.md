# Quick Reference - Manual Testing Commands

Format singkat untuk manual testing API Register dan Login di mobile BBIHUB.

---

## Register Tests

### # Test Register User Baru Valid
```bash
flutter test test/api_auth_test.dart --name "Configuration"
```

### # Test Register Email Invalid
```bash
# Manual UI: Masukkan email format salah
# Expected: Error "Invalid email format"
```

### # Test Register Password Lemah
```bash
# Manual UI: Masukkan password "weak"
# Expected: Error validation password
```

### # Test Register Password Mismatch
```bash
# Manual UI: Password dan konfirmasi berbeda
# Expected: Error "Password confirmation does not match"
```

### # Test Register Email Duplikat
```bash
# Manual UI: Gunakan email "owner@example.com"
# Expected: Error "Email already taken"
```

---

## Login Tests

### # Test Login Kredensial Valid (Owner)
```bash
# Manual UI:
# Email: owner@example.com
# Password: password
# Expected: Redirect ke dashboard
```

### # Test Login Kredensial Valid (Admin)
```bash
# Manual UI:
# Email: admin@example.com
# Password: password
# Expected: Redirect ke dashboard admin
```

### # Test Login Kredensial Valid (Mechanic)
```bash
# Manual UI:
# Email: mechanic@example.com
# Password: password
# Expected: Redirect ke dashboard mechanic
```

### # Test Login Email Tidak Terdaftar
```bash
# Manual UI:
# Email: notexist@example.com
# Password: anypassword
# Expected: Error "Credentials do not match"
```

### # Test Login Password Salah
```bash
# Manual UI:
# Email: owner@example.com
# Password: wrongpassword
# Expected: Error "Credentials do not match"
```

### # Test Login Field Kosong
```bash
# Manual UI:
# Biarkan email dan password kosong
# Expected: Button disabled atau validation error
```

---

## Configuration Tests

### # Test Base URL
```bash
flutter test test/api_auth_test.dart --name "base URL"
```

### # Test Register Endpoint
```bash
flutter test test/api_auth_test.dart --name "register endpoint"
```

### # Test Login Endpoint
```bash
flutter test test/api_auth_test.dart --name "login endpoint"
```

---

## Run All Tests

### # Run Semua API Auth Tests
```bash
flutter test test/api_auth_test.dart
```

### # Run Semua Tests (Include Widget Tests)
```bash
flutter test
```

### # Run dengan Verbose
```bash
flutter test test/api_auth_test.dart --verbose
```

### # Run dengan Coverage
```bash
flutter test test/api_auth_test.dart --coverage
```

---

## Backend Setup (untuk Manual Testing)

### # Start Backend Server
```bash
cd ../backend
php artisan serve
```

### # Seed Database
```bash
php artisan migrate:fresh --seed
```

### # Check API Endpoint
```bash
curl http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"owner@example.com","password":"password"}'
```

---

## Mobile App Setup

### # Run Android Emulator
```bash
flutter run
```

### # Run iOS Simulator
```bash
flutter run -d "iPhone 15 Pro"
```

### # Run pada Device Fisik
```bash
flutter run -d <device-id>
```

### # List Devices
```bash
flutter devices
```

---

## Debugging Commands

### # Enable Verbose Logging
```bash
flutter run --verbose
```

### # Clear Build
```bash
flutter clean
flutter pub get
```

### # Uninstall App (Android)
```bash
adb uninstall com.bengkelbi.bengkel_online_flutter
```

### # View Logs (Android)
```bash
adb logcat | grep flutter
```

### # View Logs (iOS)
```bash
flutter logs
```

---

## Test Accounts

```
Owner:
  Email: owner@example.com
  Password: password

Admin:
  Email: admin@example.com
  Password: password

Mechanic:
  Email: mechanic@example.com
  Password: password
```

---

**Quick Tip**: Untuk melihat detail lengkap setiap test, buka `MANUAL_TESTING_AUTH.md`
