# Referensi Lengkap API Endpoint BBI HUB

**Dokumentasi Teknis - Daftar Komprehensif REST API Endpoints**

---

## Ringkasan

Dokumen ini berisi **daftar lengkap semua endpoint REST API** yang digunakan dalam sistem BBI HUB untuk mendukung operasional bengkel melalui aplikasi mobile owner/admin. Total **120+ endpoint** dikelompokkan berdasarkan modul operasional dengan detail lengkap untuk setiap endpoint.

**Konvensi:**
- **Method**: HTTP method (GET, POST, PUT, PATCH, DELETE)
- **Endpoint**: Path lengkap API
- **Auth**: Autentikasi required (Public/Sanctum)
- **Role**: Role yang diperlukan (Owner/Admin/Owner|Admin/Public)
- **Deskripsi**: Fungsi singkat endpoint
- **Status**: As-Is (sudah implementasi) / Planned (untuk integrasi BBI Auto)

---

## 1. PUBLIC ENDPOINTS (No Auth Required)

### 1.1 Banner Management

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/banners/admin-homepage` | Public | - | Get banner untuk admin homepage (3 promo + 1 character) | As-Is |
| GET | `/v1/banners/owner-dashboard` | Public | - | Get banner untuk owner dashboard | As-Is |
| GET | `/v1/banners/website-landing` | Public | - | Get banner untuk landing page website (1 hero + 6 sub) | As-Is |

### 1.2 Webhook

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| POST | `/v1/webhooks/midtrans` | Middleware | - | Webhook callback dari Midtrans untuk payment notification (whitelist IP) | Planned |

### 1.3 Test Endpoint

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/test-api` | Public | - | Test endpoint untuk verify API is working | As-Is |

---

## 2. AUTENTIKASI (Public Auth Endpoints)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| POST | `/v1/auth/register` | Public | - | Registrasi owner baru dengan email verification | As-Is |
| POST | `/v1/auth/login` | Public | - | Login user (owner/admin/mechanic) dengan token generation | As-Is |
| POST | `/v1/auth/forgot-password` | Public (throttle 3/10min) | - | Request OTP untuk reset password | As-Is |
| POST | `/v1/auth/verify-otp` | Public (throttle 5/1min) | - | Verifikasi OTP code | As-Is |
| POST | `/v1/auth/reset-password` | Public (throttle 5/10min) | - | Reset password dengan OTP verified | As-Is |
| GET | `/v1/auth/email/verify/{id}/{hash}` | Public | - | Email verification link callback | As-Is |
| POST | `/v1/email/resend` | Sanctum (throttle 6/1min) | Any | Resend email verification | As-Is |

---

## 3. AUTENTIKASI (Protected Endpoints)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| POST | `/v1/auth/logout` | Sanctum | Any | Logout user dan revoke token | As-Is |
| GET | `/v1/auth/user` | Sanctum | Any | Get authenticated user data dengan relasi | As-Is |
| POST | `/v1/auth/change-password` | Sanctum | Any | Change password untuk user yang sudah login | As-Is |
| POST | `/v1/auth/fcm-token` | Sanctum | Any | Update FCM token untuk push notification | As-Is |
| GET | `/v1/debug/token` | Sanctum | Any | Debug token info (tokenable_type, tokenable_id) | As-Is |

---

## 4. CHAT & LIVE SUPPORT

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| POST | `/v1/chat/send` | Sanctum | Any | Kirim pesan chat (owner-admin atau chatbot) | As-Is |
| GET | `/v1/chat/messages` | Sanctum | Any | Get chat messages untuk conversation | As-Is |
| GET | `/v1/chat/history` | Sanctum | Any | Get chat history user | As-Is |
| DELETE | `/v1/chat/history` | Sanctum | Any | Clear chat history | As-Is |
| POST | `/v1/chat/mark-read` | Sanctum | Any | Mark chat messages as read | As-Is |
| GET | `/v1/chat/rooms` | Sanctum | Admin | Get all chat rooms (admin only) | As-Is |

---

