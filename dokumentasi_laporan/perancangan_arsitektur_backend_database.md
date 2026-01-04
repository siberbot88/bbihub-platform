# III.2.3 Perancangan Arsitektur Backend dan Basis Data

## 1. Pendahuluan

Perancangan arsitektur backend dan basis data bertujuan untuk menyediakan infrastruktur yang terstruktur dan scalable dalam mendukung proses bisnis sistem BBI HUB, khususnya untuk manajemen servis bengkel, pemrosesan invoice dan pembayaran, tracking aktivitas operasional, serta audit logging. Arsitektur ini dirancang mengikuti pola layered architecture dengan pemisahan tanggung jawab (separation of concerns) antara presentation layer (Controller), business logic layer (Service), dan data access layer (Model/Repository). Database dirancang dengan skema relasional yang menghubungkan entitas utama seperti user, workshop, transaction, service, dan audit log untuk memastikan integritas data dan mendukung analitik operasional.

---

## III.2.3.1 Rancangan Struktur Modul Backend

Struktur backend mengikuti pola **Controller → Service → Model** yang memisahkan logika bisnis dari layer presentasi dan akses data. Controller bertanggung jawab menerima HTTP request dan mengembalikan response, Service mengenkapsulasi business logic kompleks seperti kalkulasi, validasi bisnis, dan orkestrasi multiple model, sedangkan Model (Eloquent ORM) menangani interaksi langsung dengan database termasuk relasi antar tabel.

**Bukti**: Struktur folder backend terletak di `backend/app/Http/Controllers/Api`, `backend/app/Services`, dan `backend/app/Models` (Codebase).

### Tabel A: Struktur Modul Backend

| No | Modul | Controller | Service | Model | Bukti |
|----|-------|-----------|---------|-------|-------|
| 1 | Autentikasi | `Api\AuthController.php` | Tidak ada | `User.php` | Codebase |
| 2 | Transaksi Servis | `Api\TransactionController.php` | `TransactionService.php` | `Transaction.php`, `TransactionItem.php` | Codebase |
| 3 | Dashboard Analytics | `Api\DashboardController.php`, `Api\Owner\AnalyticsController.php` | `AnalyticsService.php` | `Transaction.php`, `Service.php`, `Employment.php` | Codebase |
| 4 | Membership & Subscription | `Api\MembershipController.php`, `Api\OwnerSubscriptionController.php` | `MembershipService.php`, `OwnerSubscriptionService.php` | `Membership.php`, `OwnerSubscription.php` | Codebase |
| 5 | Webhook Midtrans | `Api\MidtransWebhookController.php` | `MidtransService.php` | `Transaction.php`, `Invoice.php` | Codebase |
| 6 | Invoice & Item | `Api\InvoiceController.php` | Tidak ada | `Invoice.php`, `InvoiceItem.php` | Codebase |
| 7 | Layanan Servis | `Api\ServiceApiController.php` | `ServiceService.php` | `Service.php`, `ServiceType.php` | Codebase |
| 8 | Workshop | `Api\Owner\WorkshopApiController.php` | Tidak ada | `Workshop.php`, `WorkshopDocument.php` | Codebase |
| 9 | Karyawan | `Api\Owner\EmployementApiController.php` | `EmploymentService.php` | `Employment.php` | Codebase |
| 10 | Vehicle & Customer | `Api\VehicleController.php`, `Api\CustomerApiController.php` | `VehicleService.php` | `Vehicle.php`, `Customer.php` | Codebase |
| 11 | Voucher | `Api\VoucherApiController.php` | Tidak ada | `Voucher.php` | Codebase |
| 12 | Audit Logging | `Api\Admin\AuditLogController.php` | Tidak ada | `AuditLog.php` | Codebase |
| 13 | Chatbot & Live Chat | `Api\ChatController.php` | `ChatbotService.php` | `ChatMessage.php` | Codebase |
| 14 | Reporting | `Api\Owner\ReportController.php` | Tidak ada | `Report.php` | Codebase |
| 15 | Banner | `Api\BannerController.php` | Tidak ada | Model tidak disebutkan | Codebase |

### Detail Tanggung Jawab Modul

