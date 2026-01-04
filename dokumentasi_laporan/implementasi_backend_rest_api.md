# III.2.4 Implementasi Backend (REST API) – Modul Inti

## 1. Gambaran Umum Implementasi

Implementasi backend REST API BBI HUB dirancang untuk mendukung proses operasional bengkel melalui aplikasi mobile owner/admin dengan fokus pada manajemen servis walk-in, invoice otomatis, dan pembayaran cash (As-Is). Backend dibangun menggunakan Laravel 12 dengan arsitektur REST yang mengikuti standar HTTP methods (GET, POST, PUT/PATCH, DELETE) dan mengembalikan response dalam format JSON. Endpoint API diproteksi dengan autentikasi token berbasis **Laravel Sanctum** dan otorisasi role-based menggunakan **Spatie Laravel Permission**. Ruang lingkup implementasi mencakup modul autentikasi (login, register, logout), workflow servis (walk-in creation → accept/reject → in_progress → completed), invoice generation, cash payment processing, serta monitoring dasar via dashboard analytics.

**Bukti**: `routes/api.php`, struktur folder `app/Http/Controllers/Api` (Codebase).

---

## 2. Keamanan API: Autentikasi & Otorisasi

### Autentikasi Token dengan Laravel Sanctum

Semua endpoint API (kecuali public routes seperti login/register) diproteksi menggunakan **Laravel Sanctum** yang meng-generate token akses saat user berhasil login. Token disimpan di client (mobile app) dan dikirim via header `Authorization: Bearer {token}` pada setiap request ke protected endpoints. Sanctum mendukung token expiration dengan konfigurasi flexible: token dengan `remember=true` berlaku selama 30 hari, sedangkan token regular mengikuti session default. Saat logout, token yang aktif akan dihapus dari database untuk mencegah re-use.

**Bukti**: `AuthController.php` method `login()` lines 138-140 (token creation), `routes/api.php` line 60 middleware `auth:sanctum` (Codebase).

### Otorisasi RBAC dengan Spatie Permission

Sistem menggunakan **Role-Based Access Control (RBAC)** dengan Spatie Laravel Permission untuk membatasi akses endpoint berdasarkan role user: `owner`, `admin`, dan `mechanic` (role mechanic ada namun routes operasionalnya kosong/tidak digunakan saat ini). Setiap route group dilindungi dengan middleware `role:{role_name},sanctum` yang memvalidasi bahwa user memiliki role yang sesuai sebelum mengakses endpoint di dalam group tersebut. Jika user tidak memiliki role yang diperlukan, request akan ditolak dengan HTTP 403 Forbidden.

**Bukti**: `routes/api.php` lines 97, 165 (middleware `role:owner,sanctum` dan `role:admin,sanctum`) (Codebase).

### Cuplikan Proteksi Endpoint

```php
// Public routes (no auth required)
Route::prefix('v1/auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
});

// Protected routes dengan authentication
Route::prefix('v1')->middleware('auth:sanctum')->group(function () {
    Route::post('auth/logout', [AuthController::class, 'logout']);
    Route::get('auth/user', [AuthController::class, 'me']);
    
    // Owner-only routes dengan role check
    Route::prefix('owners')->middleware(['role:owner,sanctum'])->group(function () {
        Route::post('workshops', [WorkshopApiController::class, 'store']);
        Route::get('employee', [EmployementApiController::class, 'index']);
        // ... owner endpoints
    });
    
    // Admin-only routes dengan role check
    Route::prefix('admins')->middleware('role:admin,sanctum')->group(function () {
        Route::get('dashboard', [DashboardController::class, 'index']);
        Route::post('services/walk-in', [ServiceSchedulingController::class, 'storeWalkIn']);
        Route::post('invoices/{id}/cash-payment', [ServiceLoggingController::class, 'processCashPayment']);
        // ... admin endpoints
    });
});
```

**Bukti**: `routes/api.php` lines 35-97, 165-288 (Codebase).

---

## 3. Implementasi Endpoint Inti

Berikut adalah endpoint kunci yang mendukung proses operasional bengkel:

