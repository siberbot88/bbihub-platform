# III.2.1 Gambaran Sistem dan Ruang Lingkup

## Konteks Aplikasi

BBI HUB adalah platform manajemen bengkel otomotif berbasis *enterprise* yang dirancang untuk mendigitalisasi dan merampingkan operasional bengkel di Indonesia. Platform ini berfungsi sebagai ekosistem mitra bengkel yang memungkinkan pemilik dan pengelola bengkel untuk mengelola seluruh aspek operasional mereka secara terpadu melalui aplikasi mobile dan dashboard web administratif.

Tujuan utama BBI HUB adalah mengatasi tantangan yang dihadapi bengkel tradisional, yaitu pencatatan manual yang tidak konsisten, keterbatasan wawasan bisnis real-time, manajemen tugas karyawan yang tidak efisien, serta ketiadaan sistem pembayaran dan keanggotaan yang terintegrasi. Sebagai solusi, BBI HUB menyediakan infrastruktur backend yang robust berbasis REST API untuk sinkronisasi data secara seamless, integrasi pembayaran otomatis melalui gateway Midtrans, serta fitur AI Chatbot untuk otomasi layanan pelanggan.

Platform BBI HUB dirancang untuk terintegrasi dengan **BBI Auto**, yaitu aplikasi terpisah yang berfokus pada pengguna akhir (customer). Kedua platform ini direncanakan untuk saling melengkapi dalam ekosistem layanan servis kendaraan. Konsep integrasinya adalah: pelanggan melakukan booking service secara online melalui aplikasi BBI Auto, kemudian data booking tersebut akan dikirimkan ke BBI HUB untuk diproses oleh bengkel mitra yang terdaftar. Admin bengkel akan menerima notifikasi booking melalui BBI HUB dan dapat menerima atau menolak permintaan layanan. Dengan arsitektur ini, BBI Auto akan berperan sebagai kanal akuisisi pelanggan, sementara BBI HUB mengelola operasional dan workflow servis di sisi bengkel.

Namun, **integrasi teknis antara BBI HUB dan BBI Auto belum diimplementasikan**. Saat ini, kedua platform masih beroperasi secara terpisah dan masing-masing fokus pada pengembangan fitur inti sesuai target. Integrasi direncanakan akan dilakukan pada fase development berikutnya setelah kedua platform matang dan stabil.


## Fitur Inti yang Dikerjakan

Berikut adalah daftar fitur inti yang telah dikembangkan dalam platform BBI HUB:

### 1. Penerimaan Booking
**Aktor**: Admin bengkel, Owner bengkel  
**Input Utama**: Data booking pelanggan (scheduled service), informasi kendaraan, jenis layanan yang diminta  
**Output/Hasil**: Status penerimaan atau penolakan booking, penugasan mekanik  
**Status Implementasi**: **Sudah** - Fitur ini telah diimplementasikan dengan endpoint `/api/v1/admins/services/schedule` yang menampilkan daftar booking terkelompok berdasarkan tanggal, serta endpoint untuk menerima (`/accept`) atau menolak (`/reject`) booking dengan alasan penolakan yang tercatat dalam audit log.

### 2. Workflow Servis
**Aktor**: Admin bengkel, Mekanik, Customer (pelanggan)  
**Input Utama**: Data customer walk-in atau booking yang diterima, kategori servis (Engine, Body, Electrical, Transmission, AC, Tire), mekanik yang ditugaskan  
**Output/Hasil**: Service log yang mencatat setiap tahap proses servis (penerimaan → pengerjaan → penyelesaian → invoice → pembayaran)  
**Status Implementasi**: **Sudah** - Workflow servis lengkap telah diimplementasikan melalui `ServiceSchedulingController` dan `ServiceLoggingController`. Sistem mendukung walk-in service creation, assignment mekanik, service completion tracking, dan invoice generation. Status servis tercatat dalam berbagai state (pending, accepted, in_progress, completed, rejected).

### 3. Monitoring Operasional
**Aktor**: Owner bengkel, Admin bengkel  
**Input Utama**: Filter periode waktu (harian, mingguan, bulanan, tahunan), workshop yang dipilih  
**Output/Hasil**: Dashboard analytics berisi KPI utama (pendapatan, jumlah servis, performa mekanik), grafik tren pendapatan, analisis popularitas layanan, metrik retensi pelanggan  
**Status Implementasi**: **Sudah** - Modul analitik telah diimplementasikan melalui `AnalyticsController` dengan dukungan agregasi data historis (snapshot EIS), grafik tren, dan forecasting. Data tersedia dalam berbagai periode (daily, weekly, monthly, yearly) dengan kemampuan perbandingan multi-workshop.