1. **Autentikasi**: Login, register, logout, email verification dengan token berbasis Laravel Sanctum
2. **Transaksi Servis**: Manajemen order servis walk-in dengan status progression (pending→process→success), penugasan mekanik, tracking service completion
3. **Dashboard Analytics**: Agregasi data revenue, service statistics, employee performance untuk dashboard owner/admin
4. **Membership & Subscription**: Manajemen trial membership, pembayaran subscription via payment gateway, auto-renewal logic
5. **Webhook Midtrans**: Verifikasi webhook signature, update status transaksi berdasarkan callback Midtrans (settlement, pending, deny)
6. **Invoice & Item**: Generasi invoice dengan itemized billing, perhitungan subtotal, diskon voucher, dan pajak
7. **Layanan Servis**: CRUD layanan servis katalog, kategorisasi service (Engine, Body, Transmission), pricing configuration
8. **Workshop**: CRUD data bengkel (profile, location, operational hours), upload dokumen KTP/NPWP
9. **Karyawan**: Manajemen karyawan dengan specialization tags, penugasan ke transaksi, tracking performance
10. **Vehicle & Customer**: Registrasi kendaraan customer, tracking service history per vehicle, manajemen customer database
11. **Voucher**: Pembuatan voucher diskon (percentage/fixed), validasi expiry dan usage limit, tracking redemption
12. **Audit Logging**: Read-only access ke activity log untuk admin, mencatat user actions, IP address, changes (before/after)
13. **Chatbot & Live Chat**: Handling chat owner dengan AI chatbot (ML service integration), live chat owner-admin, message persistence
14. **Reporting**: Submission laporan bug/keluhan/saran dari owner, notifikasi real-time ke admin via websocket
15. **Banner**: CRUD banner promosi untuk platform (superadmin), display di mobile app owner

> **Catatan**: Beberapa controller tidak memiliki Service layer terpisah dan langsung menggunakan Eloquent Model untuk logika sederhana (CRUD standar). Service layer diterapkan untuk modul dengan business logic kompleks seperti analytics aggregation, payment processing, dan membership auto-charge.

---

## III.2.3.2 Desain Basis Data (ERD) dan Relasi Kunci

Database dirancang menggunakan MySQL 8.0+ dengan skema relasional yang menghubungkan entitas utama: **users** (autentikasi dan role), **workshops** (data bengkel), **transactions** (order servis), **services** (katalog layanan), **invoices** (billing), dan **audit_logs** (tracking aktivitas). Setiap tabel menggunakan UUID sebagai primary key untuk meningkatkan keamanan dan mendukung distributed system di masa depan.

**Bukti**: ERD gambar yang dilampirkan, migration files di `backend/database/migrations`, dan relasi Eloquent di Model classes (Codebase).

### Entitas Utama Teridentifikasi dari ERD

- **users**: Data user dengan role (superadmin, owner, mechanic) menggunakan Spatie Permission
- **workshops**: Data bengkel milik owner dengan geolocation dan jam operasional
- **transactions**: Order servis dengan status tracking dan link ke customer, workshop, mechanic
- **services**: Katalog layanan servis dengan pricing dan kategorisasi
- **customers & vehicles**: Data pelanggan dan kendaraan mereka
- **invoices & invoice_items**: Billing dengan itemized services
- **employments**: Data karyawan dengan specialization
- **vouchers**: Promo diskon dengan usage limit dan expiry
- **audit_logs**: Activity logging untuk compliance
- **memberships & customer_memberships**: Membership tier customer
- **owner_subscriptions & subscription_plans**: Subscription owner untuk platform
- **chat_messages**: Pesan chat owner-admin atau chatbot
- **reports**: Laporan bug/saran dari owner

### Tabel B: Relasi Kunci ERD

| No | Relasi | Tabel A (PK) | Tabel B (FK) | Kolom FK | Kardinalitas | Bukti |
|----|--------|-------------|-------------|----------|--------------|-------|
| 1 | Owner → Workshops | `users` (id) | `workshops` | `user_uuid` | 1:N | Migration `create_workshops_table.php` line 16 |
| 2 | Workshop → Transactions | `workshops` (id) | `transactions` | `workshop_uuid` | 1:N | Migration `create_transactions_table.php` line 17 |
| 3 | Customer → Vehicles | `customers` (id) | `vehicles` | `customer_uuid` | 1:N | ERD, Migration `create_vehicles_table.php` |
| 4 | Transaction → Invoice | `invoices` (id) | `transactions` | `invoice_uuid` | 1:1 | Model `Transaction.php` method `invoice()` |
| 5 | Transaction → Mechanic | `employments` (id) | `transactions` | `mechanic_uuid` | N:1 | Migration `create_transactions_table.php` line 19 |