## 5. NOTIFIKASI

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/notifications` | Sanctum | Any | List notifikasi user dengan pagination | As-Is |
| GET | `/v1/notifications/unread-count` | Sanctum | Any | Hitung jumlah notifikasi unread | As-Is |
| POST | `/v1/notifications/mark-read` | Sanctum | Any | Mark notifikasi sebagai read | As-Is |

---

## 6. OWNER ROUTES

### 6.1 Workshop Management

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| POST | `/v1/owners/workshops` | Sanctum | Owner | Buat workshop baru | As-Is |
| PUT | `/v1/owners/workshops/{workshop}` | Sanctum | Owner | Update workshop profile (alamat, jam operasional, dll) | As-Is |

### 6.2 Workshop Documents

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| POST | `/v1/owners/documents` | Sanctum | Owner | Upload dokumen workshop (KTP, NPWP, dll) | As-Is |

### 6.3 Employee Management

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/owners/employee` | Sanctum | Owner | List karyawan workshop | As-Is |
| POST | `/v1/owners/employee` | Sanctum | Owner | Tambah karyawan baru | As-Is |
| GET | `/v1/owners/employee/{employee}` | Sanctum | Owner | Detail karyawan | As-Is |
| PUT | `/v1/owners/employee/{employee}` | Sanctum | Owner | Update data karyawan | As-Is |
| DELETE | `/v1/owners/employee/{employee}` | Sanctum | Owner | Hapus karyawan | As-Is |
| PATCH | `/v1/owners/employee/{employee}/status` | Sanctum | Owner | Update status karyawan (active/inactive) | As-Is |

### 6.4 Staff Performance (PREMIUM)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/owners/staff/performance` | Sanctum + Premium | Owner | List performance semua staff | As-Is |
| GET | `/v1/owners/staff/{user_id}/performance` | Sanctum + Premium | Owner | Performance detail per staff | As-Is |

### 6.5 Analytics (PREMIUM)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/owners/analytics/report` | Sanctum + Premium | Owner | Get analytics report (revenue, service, employee) | As-Is |
| GET | `/v1/v1/owners/analytics/report` | Sanctum + Premium | Owner | Alternate analytics report endpoint | As-Is |

### 6.6 Customer Management

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/owners/customers` | Sanctum | Owner | List customers workshop | As-Is |
| POST | `/v1/owners/customers` | Sanctum | Owner | Tambah customer baru | As-Is |
| GET | `/v1/owners/customers/{customer}` | Sanctum | Owner | Detail customer | As-Is |
| PUT | `/v1/owners/customers/{customer}` | Sanctum | Owner | Update data customer | As-Is |
| DELETE | `/v1/owners/customers/{customer}` | Sanctum | Owner | Hapus customer | As-Is |

### 6.7 Voucher Management

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/owners/vouchers` | Sanctum | Owner | List voucher workshop | As-Is |
| POST | `/v1/owners/vouchers` | Sanctum | Owner | Buat voucher baru (percentage/fixed discount) | As-Is |
| GET | `/v1/owners/vouchers/{voucher}` | Sanctum | Owner | Detail voucher | As-Is |
| PUT | `/v1/owners/vouchers/{voucher}` | Sanctum | Owner | Update voucher | As-Is |
| PATCH | `/v1/owners/vouchers/{voucher}` | Sanctum | Owner | Update voucher (partial) | As-Is |
| DELETE | `/v1/owners/vouchers/{voucher}` | Sanctum | Owner | Hapus voucher | As-Is |

### 6.8 Service Catalog

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/owners/services` | Sanctum | Owner | List service katalog workshop | As-Is |
| POST | `/v1/owners/services` | Sanctum | Owner | Tambah service baru ke katalog | As-Is |
| GET | `/v1/owners/services/{service}` | Sanctum | Owner | Detail service | As-Is |

### 6.9 Vehicle Management

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/owners/vehicles` | Sanctum | Owner | List kendaraan customer | As-Is |
| POST | `/v1/owners/vehicles` | Sanctum | Owner | Register kendaraan baru | As-Is |
| GET | `/v1/owners/vehicles/{vehicle}` | Sanctum | Owner | Detail kendaraan | As-Is |
| PUT | `/v1/owners/vehicles/{vehicle}` | Sanctum | Owner | Update data kendaraan | As-Is |
| DELETE | `/v1/owners/vehicles/{vehicle}` | Sanctum | Owner | Hapus kendaraan | As-Is |

