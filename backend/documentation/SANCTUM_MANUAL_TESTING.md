# Manual Testing Guide - Laravel Sanctum Authentication

Panduan testing manual untuk autentikasi Laravel Sanctum di BBIHUB Backend.

---

## Prerequisites

Sebelum memulai testing, pastikan:
- Backend server sudah running (`php artisan serve`)
- Database sudah di-migrate dan seed
- Tool untuk API testing (Postman, cURL, atau Insomnia) sudah terinstall

**Base URL**: `http://localhost:8000/api/v1`

---

## 1. Test User Registration

### #Register User Baru (Owner)
```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "Test Owner",
    "username": "testowner",
    "email": "testowner@example.com",
    "password": "SecurePassword123!",
    "password_confirmation": "SecurePassword123!"
  }'
```

**Expected Response** (Status 201):
```json
{
  "message": "Registrasi berhasil...",
  "data": {
    "access_token": "1|xxxxx...",
    "token_type": "Bearer",
    "user": {
      "id": "uuid",
      "name": "Test Owner",
      "email": "testowner@example.com",
      "roles": [{"name": "owner"}]
    }
  }
}
```

**✅ Verification**:
- Status code = 201
- Response memiliki `access_token`
- User memiliki role `owner`
- Token type = `Bearer`

---

## 2. Test User Login

### #Login dengan Email dan Password
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "testowner@example.com",
    "password": "SecurePassword123!"
  }'
```

**Expected Response** (Status 200):
```json
{
  "message": "Login berhasil",
  "data": {
    "access_token": "2|xxxxx...",
    "token_type": "Bearer",
    "remember": false,
    "expires_in": "session",
    "user": {...}
  }
}
```

**✅ Verification**:
- Status code = 200
- Menerima `access_token` baru
- Field `remember` = false
- Field `expires_in` = "session"

---

### #Login dengan Remember Me
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "testowner@example.com",
    "password": "SecurePassword123!",
    "remember": true
  }'
```

**Expected Response** (Status 200):
```json
{
  "data": {
    "access_token": "3|xxxxx...",
    "remember": true,
    "expires_in": "30 days"
  }
}
```

**✅ Verification**:
- Field `remember` = true
- Field `expires_in` = "30 days"
- Token memiliki expiration date 30 hari

---

### #Login dengan Revoke Other Tokens
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "testowner@example.com",
    "password": "SecurePassword123!",
    "revoke_others": true
  }'
```

**✅ Verification**:
- Token lama tidak bisa digunakan
- Hanya token baru yang valid

---

## 3. Test Token Authentication

### #Akses Protected Route dengan Token
```bash
curl -X GET http://localhost:8000/api/v1/auth/user \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Accept: application/json"
```

**Expected Response** (Status 200):
```json
{
  "message": "User data retrieved",
  "data": {
    "id": "uuid",
    "name": "Test Owner",
    "email": "testowner@example.com",
    "roles": [...],
    "subscription_status": "...",
    "has_premium_access": true/false
  }
}
```

**✅ Verification**:
- Status code = 200
- Data user sesuai dengan yang login
- Termasuk informasi subscription

---

### #Akses Tanpa Token (Expected Failure)
```bash
curl -X GET http://localhost:8000/api/v1/auth/user \
  -H "Accept: application/json"
```

**Expected Response** (Status 401):
```json
{
  "message": "Unauthenticated."
}
```

**✅ Verification**:
- Status code = 401
- Message = "Unauthenticated."

---

### #Akses dengan Token Invalid (Expected Failure)
```bash
curl -X GET http://localhost:8000/api/v1/auth/user \
  -H "Authorization: Bearer invalid-token-12345" \
  -H "Accept: application/json"
```

**Expected Response** (Status 401):
```json
{
  "message": "Unauthenticated."
}
```

**✅ Verification**:
- Status code = 401
- Token invalid ditolak

---

## 4. Test Multiple Devices/Tokens

### #Login dari Device 1 (Mobile)
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "testowner@example.com",
    "password": "SecurePassword123!"
  }'
```
**Simpan token sebagai**: `MOBILE_TOKEN`

---

### #Login dari Device 2 (Web)
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "testowner@example.com",
    "password": "SecurePassword123!"
  }'
```
**Simpan token sebagai**: `WEB_TOKEN`

---

### #Test Kedua Token Bersamaan
```bash
# Request dari Mobile
curl -X GET http://localhost:8000/api/v1/auth/user \
  -H "Authorization: Bearer MOBILE_TOKEN" \
  -H "Accept: application/json"

# Request dari Web
curl -X GET http://localhost:8000/api/v1/auth/user \
  -H "Authorization: Bearer WEB_TOKEN" \
  -H "Accept: application/json"