### Detail Dampak Relasi ke Proses Bisnis

1. **Owner → Workshops (1:N)**: Satu owner dapat memiliki multiple bengkel (sesuai tier membership: Silver max 2, Gold max 5, Platinum unlimited). Relasi ini digunakan untuk filtering data workshop berdasarkan authenticated user.

2. **Workshop → Transactions (1:N)**: Setiap order servis terikat ke satu bengkel. Relasi ini penting untuk analytics per workshop (revenue, service count) dan multi-tenancy data isolation.

3. **Customer → Vehicles (1:N)**: Satu customer dapat memiliki multiple kendaraan. Relasi ini mendukung tracking service history per kendaraan dan customer retention analysis.

4. **Transaction → Invoice (1:1)**: Setiap transaksi servis yang completed akan generate satu invoice. Relasi ini memisahkan order management dari billing, memungkinkan invoice di-regenerate tanpa mengubah transaction record.

5. **Transaction → Mechanic (N:1)**: Setiap transaksi ditugaskan ke satu mekanik. Relasi ini mendukung workload balancing, performance tracking mekanik (jumlah servis completed, avg time), dan specialization matching.

> **Data yang perlu dilengkapi**:
> - Detail relasi **invoice_items → services** tidak dapat dibaca dengan jelas pada ERD. Kemungkinan: `invoice_items.service_uuid` → `services.id`
> - Relasi **vouchers → transactions** untuk tracking penggunaan voucher tidak terlihat eksplisit di ERD

---

## III.2.3.3 Kontrak API untuk Mendukung Integrasi

API dirancang mengikuti konvensi **RESTful** dengan autentikasi berbasis **Bearer Token** (Laravel Sanctum). Setiap response menggunakan envelope structure dengan `data`, `message`, dan `errors` (untuk validasi error). Format response konsisten untuk memudahkan parsing di mobile app.

**Bukti**: README.md section "API Documentation" lines 1040-1220, `routes/api.php` (Codebase).

### Konvensi Kontrak API

- **Autentikasi**: Header `Authorization: Bearer {token}` untuk protected endpoints
- **Success Response**: Struktur `{ "data": {...}, "message": "..." }` dengan HTTP status 200/201
- **Error Response**: Struktur `{ "message": "...", "errors": {...} }` dengan HTTP status 4xx/5xx
- **Identifier**: Menggunakan UUID pada path parameter (contoh: `/api/transactions/{uuid}`)

---

### Contoh 1: POST /api/auth/login

**Ringkasan**: Autentikasi user dengan email dan password, mengembalikan token untuk akses API.

**Aktor**: Owner/Admin/Mechanic yang akan login ke mobile app atau web dashboard.

**Request:**
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "SecurePass123!",
  "remember": true
}
```

**Success Response (200 OK):**
```json
{
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com",
      "roles": ["owner"]
    },
    "token": "1|abc123..."
  },
  "message": "Login successful"
}
```

**Error Response (422 Unprocessable Entity):**
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email field is required."],
    "password": ["The password field is required."]
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "message": "Invalid credentials",
  "errors": {}
}
```

**Bukti**: README.md lines 1070-1092

---

### Contoh 2: POST /api/transactions

**Ringkasan**: Membuat order servis walk-in baru dengan data customer, vehicle, dan layanan yang dipilih.

**Aktor**: Owner/Manager bengkel yang input order dari mobile app.

**Request:**
```http
POST /api/transactions
Authorization: Bearer {token}
Content-Type: application/json

{
  "customer_uuid": "uuid-customer-123",
  "workshop_uuid": "uuid-workshop-456",
  "mechanic_uuid": "uuid-mechanic-789",
  "services": [
    {"service_uuid": "uuid-service-1", "quantity": 1},
    {"service_uuid": "uuid-service-2", "quantity": 2}
  ],
  "notes": "Ganti oli dan tune-up"
}
```