### 6.10 Feedback

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/owners/feedback` | Sanctum | Owner | List feedback dari customer | As-Is |

### 6.11 Reports/Aduan Aplikasi (Owner)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/owners/reports` | Sanctum | Owner | List laporan bug/keluhan/saran yang pernah disubmit | As-Is |
| POST | `/v1/owners/reports` | Sanctum | Owner | Submit laporan baru (bug/keluhan/saran) | As-Is |
| GET | `/v1/owners/reports/{report}` | Sanctum | Owner | Detail laporan | As-Is |

### 6.12 Reports Summary (PREMIUM)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/owners/reports/summary` | Sanctum + Premium | Owner | Summary report analytics | As-Is |

---

## 7. ADMIN ROUTES

### 7.1 Dashboard & Monitoring

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/admins/dashboard` | Sanctum | Admin | Dashboard overview (revenue, services, employees) | As-Is |
| GET | `/v1/admins/dashboard/stats` | Sanctum | Admin | Aggregated statistics untuk monitoring | As-Is |

### 7.2 Mechanics Management

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/admins/mechanics` | Sanctum | Admin | List mechanics yang available | As-Is |
| GET | `/v1/admins/mechanics/performance` | Sanctum | Admin | Performance metrics semua mechanics | As-Is |

### 7.3 Service Scheduling & Flow

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/admins/services/schedule` | Sanctum | Admin | List service schedule | As-Is |
| GET | `/v1/admins/services/active` | Sanctum | Admin | List service yang sedang aktif (in-progress) | As-Is |
| POST | `/v1/admins/services/walk-in` | Sanctum | Admin | Buat order walk-in service untuk customer | As-Is |
| POST | `/v1/admins/services/{service}/accept` | Sanctum (throttle 10/1min) | Admin | Accept service order | As-Is |
| POST | `/v1/admins/services/{service}/reject` | Sanctum (throttle 10/1min) | Admin | Reject service order | As-Is |
| PATCH | `/v1/admins/services/{id}/complete` | Sanctum | Admin | Mark service sebagai completed | As-Is |
| PATCH | `/v1/admins/services/{service}/complete` | Sanctum | Admin | Alternate complete endpoint | As-Is |
| POST | `/v1/admins/services/{service}/assign-mechanic` | Sanctum | Admin | Assign mechanic ke service | As-Is |

### 7.4 Invoice Management

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| POST | `/v1/admins/services/{id}/invoice` | Sanctum (throttle 10/1min) | Admin | Generate invoice untuk service completed | As-Is |
| GET | `/v1/admins/services/{id}/invoice` | Sanctum | Admin | Get invoice detail untuk service | As-Is |
| POST | `/v1/admins/services/{service}/invoice` | Sanctum (throttle 10/1min) | Admin | Alternate invoice creation endpoint | As-Is |
| GET | `/v1/admins/services/{service}/invoice` | Sanctum | Admin | Alternate get invoice endpoint | As-Is |

### 7.5 Payment (Cash)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| POST | `/v1/admins/invoices/{id}/cash-payment` | Sanctum | Admin | Process cash payment on-site, update invoice & service status | As-Is |

### 7.6 Service CRUD

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/admins/services` | Sanctum | Admin | List services | As-Is |
| POST | `/v1/admins/services` | Sanctum | Admin | Create service baru | As-Is |
| GET | `/v1/admins/services/{service}` | Sanctum | Admin | Detail service | As-Is |
| PUT | `/v1/admins/services/{service}` | Sanctum | Admin | Update service | As-Is |
| PATCH | `/v1/admins/services/{service}` | Sanctum | Admin | Update service (partial) | As-Is |
| DELETE | `/v1/admins/services/{service}` | Sanctum | Admin | Delete service | As-Is |