### 4. Audit dan Monitoring
**Aktor**: Owner bengkel, Admin bengkel, Superadmin  
**Input Utama**: Filter berdasarkan event type, user ID, rentang waktu pencarian  
**Output/Hasil**: Log audit lengkap yang mencatat aktivitas sistem (login, perubahan data, transaksi, approval/rejection), termasuk user email, IP address, dan timestamp  
**Status Implementasi**: **Sudah** - Sistem audit logging telah diimplementasikan menggunakan model `AuditLog` dengan endpoint `/api/v1/admin/audit-logs` yang mendukung filtering, pagination, dan detail view. Setiap aktivitas kritis tercatat secara otomatis dengan metadata lengkap.

### 5. Manajemen Karyawan
**Aktor**: Owner bengkel  
**Input Utama**: Data karyawan (nama, email, spesialisasi, jobdesk), assignment role (admin/mekanik)  
**Output/Hasil**: Database karyawan dengan tracking performa (jumlah servis selesai, rating customer, kontribusi revenue)  
**Status Implementasi**: **Sudah** - Fitur manajemen karyawan telah lengkap dengan CRUD operations melalui `EmployementApiController`. Sistem mendukung assignment spesialisasi (Engine Specialist, Body Specialist, dll.), status management (active/inactive), dan performance tracking terintegrasi dengan modul analytics.

### 6. Manajemen Transaksi dan Pembayaran
**Aktor**: Admin bengkel, Customer  
**Input Utama**: Detail transaksi (item servis, harga, diskon voucher), metode pembayaran (cash/Midtrans)  
**Output/Hasil**: Invoice otomatis, payment status tracking, receipt generation, webhook notification dari Midtrans  
**Status Implementasi**: **Sudah** - Sistem pembayaran terintegrasi penuh dengan Midtrans Payment Gateway. Mendukung multiple payment methods (credit card, e-wallet, bank transfer), real-time webhook handling untuk update status pembayaran otomatis, dan cash payment processing untuk walk-in customers.

### 7. Live Chat dan Chatbot
**Aktor**: Owner bengkel, Admin bengkel, AI Chatbot  
**Input Utama**: Pesan user, riwayat percakapan  
**Output/Hasil**: Respons AI untuk FAQ automation, opsi eskalasi ke admin, chat history persistence  
**Status Implementasi**: **Sudah** - Chatbot terintegrasi dengan AI service (DeepSeek/Groq) melalui `ChatbotService`. Mendukung natural language processing, conversation history management, dan fallback mechanism. Live chat antara user dan admin juga tersedia dengan real-time messaging menggunakan Laravel Reverb.

### 8. Sistem Keanggotaan (Membership)
**Aktor**: Owner bengkel  
**Input Utama**: Pilihan tier membership (Basic Trial, Silver, Gold, Platinum), data pembayaran  
**Output/Hasil**: Aktivasi membership, akses fitur premium sesuai tier, auto-renewal subscription  
**Status Implementasi**: **Sudah** - Sistem SaaS subscription telah diimplementasikan dengan free trial 7 hari, auto-charge setelah trial, dan monthly auto-renewal. Middleware `premium` membatasi akses ke fitur-fitur premium (analytics, staff performance tracking, reporting).

### 9. Manajemen Voucher dan Promosi
**Aktor**: Owner bengkel, Admin bengkel  
**Input Utama**: Konfigurasi voucher (tipe diskon, nilai, tanggal kadaluarsa, limit penggunaan)  
**Output/Hasil**: Voucher yang dapat diterapkan pada transaksi, tracking penggunaan  
**Status Implementasi**: **Sudah** - Sistem voucher mendukung percentage discount dan fixed amount discount, expiry date handling, usage limit, dan validation otomatis saat apply ke transaksi.

### 10. Laporan Aplikasi (Reporting)
**Aktor**: Owner bengkel, Admin bengkel  
**Input Utama**: Jenis laporan (Bug, Keluhan, Saran, Ulasan), deskripsi detail, foto pendukung  
**Output/Hasil**: Laporan tersimpan dengan status tracking (baru, diproses, selesai), notifikasi real-time ke admin platform  
**Status Implementasi**: **Sudah** - Modul reporting telah lengkap dengan endpoint terpisah untuk owner dan admin, mendukung photo upload, status management, dan real-time notifications.

### Fitur Panel Superadmin (Web Dashboard)
Selain 10 fitur utama di atas yang tersedia untuk owner dan admin bengkel, terdapat juga **panel Superadmin** yang diakses melalui web dashboard untuk mengelola platform secara keseluruhan. Fitur-fitur panel superadmin meliputi:

- **Dashboard**: Monitoring KPI platform secara agregat, grafik tren bisnis platform
- **Manajemen Pengguna**: CRUD users (owner, admin, mekanik), verifikasi akun
- **Analitik Bisnis**: Platform Business Outlook (PBO) dengan MRR forecast, churn prediction, upsell scoring menggunakan ML service
- **Verifikasi Bengkel**: Approval/rejection bengkel baru yang mendaftar, validasi dokumen
- **Manajemen Bengkel**: Monitoring seluruh bengkel mitra, status membership, performance metrics
- **Manajemen Promosi**: Global banner management untuk berbagai placement (admin homepage, owner dashboard, website landing)
- **Data Center**: Executive Information System (EIS) dengan metrics aggregation dan historical data
- **Laporan**: Monitoring laporan dari owner/admin bengkel
- **Pengaturan**: Konfigurasi sistem global, membership plans, payment gateway settings

**Aktor**: Superadmin  
**Status Implementasi**: **Sudah** - Panel superadmin telah terimplementasi dengan Livewire components dan full CRUD operations.

## Gambaran Arsitektur Tingkat Tinggi

Platform BBI HUB mengadopsi arsitektur three-tier modern yang memisahkan Client Layer, Application Layer, dan Data Layer. Pada Client Layer, terdapat dua komponen utama: **Web Dashboard** yang dibangun menggunakan Laravel Livewire Volt dengan Tailwind CSS untuk antarmuka administratif berbasis browser, dan **Mobile Application** yang dikembangkan dengan Flutter untuk akses on-the-go oleh owner dan admin bengkel.

Kedua client berinteraksi dengan Application Layer melalui HTTPS REST API. Application Layer dibangun menggunakan framework Laravel 12 dengan PHP 8.2+, menerapkan pola arsitektur MVC (Model-View-Controller) untuk web dashboard dan Service Layer Pattern untuk business logic yang kompleks. Middleware Laravel Sanctum menangani autentikasi berbasis token untuk mobile API, sementara Spatie Laravel Permission mengimplementasikan Role-Based Access Control (RBAC) dengan hierarki role: Superadmin > Owner > Admin > Mekanik.

Alur data dimulai dari client yang mengirimkan request ke API endpoint, melewati middleware autentikasi dan otorisasi, kemudian diproses oleh Controller yang memanggil Service Layer untuk business logic. Service berinteraksi dengan Model (Eloquent ORM) untuk operasi database, dan respons dikembalikan ke client dalam format JSON (untuk mobile) atau rendered view (untuk web dashboard). Untuk operasi asynchronous seperti email notification dan FCM push notification, sistem menggunakan Laravel Queue dengan background worker.

Data Layer terdiri dari MySQL 8.0+ sebagai primary database untuk menyimpan data transaksional dan relasional (services, transactions, users, workshops, dsb), File Storage untuk menyimpan foto kendaraan, dokumen bengkel, dan invoice PDF, serta Redis (optional) untuk caching dan session management guna meningkatkan performa.

Untuk integrasi masa depan dengan BBI Auto, boundary sistem akan terletak pada API Gateway. BBI Auto akan dapat mengakses data bengkel mitra (workshop profiles, available services, operating hours) melalui shared API yang di-expose dari BBI HUB. Booking yang dibuat oleh pelanggan melalui platform BBI Auto akan dikirimkan ke BBI HUB melalui webhook atau API call, kemudian masuk ke workflow penerimaan booking di BBI HUB untuk diproses oleh admin bengkel. Status booking dan service progress akan di-sync kembali ke BBI Auto untuk memberikan update real-time kepada pelanggan. Namun, mekanisme integrasi ini masih dalam tahap perencanaan dan belum terimplementasi pada codebase saat ini.

Platform juga terintegrasi dengan layanan eksternal: **Midtrans Payment Gateway** untuk pembayaran subscription dan transaksi servis, **Laravel Reverb** untuk real-time event broadcasting dan live chat, **ML Service** (Python-based microservice menggunakan Flask) untuk analytics forecasting dan Platform Business Outlook, serta **Firebase Cloud Messaging (FCM)** untuk push notifications ke mobile devices. Monitoring dan error tracking ditangani oleh Sentry.