**Success Response (201 Created):**
```json
{
  "data": {
    "id": "uuid-transaction-abc",
    "customer_uuid": "uuid-customer-123",
    "workshop_uuid": "uuid-workshop-456",
    "mechanic_uuid": "uuid-mechanic-789",
    "status": "pending",
    "amount": 350000,
    "created_at": "2026-01-03T10:30:00Z"
  },
  "message": "Transaction created successfully"
}
```

**Error Response (422 Unprocessable Entity):**
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "customer_uuid": ["The customer uuid field is required."],
    "services": ["At least one service must be selected."]
  }
}
```

**Error Response (403 Forbidden):**
```json
{
  "message": "You do not have permission to create transactions for this workshop.",
  "errors": {}
}
```

**Bukti**: README.md lines 1145-1150 (endpoint path), struktur error dari lines 1214-1220

> **Catatan**: Contoh request body untuk `POST /api/transactions` adalah inferensi logis berdasarkan fillable fields di Model `Transaction.php` dan relasi `items()`. Detail exact payload perlu dikonfirmasi dari Postman collection atau API testing.

---

## Bagian VALIDASI: Matriks Validasi Klaim

| No | Klaim | Sumber Bukti | Status |
|----|-------|--------------|--------|
| 1 | Backend mengikuti pola Controller → Service → Model | Struktur folder `app/Http/Controllers/Api`, `app/Services`, `app/Models` | ✅ OK |
| 2 | Relasi `workshops.user_uuid` → `users.id` (1:N) | Migration `create_workshops_table.php` line 16, Model `Workshop.php` | ✅ OK |
| 3 | Transaction status: pending, process, success | Migration `create_transactions_table.php` line 20, enum definition | ✅ OK |
| 4 | API menggunakan Bearer Token authentication | README.md lines 1034-1038, AuthController.php | ✅ OK |
| 5 | Error response: `{ "message": "...", "errors": {...} }` | README.md lines 1214-1220 | ✅ OK |
| 6 | Invoice dan Transaction relasi 1:1 via `invoice_uuid` | Model `Transaction.php` method `invoice()` | ✅ OK |
| 7 | MidtransService webhook signature verification | `MidtransWebhookController.php`, `MidtransService.php` | ⚠️ Perlu verifikasi |
| 8 | Request body `POST /api/transactions` field `services` | Inferensi dari Model relasi `items()` | ⚠️ Perlu konfirmasi |

---

## Data yang Perlu Dilengkapi

Untuk meningkatkan presisi dokumentasi dan menghindari inferensi yang tidak terbukti, berikut data tambahan yang diperlukan:

1. **Screen capture ERD bagian relasi `invoice_items`** yang menampilkan kolom FK ke `services` dan `invoices`. Saat ini relasi hanya terlihat samar di ERD gambar yang diupload.

2. **Contoh request/response JSON lengkap untuk endpoint `POST /api/transactions`** dan `PUT /api/transactions/{uuid}` dari Postman collection atau API testing, untuk memastikan field exact seperti `services` array dan `notes`.

3. **Standar error response** untuk kasus 403 Forbidden, 404 Not Found, dan 500 Internal Server Error. Saat ini hanya ada contoh 422 Validation Error di README.

4. **Detail skema tabel `vouchers`** khususnya kolom yang menyimpan tracking usage (`current_usage`, `max_usage`) dan relasi ke `transactions`. ERD tidak menampilkan detail kolom vouchers dengan jelas.

5. **Daftar endpoint lengkap API** untuk modul Admin (saat ini hanya disebutkan controller-nya seperti `AuditLogController`, `ReportController` tanpa path eksplisit di README).

---

## Sumber Data

- **ERD**: Database Relation.png (uploaded image)
- **Struktur Backend**: Eksplorasi folder `backend/app/Http/Controllers`, `backend/app/Services`, `backend/app/Models` (Codebase)
- **Migrations**: Files di `backend/database/migrations` untuk verifikasi relasi FK (Codebase)
- **Contoh API**: README.md section "API Documentation" lines 1040-1220
- **Model Relationships**: Eloquent Model classes, khususnya `Transaction.php` dan `Workshop.php` (Codebase)

**Total kata (tidak termasuk tabel dan kode)**: ~950 kata