```

**✅ Verification**:
- Kedua token berfungsi secara independen
- Kedua request berhasil (Status 200)

---

## 5. Test Token Logout

### #Logout Current Token Only
```bash
curl -X POST http://localhost:8000/api/v1/auth/logout \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Accept: application/json" \
  -d '{}'
```

**Expected Response** (Status 200):
```json
{
  "message": "Logout berhasil"
}
```

**✅ Verification**:
- Status code = 200
- Token yang digunakan tidak bisa dipakai lagi
- Token lain (dari device lain) masih aktif

---

### #Logout All Tokens
```bash
curl -X POST http://localhost:8000/api/v1/auth/logout \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Accept: application/json" \
  -d '{
    "all": true
  }'
```

**✅ Verification**:
- Semua token user dihapus
- Semua device logout
- Semua token tidak bisa digunakan lagi

---

## 6. Test Change Password

### #Change Password dengan Token Valid
```bash
curl -X POST http://localhost:8000/api/v1/auth/change-password \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "current_password": "SecurePassword123",
    "new_password": "NewSecurePassword456!",
    "new_password_confirmation": "NewSecurePassword456!"
  }'
```

**Expected Response** (Status 200):
```json
{
  "message": "Password berhasil diperbarui"
}
```

**✅ Verification**:
- Status code = 200
- Password berubah (test login dengan password baru)
- Field `must_change_password` = false

---

### #Login dengan Password Baru
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "testowner@example.com",
    "password": "NewSecurePassword456!"
  }'
```

**✅ Verification**:
- Login berhasil dengan password baru
- Login gagal dengan password lama

---

## 7. Test Role-Based Access Control

### #Login sebagai Owner
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "owner@example.com",
    "password": "password"
  }'
```
**Simpan token sebagai**: `OWNER_TOKEN`

---

### #Akses Owner-Only Route
```bash
curl -X GET http://localhost:8000/api/v1/owners/workshops \
  -H "Authorization: Bearer OWNER_TOKEN" \
  -H "Accept: application/json"