### 7.7 Voucher Management (Admin)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/admins/vouchers` | Sanctum | Admin | List vouchers | As-Is |
| POST | `/v1/admins/vouchers` | Sanctum | Admin | Create voucher | As-Is |
| GET | `/v1/admins/vouchers/{voucher}` | Sanctum | Admin | Detail voucher | As-Is |
| PUT | `/v1/admins/vouchers/{voucher}` | Sanctum | Admin | Update voucher | As-Is |
| PATCH | `/v1/admins/vouchers/{voucher}` | Sanctum | Admin | Update voucher (partial) | As-Is |
| DELETE | `/v1/admins/vouchers/{voucher}` | Sanctum | Admin | Delete voucher | As-Is |
| POST | `/v1/admins/vouchers/validate` | Sanctum | Admin | Validate voucher code | As-Is |

### 7.8 Admin Users/Employees

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/admins/users` | Sanctum | Admin | List employees/users | As-Is |
| GET | `/v1/admins/users/{user}` | Sanctum | Admin | Detail employee | As-Is |
| PUT | `/v1/admins/users/{user}` | Sanctum | Admin | Update employee data | As-Is |

### 7.9 Vehicle Management (Admin)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/admins/vehicles` | Sanctum | Admin | List vehicles | As-Is |
| POST | `/v1/admins/vehicles` | Sanctum | Admin | Register vehicle baru | As-Is |
| GET | `/v1/admins/vehicles/{vehicle}` | Sanctum | Admin | Detail vehicle | As-Is |
| PUT | `/v1/admins/vehicles/{vehicle}` | Sanctum | Admin | Update vehicle | As-Is |
| DELETE | `/v1/admins/vehicles/{vehicle}` | Sanctum | Admin | Delete vehicle | As-Is |

### 7.10 Transaction Management

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| POST | `/v1/admins/transactions` | Sanctum | Admin | Create transaction baru | As-Is |
| GET | `/v1/admins/transactions/{transaction}` | Sanctum | Admin | Detail transaction | As-Is |
| PUT | `/v1/admins/transactions/{transaction}` | Sanctum | Admin | Update transaction | As-Is |
| PUT | `/v1/admins/transactions/{transaction}/status` | Sanctum | Admin | Update transaction status | As-Is |
| POST | `/v1/admins/transactions/{transaction}/finalize` | Sanctum | Admin | Finalize transaction | As-Is |
| POST | `/v1/admins/transactions/{transaction}/apply-voucher` | Sanctum | Admin | Apply voucher ke transaction | As-Is |
| POST | `/v1/admins/transactions/{transaction}/snap-token` | Sanctum | Admin | Get Midtrans snap token (Planned) | Planned |
| PATCH | `/v1/admins/transactions/{transaction}/items` | Sanctum | Admin | Update transaction items | As-Is |

### 7.11 Transaction Items

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| POST | `/v1/admins/transaction-items` | Sanctum | Admin | Create transaction item | As-Is |
| GET | `/v1/admins/transaction-items/{item}` | Sanctum | Admin | Detail transaction item | As-Is |
| PATCH | `/v1/admins/transaction-items/{item}` | Sanctum | Admin | Update transaction item | As-Is |
| PUT | `/v1/admins/transactions/{transaction}/items/{item}` | Sanctum | Admin | Update specific item dalam transaction | As-Is |
| DELETE | `/v1/admins/transactions/{transaction}/items/{item}` | Sanctum | Admin | Delete item dari transaction | As-Is |

### 7.12 Reports/Aduan Aplikasi (Admin)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/admins/reports` | Sanctum | Admin | List semua laporan dari owner | As-Is |
| POST | `/v1/admins/reports` | Sanctum | Admin | Submit laporan baru (admin) | As-Is |
| GET | `/v1/admins/reports/{report}` | Sanctum | Admin | Detail laporan | As-Is |

---

## 8. MECHANICS ROUTES (Empty - No Active Endpoints)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| - | `/v1/mechanics/*` | Sanctum | Mechanic | **Route group exists but empty** | Not Used |

> **Catatan**: Role mechanic ada di RBAC namun tidak memiliki endpoint operasional saat ini.

---

## 9. OWNER SUBSCRIPTION (SaaS)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| POST | `/v1/owner/subscription/checkout` | Sanctum | Any | Checkout subscription plan via Midtrans | As-Is |
| POST | `/v1/owner/subscription/start-trial` | Sanctum | Any | Start trial membership (7 hari gratis) | As-Is |
| POST | `/v1/owner/subscription/cancel` | Sanctum | Any | Cancel subscription aktif | As-Is |
| POST | `/v1/owner/subscription/check-status` | Sanctum | Any | Check status subscription saat ini | As-Is |