**ML Service** dibangun dengan Python Flask dan menggunakan library **pandas** untuk data manipulation, **numpy** untuk komputasi numerik, dan **scikit-learn** untuk machine learning algorithms. Service ini menyediakan tiga model prediktif utama: (1) **MRR Forecast** yang memprediksi Monthly Recurring Revenue menggunakan Linear Regression, (2) **Churn Prediction** yang mengidentifikasi bengkel berisiko churn berdasarkan penurunan volume transaksi, dan (3) **Upsell Scoring** yang merekomendasikan bengkel free-tier untuk upgrade membership. ML service mengakses database MySQL secara real-time untuk mendapatkan data terkini tanpa bergantung pada CSV export.

**Firebase Cloud Messaging (FCM)** diimplementasikan untuk push notification system. Backend menggunakan FCM HTTP v1 API dengan OAuth 2.0 authentication, service account credentials, dan custom channel implementation (`FcmChannel`). Mobile app menangani foreground/background notifications, deep linking, dan token management dengan auto-update ke backend setiap kali token berubah.

Teknologi yang digunakan telah dikonfirmasi dari codebase aktual: backend menggunakan **Laravel 12.x** dengan **PHP 8.2+**, database **MySQL 8.0+**, mobile app menggunakan **Flutter 3.0+** dengan **Dart 3.0+**, state management menggunakan **Provider** pattern, web dashboard menggunakan **Livewire Volt 3.x** dengan **Tailwind CSS 3.x** untuk styling, dan ML service menggunakan **Python 3.9+** dengan **Flask**, **pandas**, **numpy**, **scikit-learn**.

---

## Lampiran

### A) Diagram Arsitektur Sistem BBI HUB

![Diagram Arsitektur BBI HUB](C:\Users\fadil\.gemini\antigravity\brain\6e21cf9a-101f-4633-a003-3d709a7c5ac0\arsitektur_bbi_hub.png)

**Penjelasan Arsitektur:**

**1. Client Layer (Lapisan Klien)**
- **Web Dashboard**: Antarmuka berbasis browser menggunakan Laravel Livewire dan Tailwind CSS untuk superadmin dan pengelolaan bengkel
- **Mobile Application**: Aplikasi Flutter dengan state management Provider untuk owner dan admin bengkel

**2. API Gateway**
- **HTTPS REST API**: Endpoint terpusat dengan autentikasi Laravel Sanctum untuk semua komunikasi client-server
- Menangani routing, validasi, dan security middleware

**3. Application Layer (Laravel 12 - PHP 8.2+)**
- **Middleware**: Authentication (Sanctum), Authorization (RBAC/Spatie Permission), Rate Limiting
- **Controllers**: API Controllers, Admin Controllers, Owner Controllers
- **Service Layer**: Business logic untuk Transaction, Payment, Chatbot, FCM
- **Models**: Eloquent ORM untuk akses database (User, Workshop, Service, Transaction, Invoice, AuditLog, Report)
- **Queue Workers**: Background jobs untuk notifikasi, email, dan task asynchronous

**4. Data Layer (Lapisan Data)**
- **MySQL 8.0+**: Primary database untuk data transaksional, relasional, dan caching (menggunakan cache table)
- **File Storage**: Penyimpanan foto, dokumen, dan invoice PDF

**5. External Services (Layanan Eksternal)**
- **Midtrans**: Payment gateway untuk processing pembayaran
- **Laravel Reverb**: Real-time broadcasting untuk live chat dan notifications
- **ML Service (Flask)**: Microservice Python untuk MRR forecast, churn prediction, upsell scoring
- **FCM**: Firebase Cloud Messaging untuk push notifications
- **Sentry**: Error tracking dan monitoring

**6. Future Integration (Integrasi Masa Depan)**
- **BBI Auto**: Platform customer-facing (belum terintegrasi, dalam perencanaan)

**Alur Data Utama:**

1. **Request Flow**: Client → HTTPS API → Middleware (Auth/RBAC) → Controller → Service Layer → Model → Database
2. **Response Flow**: Database → Model → Service → Controller → JSON/View Response → Client
3. **Async Operations**: Service Layer → Queue Jobs → Background Workers → External Services (FCM, Email)
4. **Payment Flow**: Service → Midtrans Gateway → Webhook → Payment Service → Database Update
5. **Real-time**: Events → Laravel Reverb → WebSocket → Client Updates
6. **Analytics**: ML Service ← Direct MySQL Access → Predictions/Forecasts → Admin Dashboard


---

### B) Tabel Ringkas Modul/Fitur BBI HUB