```

**✅ Verification**:
- Owner bisa akses route `/api/v1/owners/*`
- Status code != 403 (Forbidden)

---

### #Login sebagai Admin
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "password"
  }'
```
**Simpan token sebagai**: `ADMIN_TOKEN`

---

### #Akses Admin-Only Route
```bash
curl -X GET http://localhost:8000/api/v1/admins/dashboard/stats \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Accept: application/json"
```

**✅ Verification**:
- Admin bisa akses route `/api/v1/admins/*`
- Status code != 403 (Forbidden)

---

### #Test Cross-Role Access (Expected Failure)
```bash
# Owner mencoba akses Admin route
curl -X GET http://localhost:8000/api/v1/admins/dashboard/stats \
  -H "Authorization: Bearer OWNER_TOKEN" \
  -H "Accept: application/json"
```

**Expected Response** (Status 403):
```json
{
  "message": "This action is unauthorized."
}
```

**✅ Verification**:
- Status code = 403
- Owner tidak bisa akses admin route

---

## 8. Test Token Inspection (Debug Endpoint)

### #Inspect Token Details
```bash
curl -X GET http://localhost:8000/api/v1/debug/token \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Accept: application/json"
```

**Expected Response** (Status 200):
```json
{
  "ok": true,
  "tokenable_type": "App\\Models\\User",
  "tokenable_id": "user-uuid"
}
```

**✅ Verification**:
- Response menampilkan informasi token
- `tokenable_type` = "App\\Models\\User"
- `tokenable_id` sesuai dengan user

---

## 9. Test Rate Limiting

### #Test Login Rate Limiting
```bash
# Lakukan 6x login dengan password salah secara berturut-turut
for i in {1..6}; do
  curl -X POST http://localhost:8000/api/v1/auth/login \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -d '{
      "email": "testowner@example.com",
      "password": "wrongpassword"
    }'
  echo "\n--- Attempt $i ---\n"
done
```

**✅ Verification**:
- Attempt 1-5: Status 422 (Validation Error)
- Attempt 6: Status 422 dengan message "Too many login attempts"
- Account ter-lock untuk beberapa waktu

---

### #Test Email Resend Rate Limiting
```bash
# Lakukan 7x request resend verification email
for i in {1..7}; do
  curl -X POST http://localhost:8000/api/v1/email/resend \
    -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
    -H "Accept: application/json"
  echo "\n--- Attempt $i ---\n"
done
```

**✅ Verification**:
- Attempt 1-6: Berhasil atau sukses
- Attempt 7: Status 429 (Too Many Requests)

---

## 10. Test Forgot Password Flow (dengan Sanctum)

### #Request Password Reset OTP
```bash
curl -X POST http://localhost:8000/api/v1/auth/forgot-password \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "testowner@example.com"
  }'
```

**✅ Verification**:
- Status code = 200
- OTP dikirim ke email (check log atau email)

---

### #Verify OTP
```bash
curl -X POST http://localhost:8000/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "testowner@example.com",
    "otp": "123456"
  }'
```

**✅ Verification**:
- Status code = 200 jika OTP benar
- Status code = 422 jika OTP salah

---

### #Reset Password dengan OTP Valid
```bash
curl -X POST http://localhost:8000/api/v1/auth/reset-password \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "testowner@example.com",
    "otp": "123456",
    "password": "NewResetPassword789!",
    "password_confirmation": "NewResetPassword789!"
  }'
```

**✅ Verification**:
- Password berhasil di-reset
- Bisa login dengan password baru

---

## 11. Test Token Expiration

### #Login dengan Remember = true
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "testowner@example.com",
    "password": "SecurePassword123!",
    "remember": true
  }'
```

### #Check Token Expiration di Database
```bash
php artisan tinker
```

Dalam tinker:
```php
use Laravel\Sanctum\PersonalAccessToken;

// Ganti dengan token yang didapat
$token = PersonalAccessToken::findToken('YOUR_TOKEN');
echo $token->expires_at; // Harus 30 hari dari sekarang
echo $token->expires_at->diffForHumans(); // "30 days from now"
```

**✅ Verification**:
- Token memiliki `expires_at` field
- Expires 30 hari dari sekarang

---

## 12. Test Email Verification

### #Check Email Verification Status
```bash
curl -X GET http://localhost:8000/api/v1/auth/user \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Accept: application/json"
```

**Response akan mencakup**:
```json
{
  "data": {
    "email_verified_at": null  // atau timestamp jika sudah verified
  }
}
```

---

### #Resend Verification Email
```bash
curl -X POST http://localhost:8000/api/v1/email/resend \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Accept: application/json"
```

**✅ Verification**:
- Email verification link dikirim
- Status code = 200

---

## Test Summary Checklist

Gunakan checklist ini untuk memastikan semua test sudah dilakukan:

- [ ] **Registration**: User bisa register dan menerima token
- [ ] **Login**: User bisa login dengan email/password
- [ ] **Remember Me**: Token dengan remember = true memiliki expiration 30 hari
- [ ] **Revoke Others**: Login dengan revoke_others menghapus token lain
- [ ] **Protected Routes**: Token bisa akses protected routes
- [ ] **No Token**: Request tanpa token ditolak (401)
- [ ] **Invalid Token**: Token invalid ditolak (401)
- [ ] **Multiple Tokens**: Multiple tokens berfungsi independen
- [ ] **Logout Single**: Logout menghapus current token saja
- [ ] **Logout All**: Logout dengan all=true menghapus semua token
- [ ] **Change Password**: User bisa ganti password
- [ ] **Role-Based Access**: Owner/Admin/Mechanic hanya akses route sesuai role
- [ ] **Cross-Role Rejection**: Role tidak bisa akses route role lain (403)
- [ ] **Token Debug**: Debug endpoint menampilkan info token
- [ ] **Rate Limiting**: Login dan email resend memiliki rate limit
- [ ] **Forgot Password**: Flow forgot password berfungsi
- [ ] **Token Expiration**: Remember token memiliki expiration date
- [ ] **Email Verification**: Email verification flow berfungsi

---

## Tools & Resources

### Postman Collection
Import collection ini ke Postman untuk testing lebih mudah:
- File: `BBIHUB_Sanctum_Tests.postman_collection.json` (create this yourself from the commands above)

### Environment Variables
Setup environment variables di Postman/Insomnia:
- `BASE_URL`: http://localhost:8000/api/v1
- `ACCESS_TOKEN`: Token dari login response
- `OWNER_TOKEN`: Token untuk owner
- `ADMIN_TOKEN`: Token untuk admin

### Database Inspection
Check token di database:
```bash
php artisan tinker
```

```php
// List all tokens
\Laravel\Sanctum\PersonalAccessToken::all();

// Find token
$token = \Laravel\Sanctum\PersonalAccessToken::findToken('YOUR_TOKEN');

// Count user tokens
$user = \App\Models\User::find('USER_ID');
$user->tokens()->count();

// Delete all user tokens
$user->tokens()->delete();
```

---

## Troubleshooting

### Token tidak valid setelah login
- Pastikan menggunakan header `Authorization: Bearer TOKEN`
- Pastikan tidak ada spasi ekstra di token
- Check database `personal_access_tokens` table

### 401 Unauthenticated meskipun token valid
- Check middleware `auth:sanctum` di route
- Verify Sanctum package terinstall
- Check config `sanctum.php`

### Role-based access tidak berfungsi
- Check user memiliki role yang benar: `$user->roles`
- Verify middleware `role:owner,sanctum`
- Check Spatie Permission package configuration

---

**Last Updated**: 2025-12-22  
**Version**: 1.0  
**Author**: BBIHUB Testing Team