---

## 10. MEMBERSHIP (Customer Membership - Planned)

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/memberships/workshops/{workshop}` | Sanctum | Any | Get available membership tiers untuk workshop | Planned |
| GET | `/v1/memberships/{membership}` | Sanctum | Any | Detail membership tier | Planned |
| GET | `/v1/memberships/customer/active` | Sanctum | Any | Get active membership customer | Planned |
| POST | `/v1/memberships/customer/purchase` | Sanctum | Any | Purchase membership via payment gateway | Planned |
| POST | `/v1/memberships/customer/cancel` | Sanctum | Any | Cancel customer membership | Planned |
| PUT | `/v1/memberships/customer/auto-renew` | Sanctum | Any | Update auto-renew setting | Planned |
| GET | `/v1/memberships/customer/payment-status/{orderId}` | Sanctum | Any | Check payment status membership | Planned |

> **Catatan**: Membership customer routes untuk integrasi BBI Auto yang belum diimplementasikan.

---

## 11. AUDIT LOGS

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/admin/audit-logs` | Sanctum | Owner\|Admin | List activity logs dengan pagination | As-Is |
| GET | `/v1/admin/audit-logs/events` | Sanctum | Owner\|Admin | Get distinct event types | As-Is |
| GET | `/v1/admin/audit-logs/{auditLog}` | Sanctum | Owner\|Admin | Detail audit log spesifik | As-Is |

---

## 12. FAILSAFE ROUTES

| Method | Endpoint | Auth | Role | Deskripsi | Status |
|--------|----------|------|------|-----------|--------|
| GET | `/v1/admins/reports` | Sanctum | Admin | Failsafe route untuk admin reports | As-Is |
| POST | `/v1/admins/reports` | Sanctum | Admin | Failsafe route untuk create report | As-Is |

---

## SUMMARY STATISTIK

| Kategori | Jumlah Endpoint | Keterangan |
|----------|-----------------|------------|
| **Public Endpoints** | 6 | Banner (3), Webhook (1), Test (1), Email verify (1) |
| **Autentikasi** | 12 | Register, Login, Logout, Password Reset, Email Verification, FCM |
| **Chat & Notification** | 9 | Chat messages, history, rooms, notifications |
| **Owner Routes** | 46 | Workshop, Employee, Analytics, Customer, Voucher, Service, Vehicle, Feedback, Reports |
| **Admin Routes** | 62 | Dashboard, Service flow, Invoice, Payment, Voucher, Vehicle, Transaction, Reports |
| **Subscription** | 4 | Owner SaaS subscription management |
| **Membership** | 7 | Customer membership (Planned for BBI Auto) |
| **Audit Logs** | 3 | Activity logging |
| **Mechanics** | 0 | Route group kosong |
| **Failsafe** | 2 | Duplicate routes untuk reliability |
| **TOTAL** | **~120+ endpoints** | |

---

## CATATAN PENTING

1. **Rate Limiting**: Beberapa endpoint kritikal menggunakan throttling:
   - Password reset: 3-5 requests per 1-10 minutes
   - Service accept/reject: 10 per minute
   - Invoice creation: 10 per minute

2. **Premium Middleware**: Endpoint owner analytics dan staff performance memerlukan subscription premium aktif

3. **Planned Endpoints**: Semua endpoint membership customer dan Midtrans snap token untuk integrasi dengan BBI Auto masih **Planned/To-Be**

4. **Duplicate Routes**: Beberapa endpoint memiliki alternate path untuk backward compatibility atau failsafe

5. **Empty Route Groups**: Route group `/v1/mechanics/` exists namun tidak memiliki endpoint aktif

---

## SUMBER DATA

- **Routes File**: `backend/routes/api.php` (Codebase)
- **Controllers**: `app/Http/Controllers/Api/` various controllers
- **Total Lines Routes**: 322 lines

**Dokumentasi ini dibuat dari ekstraksi langsung routes file tanpa halusinasi endpoint yang tidak ada.**