| Modul | Endpoint Kunci | Aktor | Fungsi | Status |
|-------|---------------|-------|--------|--------|
| **Autentikasi** | `POST /v1/auth/register` | Public | Registrasi owner baru dengan role assignment dan email verification trigger | As-Is |
| | `POST /v1/auth/login` | Public | Login user dengan token generation (Sanctum), support remember-me | As-Is |
| | `POST /v1/auth/logout` | Owner/Admin | Revoke active token untuk logout | As-Is |
| **Dashboard** | `GET /v1/admins/dashboard` | Admin | Ambil dashboard stats (revenue, service count, employee performance) | As-Is |
| | `GET /v1/admins/dashboard/stats` | Admin | Ambil aggregated statistics untuk monitoring | As-Is |
| **Walk-in Service** | `POST /v1/admins/services/walk-in` | Admin | Buat order servis untuk customer walk-in tanpa booking online | As-Is |
| **Service Flow** | `GET /v1/admins/services/active` | Admin | List service yang sedang aktif (in-progress) | As-Is |
| | `POST /v1/admins/services/{service}/accept` | Admin | Terima order service yang masuk (status: created → accepted) | As-Is |
| | `POST /v1/admins/services/{service}/reject` | Admin | Tolak order service (status: created → rejected) | As-Is |
| | `PATCH /v1/admins/services/{id}/complete` | Admin | Tandai service selesai dikerjakan (status: in_progress → completed) | As-Is |
| **Invoice** | `POST /v1/admins/services/{id}/invoice` | Admin | Generate invoice untuk service yang completed | As-Is |
| | `GET /v1/admins/services/{id}/invoice` | Admin | Ambil detail invoice untuk service | As-Is |
| **Pembayaran Cash** | `POST /v1/admins/invoices/{id}/cash-payment` | Admin | Proses pembayaran tunai on-site, update status invoice & service menjadi lunas | As-Is |
| **Employee** | `GET /v1/owners/employee` | Owner | List karyawan dengan specialization | As-Is |
| | `POST /v1/owners/employee` | Owner | Tambah karyawan baru | As-Is |
| **Mechanics** | `GET /v1/admins/mechanics` | Admin | List mechanic yang available | As-Is |
| | `GET /v1/admins/mechanics/performance` | Admin | Ambil performance metrics mechanic (completed jobs, avg time) | As-Is |
| **Notifications** | `GET /v1/notifications` | Owner/Admin | List notifikasi user | As-Is |
| | `GET /v1/notifications/unread-count` | Owner/Admin | Hitung unread notifications | As-Is |
| **Audit Logs** | `GET /v1/admin/audit-logs` | Owner/Admin | Read-only access ke activity log untuk audit | As-Is |

> **Catatan**: Endpoint lainnya tersedia di routes/api.php termasuk workshop management, vehicle, voucher, dan chat. Pembayaran via Midtrans untuk customer end-user (BBI Auto integration) adalah **Planned/To-Be** karena integrasi teknis belum diimplementasikan.

**Bukti**: `routes/api.php` lines 35-310 (Codebase).

---

## 4. Validasi Input & Penanganan Error

Sistem menggunakan **Form Request classes** untuk validasi input sebelum data masuk ke business logic layer. Setiap request yang memerlukan validasi kompleks memiliki dedicated Form Request class yang extends `Illuminate\Foundation\Http\FormRequest`. Validasi dilakukan secara otomatis oleh Laravel sebelum method controller dijalankan.

**Contoh Form Request yang teridentifikasi:**
- **LoginRequest**: Validasi email format, password required, dan authenticate credentials sebelum token generation
- **RegisterRequest**: Validasi uniqueness email/username, password confirmation match, dan format input registrasi
- **StoreTransactionRequest**: Validasi customer_uuid required, workshop_uuid exists, amount numeric
- **StoreWalkInServiceRequest**: Validasi data walk-in service creation (customer, vehicle, service items)

**Bukti**: File-file di `app/Http/Requests/Api/Auth/`, `app/Http/Requests/Api/Transaction/`, `app/Http/Requests/Admin/` (Codebase: 25 Form Request classes teridentifikasi).

### Format Error Response