| No | Modul/Fitur | Deskripsi Singkat | Aktor | Data Masuk | Data Keluar | Status | Catatan |
|:--:|:-----------|:-----------------|:------|:-----------|:-----------|:------:|:--------|
| **1** | **Penerimaan Booking** | Workflow untuk menerima/menolak booking pelanggan dengan assignment mekanik | Admin, Owner | Booking data, workshop_uuid, scheduled_date | Accept/reject status, assigned mechanic | ✅ Sudah | Endpoint: `/admins/services/schedule` |
| **2** | **Workflow Servis** | Manajemen siklus hidup servis lengkap dari walk-in hingga completion | Admin, Mekanik, Customer | Service type, customer, vehicle, mechanic | Service status, logs, invoice | ✅ Sudah | Support multiple states: pending → in_progress → completed |
| **3** | **Monitoring Operasional** | Dashboard analytics dengan KPI, revenue trends, mechanic performance | Owner, Admin | Period filter, workshop_uuid | Charts, metrics, forecasts | ✅ Sudah | Real-time data aggregation dengan EIS snapshot |
| **4** | **Audit & Monitoring** | Sistem logging aktivitas dengan tracking IP, user, event type | Owner, Admin, Superadmin | Filter: event, user_id, date_range | Audit log list, detail view | ✅ Sudah | Automatic logging untuk critical events |
| **5** | **Manajemen Karyawan** | CRUD karyawan dengan spesialisasi, performance tracking | Owner | Employee data, specialization, role | Employee list, performance metrics | ✅ Sudah | Terintegrasi dengan service assignment |
| **6** | **Transaksi & Pembayaran** | Pemrosesan pembayaran via Midtrans dan cash, invoice generation | Admin, Customer | Transaction items, payment method | Invoice, payment status, receipt | ✅ Sudah | Support multiple payment methods + webhook |
| **7** | **Live Chat & Chatbot** | AI-powered chat dengan escalation ke admin | Owner, Admin, AI Bot | User message, conversation history | AI/admin response, chat history | ✅ Sudah | Integration: DeepSeek/Groq API |
| **8** | **Sistem Membership** | SaaS subscription dengan free trial dan auto-renewal | Owner | Membership tier, payment | Subscription status, access control | ✅ Sudah | Premium middleware untuk access control |
| **9** | **Voucher & Promosi** | Manajemen voucher dengan validation dan usage tracking | Owner, Admin | Voucher config, discount type | Applied discount, usage analytics | ✅ Sudah | Support percentage & fixed discount |
| **10** | **Laporan Aplikasi** | Sistem reporting Bug/Keluhan/Saran dengan photo upload | Owner, Admin | Report type, description, photo | Report status, real-time notification | ✅ Sudah | Separate endpoints untuk owner & admin |
| **11** | **Panel Superadmin** | Dashboard platform untuk monitoring global, verifikasi bengkel, EIS | Superadmin | N/A (dashboard queries) | Platform KPIs, MRR forecast, user management | ✅ Sudah | Web-only, Livewire components |
| **12** | **ML Analytics Service** | Microservice untuk forecasting dan predictive analytics | System (Backend) | Historical data via MySQL | MRR forecast, churn list, upsell score | ✅ Sudah | Python Flask + pandas + scikit-learn |
| **13** | **Push Notifications** | FCM integration untuk notifikasi real-time ke mobile | System (Backend) | Event triggers, user FCM token | Push notification delivery | ✅ Sudah | FCM HTTP v1 API dengan OAuth 2.0 |

**Keterangan Status:**
- ✅ **Sudah**: Fitur telah diimplementasikan dan berfungsi di environment development
- ⚠️ **Sebagian**: Implementasi parsial, masih dalam pengembangan
- ❌ **Belum**: Belum diimplementasikan

**Catatan Umum:**
- Semua fitur di atas telah diverifikasi dari codebase aktual (backend Laravel, mobile Flutter, ML service Python)
- Platform dalam tahap development, belum production
- Integrasi dengan BBI Auto masih rencana masa depan

---

## Catatan Status Implementasi

Platform BBI HUB saat ini berada dalam **tahap development** dan akan memasuki fase testing sebelum deployment ke production. Meskipun semua fitur inti telah diimplementasikan dan berfungsi, sistem belum digunakan oleh bengkel mitra aktual di lingkungan production. Infrastruktur production-ready seperti Sentry monitoring, Laravel Reverb, dan RoadRunner server telah disiapkan untuk mendukung deployment di masa mendatang.

**Integrasi dengan BBI Auto** saat ini belum diimplementasikan. Kedua platform (BBI HUB dan BBI Auto) masih beroperasi secara terpisah dan masing-masing fokus pada target development mereka. Integrasi teknis (mekanisme webhook, shared API, format data, authentication) direncanakan untuk fase pengembangan berikutnya setelah kedua platform mencapai kematangan yang cukup.

---


