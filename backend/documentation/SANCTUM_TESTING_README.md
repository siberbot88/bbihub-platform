# Testing Sanctum - BBIHUB Backend

Testing suite lengkap untuk Laravel Sanctum authentication di BBIHUB Backend.

## 📁 File Testing

- **Automated Tests**: `tests/Feature/Auth/SanctumAuthenticationTest.php`
- **Manual Testing Guide**: `documentation/SANCTUM_MANUAL_TESTING.md`

## 🚀 Menjalankan Automated Tests

### Run Semua Sanctum Tests
```bash
php artisan test tests/Feature/Auth/SanctumAuthenticationTest.php
```

### Run dengan Output Detail
```bash
php artisan test tests/Feature/Auth/SanctumAuthenticationTest.php --testdox
```

### Run Specific Test
```bash
php artisan test --filter=test_login_returns_valid_token
```

### Run dengan Coverage (jika ada phpunit coverage)
```bash
vendor/bin/phpunit tests/Feature/Auth/SanctumAuthenticationTest.php --coverage-html coverage
```

## ✅ Test Coverage (15 Tests, 71 Assertions)

### Authentication Tests
- ✅ **Register creates user and returns token** - Verifikasi registrasi user baru
- ✅ **Login returns valid token** - Verifikasi login dan token generation
- ✅ **Token can access protected routes** - Token bisa akses route yang dilindungi

### Authorization Tests  
- ✅ **Protected route without token is rejected** - Request tanpa token ditolak (401)
- ✅ **Invalid token is rejected** - Token invalid ditolak (401)

### Token Management Tests
- ✅ **Logout deletes current token** - Logout menghapus token saat ini
- ✅ **Logout all deletes all tokens** - Logout dengan parameter `all=true` menghapus semua token
- ✅ **Remember me creates long lived token** - Token dengan remember=true memiliki expiration 30 hari
- ✅ **Revoke others deletes previous tokens** - Login dengan revoke_others=true menghapus token lama

### Multi-Device Tests
- ✅ **Multiple concurrent tokens work independently** - Multiple tokens dari device berbeda bekerja independen
- ✅ **Token has correct abilities** - Token memiliki abilities yang benar

### Security Tests
- ✅ **Change password with valid token** - User bisa ganti password dengan token yang valid
- ✅ **Role based access control** - Role-based access control (Owner/Admin/Mechanic) berfungsi
- ✅ **Expired token is rejected** - Token yang expired ditolak (401)

### Configuration Tests
- ✅ **Sanctum guard is configured correctly** - Konfigurasi Sanctum guard sudah benar

## 🧪 Manual Testing

Untuk manual testing menggunakan curl atau Postman, ikuti panduan lengkap di:
```
documentation/SANCTUM_MANUAL_TESTING.md
```

Panduan manual testing mencakup:
- User Registration
- User Login (with/without remember me)
- Token Authentication
- Multiple Devices/Tokens
- Token Logout
- Change Password
- Role-Based Access Control (Owner/Admin/Mechanic)
- Rate Limiting
- Password Reset Flow
- Token Expiration
- Email Verification

## 📊 Test Results

**Status**: ✅ **ALL TESTS PASSING**

```
Tests:    15 passed (71 assertions)
Duration: ~6-7 seconds
```

## 🔧 Troubleshooting

### Test Gagal karena Password Validation
Jika test `register_creates_user_and_returns_token` gagal dengan error "password has appeared in a data leak", pastikan menggunakan password yang unique dan complex:
- Minimum 8 karakter
- Mixed case (huruf besar dan kecil)
- Angka
- Symbol (!@#$%^&*)
- Tidak muncul di data breach database

### Test Gagal karena Token Caching
Jika test logout atau token deletion gagal, masalahnya biasanya adalah token caching. Solution:
- Gunakan `assertDatabaseMissing()` untuk verifikasi deletion
- Gunakan `PersonalAccessToken::findToken()` yang return `null` untuk token yang dihapus

### Database Refresh Issues
Jika test gagal karena data sudah ada, pastikan test menggunakan `RefreshDatabase` trait:
```php
use Illuminate\Foundation\Testing\RefreshDatabase;

class SanctumAuthenticationTest extends TestCase
{
    use RefreshDatabase;
}
```

## 📝 Continuous Integration

Untuk CI/CD pipeline, tambahkan command ini:

```yaml
# .github/workflows/tests.yml
- name: Run Sanctum Tests
  run: php artisan test tests/Feature/Auth/SanctumAuthenticationTest.php
```

## 🔐 Security Considerations

Testing ini memverifikasi:
- ✅ Password hashing menggunakan bcrypt
- ✅ Token security dengan Sanctum
- ✅ Rate limiting untuk login dan password reset
- ✅ Password strength validation
- ✅ Role-based access control
- ✅ Token expiration
- ✅ Multi-device token management

## 📚 Resources

- [Laravel Sanctum Documentation](https://laravel.com/docs/sanctum)
- [PHPUnit Documentation](https://phpunit.de/documentation.html)
- [Laravel Testing Documentation](https://laravel.com/docs/testing)

---

**Last Updated**: 2025-12-22  
**Test Suite Version**: 1.0  
**Laravel Version**: 11.x  
**PHPUnit Version**: 11.x