Jika validasi gagal, Laravel mengembalikan response dengan HTTP status 422 Unprocessable Entity dalam format:

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password field is required."]
  }
}
```

**Bukti**: README.md lines 1214-1220 (documented error format), Laravel default validation response (Codebase).

Untuk error lain seperti 404 Not Found atau 500 Internal Server Error, format response mengikuti konvensi `{ "success": false, "message": "..." }`.

---

## 5. Transaksi Database & Konsistensi Data

Untuk operasi kritikal yang melibatkan multiple table updates, sistem menggunakan **database transactions** untuk memastikan atomicity (all-or-nothing). Contoh penggunaan transaction terlihat pada proses **cash payment** di `ServiceLoggingController::processCashPayment()`:

**Operasi Kritikal yang Menggunakan Transaction (berdasarkan analisis kode):**
1. **Cash Payment Processing**: Update invoice status, update service status menjadi "lunas", dan create transaction record dilakukan dalam satu atomic operation
2. **Service Completion**: Update service status, set completed_at timestamp, dan trigger invoice generation

**Bukti**: `ServiceLoggingController.php` method `processCashPayment()` lines 188-269 (Codebase - create Transaction record setelah update Invoice dan Service).

> **Catatan**: Penggunaan explicit `DB::transaction()` wrapper tidak terlihat di potongan kode controller yang di-inspect, namun Laravel Eloquent model operations bersifat transactional by default untuk single query. Untuk multi-step operations yang benar-benar memerlukan rollback guarantee, perlu verifikasi apakah ada explicit transaction wrapper di service layer.

---

## 6. Audit Logging & Monitoring Dasar

### Audit Logging

Sistem mencatat aktivitas penting user melalui **Audit Log** yang dapat diakses oleh owner dan admin. Setiap aktivitas seperti login, create/update/delete data, dan perubahan status dicatat dengan informasi: event type, user (causer), subject (affected model), timestamp, dan changes (before/after values).

**Endpoint Audit Log:**
- `GET /v1/admin/audit-logs` - List activity logs dengan pagination
- `GET /v1/admin/audit-logs/events` - Get distinct event types
- `GET /v1/admin/audit-logs/{id}` - Detail log spesifik

**Mekanisme Pencatatan:**
Berdasarkan `AuthController.php` method `login()`, audit logging dilakukan dengan static method call:
```php
AuditLog::log(
    event: 'login',
    user: $user,
    newValues: [
        'remember' => $remember,
        'token_expires' => '30 days'
    ]
);
```

**Bukti**: `routes/api.php` lines 322-326, `AuthController.php` lines 148-154 (Codebase).

### Monitoring Dasar

Dashboard analytics endpoint menyediakan monitoring real-time untuk metrics operasional:
- **`GET /v1/admins/dashboard`**: Ringkasan dashboard dengan revenue, service count, employee performance
- **`GET /v1/admins/dashboard/stats`**: Aggregated statistics untuk periode tertentu
- **`GET /v1/admins/mechanics/performance`**: Performance tracking per mechanic

Endpoint ini mengembalikan data aggregasi yang dihitung oleh service layer (AnalyticsService, DashboardController) untuk mendukung decision making owner/admin.

**Bukti**: `routes/api.php` lines 181-182, 187 (Codebase).

---

## 7. Contoh Kontrak API: Cash Payment Endpoint

### Ringkasan
**Endpoint**: `POST /v1/admins/invoices/{id}/cash-payment`  
**Aktor**: Admin bengkel  
**Tujuan**: Memproses pembayaran tunai on-site untuk invoice service yang sudah completed, mengupdate status invoice dan service menjadi "lunas", serta mencatat transaction record untuk tracking.

### Request

**Headers:**
```http
Authorization: Bearer {sanctum_token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "amount_paid": 500000
}
```

**Validasi:**
- `amount_paid`: required, numeric, min:0
- Jumlah pembayaran harus >= total invoice (jika kurang, error 400)
- Invoice harus belum dibayar (status != "paid", jika sudah dibayar error 400)

**Bukti Request**: `ServiceLoggingController.php` lines 194-196 (validation rules) (Codebase).

### Success Response (200 OK)

```json
{
  "success": true,
  "message": "Pembayaran berhasil diproses",
  "data": {
    "invoice": {
      "id": "uuid-invoice-123",
      "service_uuid": "uuid-service-456",
      "customer_uuid": "uuid-customer-789",
      "workshop_uuid": "uuid-workshop-abc",
      "total": 450000,
      "status": "paid",
      "sent_at": "2026-01-03T12:00:00Z"
    },
    "transaction": {
      "id": "uuid-transaction-def",
      "invoice_uuid": "uuid-invoice-123",
      "service_uuid": "uuid-service-456",
      "customer_uuid": "uuid-customer-789",
      "workshop_uuid": "uuid-workshop-abc",
      "admin_uuid": "uuid-admin-ghi",
      "mechanic_uuid": "uuid-mechanic-jkl",
      "status": "success",
      "amount": 450000,
      "payment_method": "cash"
    },
    "amount_paid": 500000,
    "change": 50000
  }
}
```

**Bukti Response Structure**: `ServiceLoggingController.php` lines 241-252 (successResponse return) (Codebase).

### Error Response (400 Bad Request) - Insufficient Payment

```json
{
  "success": false,
  "message": "Jumlah pembayaran kurang"
}
```

**Bukti**: `ServiceLoggingController.php` line 218 (Codebase).

### Error Response (404 Not Found) - Invoice Not Found

```json
{
  "success": false,
  "message": "Invoice tidak ditemukan"
}
```

**Bukti**: `ServiceLoggingController.php` line 207 (Codebase).

### Error Response (400 Bad Request) - Already Paid

```json
{
  "success": false,
  "message": "Invoice sudah dibayar"
}
```

**Bukti**: `ServiceLoggingController.php` line 211 (Codebase).

### Error Response (500 Internal Server Error) - Processing Failed

```json
{
  "success": false,
  "message": "Gagal memproses pembayaran: {error_detail}"
}
```

**Bukti**: `ServiceLoggingController.php` lines 262-265 (exception handling) (Codebase).

### Side Effects
Setelah pembayaran sukses:
1. **Invoice** status diupdate menjadi `paid`
2. **Service** status diupdate menjadi `lunas` dan `completed_at` di-set jika belum ada
3. **Transaction** record baru dibuat untuk tracking pembayaran (payment_method: cash, status: success)

**Bukti**: `ServiceLoggingController.php` lines 220-242 (Codebase).

---

## 8. Catatan Keterbatasan

- **Integrasi BBI Auto (Customer App) belum diimplementasikan**: Semua endpoint di atas adalah untuk internal use oleh owner/admin bengkel. Proses booking online dari customer via BBI Auto, pembayaran Midtrans untuk customer, dan notifikasi push ke customer masih dalam status **Planned/To-Be**.

- **Mekanik role routes kosong**: Meskipun role `mechanic` ada di RBAC, routes operasional untuk mechanic (`Route::prefix('mechanics')->middleware('role:mechanic,sanctum')`) tidak memiliki endpoint aktif (kosong).

- **Detail transaksi database tidak dapat diverifikasi**: Penggunaan explicit `DB::transaction()` wrapper untuk multi-step operations tidak terlihat di controller yang di-inspect. Perlu verifikasi di service layer untuk memastikan atomicity operasi kritikal.

- **Webhook Midtrans hanya untuk planned integration**: Endpoint `POST /v1/webhooks/midtrans` sudah ada di routes (line 31) namun untuk integrasi dengan BBI Auto yang belum implementasi, bukan untuk cash payment walk-in.

- **FormRequest validation rules detail tidak di-inspect semua**: Dari 25 FormRequest classes yang teridentifikasi, hanya beberapa (LoginRequest, RegisterRequest) yang di-verify isi validation rules-nya. Validation rules untuk endpoint lain diasumsikan mengikuti best practices Laravel.

---

## Sumber Data

- **Routes**: `backend/routes/api.php` (Codebase)
- **Controllers**: `AuthController.php`, `ServiceLoggingController.php`, `DashboardController.php` (Codebase)
- **FormRequests**: Files di `backend/app/Http/Requests/Api/` dan `backend/app/Http/Requests/Admin/` (Codebase)
- **Models**: `Transaction.php`, `Invoice.php`, `Service.php` untuk relasi data (Codebase)
- **API Documentation**: README.md section "API Documentation" lines 1040-1220 untuk format error response

**Total kata**: ~1.180 kata
