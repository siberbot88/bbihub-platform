# Platform BBIHUB

**Ekosistem Manajemen Bengkel Modern**

Platform komprehensif untuk manajemen bengkel otomotif, terdiri dari dashboard administratif berbasis web dan aplikasi mobile untuk pemilik bengkel.

[![Laravel](https://img.shields.io/badge/Laravel-12.x-FF2D20?style=flat-square&logo=laravel&logoColor=white)](https://laravel.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![PHP](https://img.shields.io/badge/PHP-8.2+-777BB4?style=flat-square&logo=php&logoColor=white)](https://php.net)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=flat-square&logo=mysql&logoColor=white)](https://www.mysql.com)

---

## Daftar Isi

- [Pendahuluan](#pendahuluan)
- [Arsitektur Sistem](#arsitektur-sistem)
- [Alur Aplikasi](#alur-aplikasi)
- [Komponen Platform](#komponen-platform)
  - [Dashboard Web](#dashboard-web)
  - [Aplikasi Mobile](#aplikasi-mobile)
- [Fitur Utama](#fitur-utama)
- [Stack Teknologi](#stack-teknologi)
- [Implementasi Keamanan](#implementasi-keamanan)
- [Panduan Instalasi](#panduan-instalasi)
- [Dokumentasi API](#dokumentasi-api)
- [Struktur Proyek](#struktur-proyek)
- [Alur Pengembangan](#alur-pengembangan)
- [Pengujian](#pengujian)
- [Deployment](#deployment)
- [Kontribusi](#kontribusi)
- [Lisensi](#lisensi)

---

## Pendahuluan

### Gambaran Umum

BBIHUB adalah platform manajemen bengkel tingkat enterprise yang dirancang untuk mendigitalisasi dan merampingkan operasi bengkel otomotif di Indonesia. Platform ini mengatasi tantangan umum dalam manajemen bengkel tradisional dengan menyediakan solusi terintegrasi untuk pelacakan layanan, manajemen transaksi, pemantauan kinerja karyawan, dan manajemen hubungan pelanggan.

### Permasalahan

Bengkel otomotif tradisional menghadapi beberapa tantangan operasional:
- Pencatatan layanan dan transaksi manual yang menyebabkan inkonsistensi data
- Kurangnya insight bisnis dan analitik real-time
- Manajemen tugas karyawan dan pelacakan kinerja yang tidak efisien
- Kurangnya transparansi manajemen service harian

### Solusi

BBIHUB menyediakan ekosistem komprehensif yang mencakup:
- **Dashboard Web**: Panel administratif terpusat untuk superadmin dan manajemen bengkel
- **Aplikasi Mobile**: Alat manajemen portabel untuk pemilik bengkel
- **REST API**: Infrastruktur backend yang solid untuk sinkronisasi data yang mulus
- **Integrasi Pembayaran**: Penagihan otomatis dan pemrosesan pembayaran via Midtrans
- **Chatbot AI**: Otomasi layanan pelanggan yang cerdas

---

## Arsitektur Sistem

### Arsitektur Tingkat Tinggi

```
┌─────────────────────────────────────────────────────────────┐
│                     Lapisan Client                           │
├──────────────────────┬──────────────────────────────────────┤
│   Dashboard Web      │      Aplikasi Mobile                 │
│   (Livewire + Blade) │      (Flutter)                       │
└──────────┬───────────┴──────────────┬───────────────────────┘
           │                          │
           │      HTTPS/REST API      │
           │                          │
┌──────────▼──────────────────────────▼───────────────────────┐
│              Lapisan Aplikasi (Laravel 12)                   │
├──────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ Controllers │  │ Middleware  │  │   Service Layer     │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │   Models    │  │   Queues    │  │  Event Listeners    │ │
│  └─────────────┘  └─────────────┘  └─────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
           │
┌──────────▼──────────────────────────────────────────────────┐
│                   Lapisan Data                               │
├──────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   MySQL DB   │  │  File Storage│  │   Cache (Redis)  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└──────────────────────────────────────────────────────────────┘
           │
┌──────────▼──────────────────────────────────────────────────┐
│                Layanan Eksternal                             │
├──────────────────────────────────────────────────────────────┤
│  Pembayaran Midtrans │  Monitoring Sentry  │  Realtime Pusher│
└──────────────────────────────────────────────────────────────┘
```

### Pola Arsitektur

**Arsitektur Backend:**
- **Pola MVC**: Model-View-Controller untuk dashboard web
- **Pola Repository**: Layer abstraksi akses data
- **Pola Service Layer**: Pemisahan logika bisnis
- **Arsitektur Event-Driven**: Pemrosesan tugas asinkron dengan antrian

**Arsitektur Mobile:**
- **Pola Provider**: Manajemen state
- **Pola Repository**: Abstraksi data API
- **Clean Architecture**: Pemisahan concern (diimplementasikan sebagian)

### Alur Data

1. **Alur Autentikasi:**
   ```
   Permintaan Client → Middleware (Sanctum) → Controller → Service → Model → Database
   ```

2. **Alur Permintaan API:**
   ```
   Aplikasi Mobile → HTTP Client → API Endpoint → Validasi → Logika Bisnis → Response
   ```

3. **Pemrosesan Transaksi:**
   ```
   Aksi User → Controller → Service → Payment Gateway → Update Database → Event Dispatch → Queue Worker
   ```

---

## Alur Aplikasi

### Perjalanan User - Pemilik Bengkel

#### 1. Registrasi & Onboarding
```
Registrasi → Verifikasi Email → Pembuatan Bengkel → Setup Keanggotaan Trial → Akses Dashboard
```

#### 2. Manajemen Layanan
```
Definisi Layanan → Set Harga → Assign Kategori → Aktivasi Layanan → Monitoring Analitik
```

#### 3. Pemrosesan Transaksi
```
Kedatangan Pelanggan → Pemilihan Layanan → Pembuatan Invoice → Pemrosesan Pembayaran → Penyelesaian Layanan → Notifikasi Pelanggan
```

#### 4. Manajemen Karyawan
```
Tambah Karyawan → Assign Role → Definisi Spesialisasi → Assign Tugas → Tracking Kinerja
```

#### 5. Keanggotaan & Pembayaran
```
Trial Gratis (7 hari) → Setup Pembayaran (Midtrans) → Auto-charge → Keanggotaan Aktif → Auto-renewal
```

### Perjalanan User - Superadmin

#### 1. Administrasi Sistem
```
Login → Ikhtisar Dashboard → Manajemen User → Approval Bengkel → Konfigurasi Sistem
```

#### 2. Monitoring & Analitik
```
Metrik Platform → Laporan Revenue → Aktivitas User → Monitoring Transaksi → Kesehatan Sistem
```

### Alur User Aplikasi Mobile

```
Peluncuran App
    ↓
Pemeriksaan Autentikasi
    ↓
┌───Login Required───┐       ┌───Authenticated───┐
│                    │       │                   │
│ Screen Login       │────→  │  Dashboard        │
│ Registrasi         │       │                   │
└────────────────────┘       └─────────┬─────────┘
                                       │
                   ┌───────────────────┼───────────────────┐
                   ↓                   ↓                   ↓
            ┌──────────┐        ┌──────────┐       ┌──────────┐
            │ Layanan  │        │ Pesanan  │       │ Kendaraan│
            └──────────┘        └──────────┘       └──────────┘
                   ↓                   ↓                   ↓
            ┌──────────┐        ┌──────────┐       ┌──────────┐
            │ Tambah/  │        │ Proses   │       │ Tambah/  │
            │ Edit     │        │ Pembayar │       │ Lihat    │
            └──────────┘        └──────────┘       └──────────┘
```

---

## Komponen Platform

### Dashboard Web

Dashboard web berfungsi sebagai antarmuka administratif utama untuk superadmin dan manajemen bengkel.

#### Target User
- **Superadmin**: Administrator platform dengan akses sistem penuh
- **Manajer Bengkel**: Staf bengkel dengan kemampuan administratif terbatas

#### Modul Utama

**1. Ikhtisar Dashboard**
- Metrik bisnis real-time (kartu KPI)
- Analitik revenue dengan grafik
- Statistik layanan
- Ringkasan kinerja karyawan
- Transaksi terbaru dan notifikasi

**2. Manajemen Bengkel**
- Konfigurasi profil bengkel
- Pengaturan jam operasional
- Manajemen lokasi dan kontak
- Kustomisasi branding (logo, warna)
- Dukungan multi-bengkel

**3. Manajemen Layanan**
- Pembuatan dan pengeditan katalog layanan
- Organisasi berbasis kategori (Mesin, Body, Elektrikal, Transmisi, AC, Ban, dll.)
- Konfigurasi harga dinamis
- Aktivasi/deaktivasi layanan
- Pelacakan histori layanan

**4. Manajemen Transaksi**
- Pembuatan dan manajemen invoice
- Pelacakan status pembayaran
- Histori transaksi
- Pemrosesan refund
- Laporan keuangan

**5. Manajemen User & Role**
- Pembuatan akun user
- Kontrol akses berbasis role (RBAC)
- Manajemen permission via Spatie Permission
- Manajemen profil karyawan

**6. Manajemen Kendaraan & Pelanggan**
- Database pelanggan
- Registrasi kendaraan
- Histori layanan per kendaraan
- Pelacakan engagement pelanggan

**7. Sistem Keanggotaan & Voucher**
- Konfigurasi tier keanggotaan (Basic, Silver, Gold, Platinum)
- Manajemen trial
- Pembuatan dan distribusi voucher
- Konfigurasi aturan diskon

**8. Analitik & Pelaporan**
- Laporan revenue (harian, mingguan, bulanan, tahunan)
- Analisis popularitas layanan
- Metrik kinerja karyawan
- Analitik perilaku pelanggan
- Kemampuan export (PDF, Excel)

#### Implementasi Teknis

**Stack Frontend:**
- **Livewire Volt**: Komponen reaktif single-file untuk antarmuka dinamis
- **Tailwind CSS**: Styling utility-first dengan sistem desain kustom
- **Alpine.js**: JavaScript lightweight untuk perilaku interaktif
- **Chart.js/ApexCharts**: Visualisasi data

**Sistem Desain:**
- **Typography**: Poppins (primary), Fredoka (aksen)
- **Skema Warna**: Merah primary (#DC2626), Abu-abu gelap (#1F2937), palet Tailwind
- **Komponen**: Komponen Livewire yang dapat digunakan kembali
- **Responsive**: Pendekatan mobile-first dengan optimasi breakpoint

### Aplikasi Mobile

Aplikasi mobile berkualitas native yang dibangun dengan Flutter untuk pemilik dan manajer bengkel.

#### Target User
- **Pemilik Bengkel**: Pemilik bisnis yang mengelola satu atau beberapa bengkel
- **Manajer Bengkel**: Staf yang berwenang dengan izin manajemen

#### Fitur Utama

**1. Autentikasi & Keamanan**
- Login aman dengan autentikasi berbasis token (Laravel Sanctum)
- Dukungan autentikasi biometrik
- Auto-logout pada inaktivitas
- Penyimpanan kredensial aman via Flutter Secure Storage

**2. Dashboard**
- Mini dashboard dengan KPI kritis
- Ikhtisar revenue
- Jumlah layanan pending
- Ringkasan kinerja karyawan
- Tombol aksi cepat
- Sinkronisasi data real-time

**3. Manajemen Layanan**
- Telusuri katalog layanan
- Tambah/edit layanan
- Update harga layanan
- Lihat statistik layanan
- Manajemen antrian layanan

**4. Pemrosesan Pesanan & Transaksi**
- Registrasi layanan walk-in
- Penjadwalan appointment
- Pembuatan invoice
- Pemrosesan pembayaran dengan WebView Midtrans
- Histori transaksi
- Download invoice PDF

**5. Manajemen Kendaraan**
- Registrasi kendaraan
- Database kendaraan pelanggan
- Histori layanan per kendaraan
- Pelacakan odometer
- Manajemen foto kendaraan

**6. Manajemen Karyawan**
- Direktori karyawan
- Assignment spesialis
- Delegasi tugas
- Pelacakan kinerja
- Ikhtisar kehadiran (future)

**7. Manajemen Keanggotaan**
- Lihat status keanggotaan
- Aktivasi trial
- Pembayaran via Midtrans
- Histori keanggotaan
- Pengaturan auto-renewal

**8. Interaksi Pelanggan**
- Chatbot bertenaga AI
- Live chat dengan admin
- Respons FAQ cepat
- Histori chat

**9. Notifikasi**
- Push notification untuk event penting
- Deep linking ke layar relevan
- Histori notifikasi
- Preferensi notifikasi

**10. Dukungan Offline**
- Persistensi data lokal dengan SharedPreferences
- Mode offline untuk fitur kritis
- Sinkronisasi data saat jaringan pulih

#### Implementasi Teknis

**Arsitektur:**
- **Manajemen State**: Pola Provider untuk state reaktif
- **Navigasi**: Flutter Navigator 2.0
- **Layer API**: HTTP client dengan interceptor untuk autentikasi
- **Penyimpanan Lokal**: SharedPreferences (data app), Flutter Secure Storage (token)
- **Penanganan Gambar**: Image picker dengan kompresi

**UI/UX:**
- **Material Design 3**: Komponen UI modern
- **Tema Kustom**: Konsisten dengan panduan brand
- **Layout Responsif**: Adaptif terhadap berbagai ukuran layar
- **Animasi**: Transisi halus dan micro-interaction

---

## Fitur Utama

### Autentikasi & Otorisasi

**Dashboard Web:**
- Akses khusus superadmin untuk antarmuka web
- Dukungan autentikasi multi-faktor (future)
- Manajemen sesi dengan cookie aman
- Proteksi CSRF

**Aplikasi Mobile:**
- Autentikasi email dan password
- Autentikasi berbasis token via Laravel Sanctum
- Autentikasi biometrik (fingerprint/face ID)
- Mekanisme refresh token otomatis
- Penyimpanan token aman

**Kontrol Akses Berbasis Role:**
- Integrasi Spatie Laravel Permission
- Sistem permission granular
- Hierarki role: Superadmin > Pemilik Bengkel > Manajer > Teknisi
- Assignment permission dinamis

### Manajemen Layanan

**Katalog Layanan:**
- Kategorisasi hierarkis
- Pembuatan layanan kustom
- Konfigurasi harga per bengkel
- Estimasi durasi layanan
- Spesialisasi karyawan yang diperlukan

**Antrian Layanan:**
- Registrasi layanan walk-in
- Penjadwalan appointment
- Prioritasi antrian
- Update status real-time
- Pelacakan penyelesaian layanan

**Kategori Layanan:**
- Layanan Mesin
- Body & Cat
- Sistem Elektrikal
- Transmisi
- Air Conditioning
- Layanan Ban
- Pemeliharaan Umum

### Transaksi & Pembayaran

**Manajemen Invoice:**
- Pembuatan invoice otomatis
- Penagihan terperinci
- Kalkulasi pajak
- Aplikasi diskon
- Dukungan multi-mata uang (future)

**Pemrosesan Pembayaran:**
- Integrasi payment gateway Midtrans
- Berbagai metode pembayaran (kartu kredit, e-wallet, transfer bank)
- Update status pembayaran real-time
- Penanganan webhook untuk notifikasi pembayaran
- Pembuatan bukti pembayaran otomatis

**Alur Pembayaran:**
```
Pemilihan Layanan → Pembuatan Invoice → Payment Gateway (Midtrans) → Konfirmasi Pembayaran → 
Pembuatan Bukti → Aktivasi Layanan
```

### Sistem Keanggotaan

**Tier Keanggotaan:**
1. **Basic** (Trial Gratis)
   - Periode trial 7 hari
   - Fitur terbatas
   - Satu bengkel

2. **Silver**
   - Fitur standar
   - Hingga 2 bengkel
   - Analitik dasar

3. **Gold**
   - Fitur advanced
   - Hingga 5 bengkel
   - Analitik advanced
   - Dukungan prioritas

4. **Platinum**
   - Semua fitur
   - Bengkel unlimited
   - Branding kustom
   - Dukungan dedicated

**Alur Trial & Subscription:**
```
Registrasi → Trial Gratis (7 hari) → Setup Pembayaran (transaksi Rp 0) → 
Auto-charge setelah trial → Subscription Aktif → Auto-renewal Bulanan
```

### Sistem Voucher

**Jenis Voucher:**
- Diskon persentase (misal, diskon 10%)
- Diskon nominal tetap (misal, diskon Rp 50.000)
- Voucher spesifik layanan
- Voucher pelanggan pertama kali

**Manajemen Voucher:**
- Pembuatan dengan tanggal kadaluarsa
- Konfigurasi batas penggunaan
- Penanganan kadaluarsa otomatis
- Pelacakan penggunaan dan analitik

### Manajemen Karyawan

**Profil Karyawan:**
- Informasi personal
- Tag spesialisasi (Spesialis Mesin, Spesialis Body, dll.)
- Detail kontak
- Status pekerjaan

**Assignment Tugas:**
- Alokasi tugas berbasis layanan
- Penyeimbangan beban kerja
- Status tugas real-time
- Pelacakan penyelesaian

**Pelacakan Kinerja:**
- Jumlah layanan terselesaikan
- Rating pelanggan
- Rata-rata waktu layanan
- Kontribusi revenue

### Manajemen Kendaraan & Pelanggan

**Database Pelanggan:**
- Profil pelanggan
- Informasi kontak
- Histori layanan
- Kepemilikan kendaraan

**Manajemen Kendaraan:**
- Registrasi kendaraan (plat nomor, merk, model, tahun)
- Pelacakan odometer
- Histori layanan
- Histori penggunaan sparepart
- Foto kendaraan

### Analitik & Pelaporan

**Business Intelligence:**
- Pelacakan revenue (harian, mingguan, bulanan, tahunan)
- Analisis popularitas layanan
- Metrik retensi pelanggan
- Benchmarking kinerja karyawan
- Perbandingan bengkel (pemilik multi-bengkel)

**Kemampuan Export:**
- Laporan PDF
- Spreadsheet Excel
- Rentang tanggal kustom
- Laporan terjadwal (future)

### Chatbot AI

**Kemampuan:**
- Pemrosesan bahasa alami
- Otomasi FAQ
- Penanganan pertanyaan layanan
- Bantuan booking appointment
- Eskalasi ke agen manusia

**Integrasi:**
- Antarmuka chat real-time
- Persistensi histori chat
- Dukungan multi-bahasa (future)

---

## Stack Teknologi

### Teknologi Backend

**Framework Inti:**
- **Laravel 12.x**: Framework PHP modern dengan fitur terbaru
- **PHP 8.2+**: PHP modern yang type-safe

**Database:**
- **MySQL 8.0+**: Database relasional untuk data terstruktur
- **Redis**: Caching dan manajemen sesi (opsional)

**Autentikasi & Otorisasi:**
- **Laravel Sanctum**: Autentikasi token API
- **Spatie Laravel Permission**: Manajemen role dan permission

**Real-time & Queue:**
- **Laravel Queue**: Pemrosesan job asinkron
- **Laravel Reverb**: Broadcasting event real-time
- **Pusher**: Layanan real-time alternatif

**Integrasi Pembayaran:**
- **Midtrans**: Payment gateway Indonesia

**Monitoring & Analitik:**
- **Sentry**: Pelacakan error dan monitoring performa
- **Laravel Telescope**: Tool debugging development

**Package Utama:**
```json
{
  "laravel/sanctum": "Autentikasi API",
  "spatie/laravel-permission": "Implementasi RBAC",
  "spatie/laravel-activitylog": "Audit logging",
  "spatie/laravel-query-builder": "Filtering API advanced",
  "midtrans/midtrans-php": "SDK payment gateway",
  "sentry/sentry-laravel": "Monitoring error",
  "dedoc/scramble": "Generator dokumentasi API",
  "livewire/livewire": "Komponen reaktif",
  "livewire/volt": "Komponen single-file"
}
```

**Tool Development:**
```json
{
  "pestphp/pest": "Framework testing modern",
  "laravel/pint": "Code style fixer (PSR-12)",
  "barryvdh/laravel-debugbar": "Debugging development",
  "barryvdh/laravel-ide-helper": "Autocomplete IDE"
}
```

### Teknologi Frontend (Dashboard Web)

**Framework UI:**
- **Livewire Volt 3.x**: Komponen reaktif single-file
- **Blade**: Template engine
- **Alpine.js**: Framework JavaScript lightweight

**Styling:**
- **Tailwind CSS 3.x**: Framework CSS utility-first
- **Sistem Desain Kustom**: Style spesifik brand

**Build Tools:**
- **Vite**: Tool build frontend generasi selanjutnya
- **PostCSS**: Pemrosesan CSS

**Asset:**
- **Google Fonts**: Typography Poppins, Fredoka
- **Heroicons**: Library ikon

### Teknologi Mobile

**Framework:**
- **Flutter 3.0+**: Framework mobile cross-platform
- **Dart 3.0+**: Bahasa pemrograman

**Manajemen State:**
- **Provider**: Manajemen state reaktif

**Networking:**
- **http**: HTTP client untuk pemanggilan API
- **connectivity_plus**: Monitoring status jaringan

**Penyimpanan:**
- **flutter_secure_storage**: Penyimpanan kredensial terenkripsi
- **shared_preferences**: Penyimpanan lokal key-value

**Komponen UI:**
- **Material Design 3**: Komponen UI modern
- **google_fonts**: Typography kustom
- **flutter_svg**: Rendering asset SVG

**Grafik & Visualisasi:**
- **fl_chart**: Grafik lightweight
- **syncfusion_flutter_charts**: Grafik advanced
- **syncfusion_flutter_datepicker**: Pemilihan tanggal

**Utilitas:**
- **intl**: Internationalisasi dan formatting
- **image_picker**: Akses kamera dan galeri
- **url_launcher**: Penanganan URL eksternal
- **webview_flutter**: Browser in-app (pembayaran Midtrans)
- **app_links**: Deep linking
- **pdf & printing**: Pembuatan dan printing PDF

**Testing:**
- **flutter_test**: Widget dan unit testing
- **flutter_driver**: Integration testing (future)

### Infrastruktur

**Version Control:**
- **Git**: Source control
- **Struktur Monorepo**: Manajemen codebase terpadu

**Testing API:**
- **Postman**: Koleksi dan testing API

**Deployment:**
- **Backend**: VPS (DigitalOcean, AWS, dll.), Nginx/Apache, PHP-FPM
- **Mobile**: Google Play Store, Apple App Store

**CI/CD (Planned):**
- **GitHub Actions**: Testing dan deployment otomatis
- **Laravel Forge**: Manajemen server (opsional)

---

## Implementasi Keamanan

### Keamanan Autentikasi

**Autentikasi Berbasis Token:**
- Laravel Sanctum untuk autentikasi API stateless
- Expirasi dan rotasi token
- Penyimpanan token aman di aplikasi mobile (Flutter Secure Storage dengan enkripsi AES)
- Cookie HTTPOnly untuk sesi web

**Keamanan Password:**
- Algoritma hashing Bcrypt (cost factor 10)
- Penegakan panjang minimum password
- Persyaratan kompleksitas password
- Reset password dengan token waktu terbatas
- Penguncian akun setelah percobaan gagal (future)

**Keamanan Sesi:**
- Proteksi token CSRF untuk form web
- Cookie sesi aman (HTTP-only, flag Secure)
- Timeout sesi dan logout otomatis
- Manajemen sesi concurrent

### Keamanan Otorisasi

**Kontrol Akses Berbasis Role (RBAC):**
- Package Spatie Permission untuk permission granular
- Penegakan hierarki role
- Caching permission untuk performa
- Pemeriksaan permission dinamis di level route dan action

**Otorisasi API:**
- Otorisasi berbasis middleware
- Pemeriksaan permission level resource
- Kontrol akses berbasis owner (user hanya dapat mengakses data mereka)
- Kemampuan override admin dengan audit logging

### Keamanan Data

**Enkripsi Data:**
- Enkripsi kolom database untuk data sensitif (future enhancement)
- HTTPS/TLS untuk semua data in transit
- Penyimpanan terenkripsi untuk token autentikasi

**Keamanan Database:**
- Query terparameterisasi (Eloquent ORM) mencegah SQL injection
- User database dengan privilege minimal yang diperlukan
- Tidak ada eksposur database langsung ke jaringan publik
- Backup database reguler dengan enkripsi

**Validasi Input:**
- Validasi Form Request untuk semua input user
- Pencegahan XSS melalui escaping otomatis Laravel
- Validasi upload file (tipe, ukuran, whitelist ekstensi)
- Validasi request API dengan aturan kustom

**Sanitasi Output:**
- Escaping otomatis template Blade
- Sanitasi response JSON
- HTML Purifier untuk konten rich text (jika berlaku)

### Keamanan Aplikasi

**Proteksi Middleware:**
- Middleware autentikasi untuk route yang dilindungi
- Rate limiting untuk mencegah serangan brute force
- Konfigurasi CORS untuk kontrol akses API
- Request throttling berdasarkan IP dan user

**Keamanan API:**
- Versioning API untuk backward compatibility
- Request signing (planned)
- Kemampuan rotasi API key
- Verifikasi signature webhook (Midtrans)

**Keamanan Upload File:**
- Validasi tipe mime
- Batas ukuran file
- Pemindaian virus (planned)
- Penyimpanan file aman di luar direktori publik
- Pembuatan nama file unik

### Keamanan Pembayaran

**Integrasi Midtrans:**
- Validasi server-side untuk notifikasi pembayaran
- Verifikasi signature webhook
- Pemeriksaan idempotency untuk mencegah pemrosesan ganda
- Kepatuhan PCI DSS melalui Midtrans

**Keamanan Transaksi:**
- Transaksi database untuk atomicity
- Pencegahan transaksi duplikat
- Hook deteksi fraud (future)
- Audit logging transaksi

### Keamanan Infrastruktur

**Konfigurasi Server:**
- Konfigurasi firewall (UFW/iptables)
- Autentikasi berbasis SSH key
- Fail2ban untuk pencegahan intrusi
- Update keamanan reguler

**Keamanan Environment:**
- Environment variables untuk konfigurasi sensitif
- File .env dikecualikan dari version control
- Environment terpisah (development, staging, production)
- Pengaturan keamanan spesifik environment

**Monitoring & Logging:**
- Sentry untuk pelacakan error dan alerting
- Activity logging dengan Spatie Activity Log
- Logging percobaan autentikasi
- Monitoring event keamanan
- Retensi log yang patuh GDPR

### Keamanan Mobile

**Keamanan App:**
- Certificate pinning untuk komunikasi API (planned)
- Deteksi root dan jailbreak (planned)
- Obfuscation kode untuk release build
- Penyimpanan lokal aman dengan enkripsi

**Keamanan Jaringan:**
- TLS 1.3 untuk semua komunikasi jaringan
- Validasi sertifikat
- Deteksi proxy (planned)
- Deteksi VPN (planned)

### Kepatuhan & Best Practice

**Standar Keamanan:**
- Mitigasi OWASP Top 10
- Best practice keamanan Laravel
- Audit keamanan reguler (planned)
- Pemindaian kerentanan dependency

**Privasi Data:**
- Arsitektur siap-GDPR (export/penghapusan data user)
- Kepatuhan regulasi privasi data Indonesia
- Kebijakan privasi yang jelas
- Manajemen consent user

**Audit Trail:**
- Activity logging komprehensif
- Pelacakan aksi user
- Logging aksi admin
- Log audit yang immutable

---

## Panduan Instalasi

### Prasyarat

**Kebutuhan Backend:**
```
PHP >= 8.2
Composer >= 2.0
Node.js >= 18.x
npm >= 9.x
MySQL >= 8.0
Git
```

**Kebutuhan Mobile:**
```
Flutter SDK >= 3.0
Dart SDK >= 3.0
Android Studio (untuk development Android)
Xcode (untuk development iOS, hanya macOS)
```

### Instalasi Backend

#### 1. Clone Repository
```bash
git clone https://github.com/siberbot88/bbihub-platform.git
cd bbihub-platform/backend
```

#### 2. Install Dependency PHP
```bash
composer install
```

#### 3. Install Dependency Node
```bash
npm install
```

#### 4. Konfigurasi Environment
```bash
cp .env.example .env
php artisan key:generate
```

#### 5. Konfigurasi Database
Edit file `.env`:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=bbihub
DB_USERNAME=root
DB_PASSWORD=password_aman_anda
```

Buat database:
```bash
mysql -u root -p
CREATE DATABASE bbihub CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

#### 6. Migrasi & Seeding Database
```bash
php artisan migrate --seed
```

#### 7. Linking Storage
```bash
php artisan storage:link
```

#### 8. Build Asset Frontend
```bash
npm run build
```

#### 9. Konfigurasi Queue (Opsional tapi Direkomendasikan)
Edit `.env`:
```env
QUEUE_CONNECTION=database
```

Jalankan queue worker:
```bash
php artisan queue:table
php artisan migrate
```

### Instalasi Mobile

#### 1. Navigasi ke Direktori Mobile
```bash
cd ../mobile
```

#### 2. Install Dependency Flutter
```bash
flutter pub get
```

#### 3. Konfigurasi Endpoint API
Edit `lib/services/api_service.dart` atau file konfigurasi yang setara:
```dart
static const String baseUrl = 'http://backend-url-anda.com/api';
```

#### 4. Generate Icon App (Opsional)
```bash
flutter pub run flutter_launcher_icons
```

#### 5. Jalankan Aplikasi
```bash
# Untuk development
flutter run

# Pilih target device saat diminta
```

### Server Development

#### Server Development Backend (3 opsi)

**Opsi 1: Single Command (Direkomendasikan)**
```bash
cd backend
composer run dev
```
Ini menjalankan server Laravel, queue worker, dan Vite dev server secara bersamaan.

**Opsi 2: Manual (3 terminal terpisah)**

Terminal 1 - Laravel:
```bash
cd backend
php artisan serve
```

Terminal 2 - Queue Worker:
```bash
cd backend
php artisan queue:listen --tries=1
```

Terminal 3 - Vite:
```bash
cd backend
npm run dev
```

**Opsi 3: Laravel Sail (Docker)**
```bash
cd backend
./vendor/bin/sail up
```

#### Titik Akses

- Dashboard Web: `http://localhost:8000`
- API Endpoint: `http://localhost:8000/api`
- Kredensial default: `superadmin@gmail.com` / `password`

### Development Mobile

```bash
cd mobile
flutter run

# Untuk device spesifik
flutter devices
flutter run -d <device_id>

# Untuk hot reload selama development, tekan 'r' di terminal
# Untuk hot restart, tekan 'R'
```

---

## Dokumentasi API

### Base URL

```
Development: http://localhost:8000/api
Production: https://api.bbihub.com/api
```

### Autentikasi

Semua endpoint kecuali route autentikasi memerlukan autentikasi Bearer token.

**Header:**
```http
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### Endpoint Autentikasi

#### Registrasi
```http
POST /api/auth/register

Request Body:
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!",
  "password_confirmation": "SecurePass123!"
}

Response: 201 Created
{
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john@example.com"
    },
    "token": "1|abc123..."
  },
  "message": "Registrasi berhasil"
}
```

#### Login
```http
POST /api/auth/login

Request Body:
{
  "email": "john@example.com",
  "password": "SecurePass123!",
  "remember": true
}

Response: 200 OK
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
  "message": "Login berhasil"
}
```

#### Logout
```http
POST /api/auth/logout
Authorization: Bearer {token}

Response: 200 OK
{
  "message": "Logout berhasil"
}
```

#### Get Authenticated User
```http
GET /api/auth/me
Authorization: Bearer {token}

Response: 200 OK
{
  "data": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "roles": ["owner"],
    "workshops": [...]
  }
}
```

### Endpoint API Inti

#### Bengkel
```http
GET    /api/workshops              # Daftar semua bengkel
POST   /api/workshops              # Buat bengkel
GET    /api/workshops/{uuid}       # Detail bengkel
PUT    /api/workshops/{uuid}       # Update bengkel
DELETE /api/workshops/{uuid}       # Hapus bengkel
```

#### Layanan
```http
GET    /api/services               # Daftar semua layanan
POST   /api/services               # Buat layanan
GET    /api/services/{uuid}        # Detail layanan
PUT    /api/services/{uuid}        # Update layanan
DELETE /api/services/{uuid}        # Hapus layanan
GET    /api/services/categories    # Kategori layanan
```

#### Transaksi
```http
GET    /api/transactions           # Daftar transaksi
POST   /api/transactions           # Buat transaksi
GET    /api/transactions/{uuid}    # Detail transaksi
PUT    /api/transactions/{uuid}    # Update status transaksi
POST   /api/transactions/{uuid}/pay # Proses pembayaran
```

#### Kendaraan
```http
GET    /api/vehicles               # Daftar kendaraan
POST   /api/vehicles               # Registrasi kendaraan
GET    /api/vehicles/{uuid}        # Detail kendaraan
PUT    /api/vehicles/{uuid}        # Update kendaraan
DELETE /api/vehicles/{uuid}        # Hapus kendaraan
```

#### Karyawan
```http
GET    /api/employees              # Daftar karyawan
POST   /api/employees              # Tambah karyawan
GET    /api/employees/{uuid}       # Detail karyawan
PUT    /api/employees/{uuid}       # Update karyawan
DELETE /api/employees/{uuid}       # Hapus karyawan
GET    /api/employees/{uuid}/performance # Metrik kinerja
```

#### Dashboard
```http
GET    /api/dashboard/stats        # Statistik dashboard
GET    /api/dashboard/revenue      # Data revenue
GET    /api/dashboard/services     # Statistik layanan
GET    /api/dashboard/employees    # Kinerja karyawan
```

#### Keanggotaan
```http
GET    /api/membership/status      # Keanggotaan saat ini
POST   /api/membership/trial       # Mulai trial gratis
POST   /api/membership/subscribe   # Subscribe plan
GET    /api/membership/history     # Histori subscription
```

### Pagination

Endpoint list mendukung pagination:
```http
GET /api/services?page=1&per_page=15

Response:
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "last_page": 5,
    "per_page": 15,
    "total": 73
  }
}
```

### Filtering & Sorting

```http
GET /api/transactions?filter[status]=completed&sort=-created_at
```

### Response Error

```json
{
  "message": "Data yang diberikan tidak valid.",
  "errors": {
    "email": ["Email sudah digunakan."]
  }
}
```

### Koleksi Postman

Import koleksi Postman dari direktori `postman/` untuk dokumentasi API lengkap dengan contoh.

---

## Struktur Proyek

```
bbihub-platform/
├── backend/                          # Backend Laravel
│   ├── app/
│   │   ├── Console/                  # Command Artisan
│   │   ├── Exceptions/               # Exception handler
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   │   ├── Api/             # Controller API RESTful
│   │   │   │   │   ├── AuthController.php
│   │   │   │   │   ├── WorkshopController.php
│   │   │   │   │   ├── ServiceController.php
│   │   │   │   │   ├── TransactionController.php
│   │   │   │   │   └── ...
│   │   │   │   └── Web/             # Controller web (minimal)
│   │   │   ├── Middleware/          # Middleware kustom
│   │   │   └── Requests/            # Validasi form request
│   │   ├── Livewire/                # Komponen Livewire Volt
│   │   │   ├── Auth/
│   │   │   ├── Dashboard/
│   │   │   ├── Workshops/
│   │   │   └── ...
│   │   ├── Models/                  # Model Eloquent
│   │   │   ├── User.php
│   │   │   ├── Workshop.php
│   │   │   ├── Service.php
│   │   │   ├── Transaction.php
│   │   │   └── ...
│   │   ├── Providers/               # Service provider
│   │   └── Services/                # Service logika bisnis
│   │       ├── AuthService.php
│   │       ├── PaymentService.php
│   │       └── ...
│   ├── bootstrap/                   # Bootstrap framework
│   ├── config/                      # File konfigurasi
│   ├── database/
│   │   ├── factories/               # Factory model
│   │   ├── migrations/              # Migrasi database
│   │   └── seeders/                 # Seeder database
│   ├── public/                      # Asset publik
│   ├── resources/
│   │   ├── css/                     # Stylesheet
│   │   ├── js/                      # JavaScript
│   │   └── views/
│   │       ├── components/          # Komponen Blade
│   │       ├── layouts/             # Layout
│   │       ├── livewire/            # View Livewire
│   │       └── errors/              # Halaman error
│   ├── routes/
│   │   ├── api.php                  # Route API
│   │   ├── web.php                  # Route web
│   │   └── auth.php                 # Route auth
│   ├── storage/                     # Penyimpanan file
│   │   ├── app/
│   │   ├── framework/
│   │   └── logs/
│   ├── tests/                       # Test PHPUnit/Pest
│   │   ├── Feature/
│   │   └── Unit/
│   ├── .env.example
│   ├── composer.json
│   ├── package.json
│   └── phpunit.xml
│
├── mobile/                           # Aplikasi Mobile Flutter
│   ├── android/                      # Kode native Android
│   ├── ios/                          # Kode native iOS
│   ├── lib/
│   │   ├── main.dart                # Entry point app
│   │   ├── models/                  # Model data
│   │   │   ├── user.dart
│   │   │   ├── workshop.dart
│   │   │   ├── service.dart
│   │   │   └── ...
│   │   ├── providers/               # Manajemen state Provider
│   │   │   ├── auth_provider.dart
│   │   │   ├── workshop_provider.dart
│   │   │   └── ...
│   │   ├── screens/                 # Screen app
│   │   │   ├── auth/
│   │   │   ├── dashboard/
│   │   │   ├── services/
│   │   │   ├── transactions/
│   │   │   └── ...
│   │   ├── services/                # Service API
│   │   │   ├── api_service.dart
│   │   │   ├── auth_service.dart
│   │   │   └── ...
│   │   ├── utils/                   # Utilitas
│   │   │   ├── constants.dart
│   │   │   ├── helpers.dart
│   │   │   └── ...
│   │   └── widgets/                 # Widget yang dapat digunakan kembali
│   │       ├── custom_button.dart
│   │       ├── custom_card.dart
│   │       └── ...
│   ├── assets/                      # Gambar, ikon, font
│   ├── test/                        # Widget & unit test
│   ├── pubspec.yaml
│   └── README.md
│
├── postman/                          # Testing API
│   ├── BBIHUB_API.postman_collection.json
│   └── README.md
│
├── .gitignore
├── README.md
└── LICENSE
```

---

## Alur Pengembangan

### Alur Git

**Strategi Branching:**
```
main           # Kode siap production
develop        # Branch integrasi development (default)
feature/*      # Branch development fitur
bugfix/*       # Branch fix bug
hotfix/*       # Fix production urgent
release/*      # Branch persiapan release
```

**Development Fitur:**
```bash
# Buat branch fitur dari develop
git checkout develop
git pull origin develop
git checkout -b feature/nama-fitur-baru

# Buat perubahan, commit
git add .
git commit -m "feat: tambah fitur baru"

# Push dan buat pull request
git push origin feature/nama-fitur-baru
```

**Konvensi Commit Message:**
```
feat: Tambah fitur baru
fix: Perbaiki bug di pemrosesan layanan
docs: Update dokumentasi API
style: Format kode dengan Pint
refactor: Refactor service pembayaran
test: Tambah unit test untuk AuthController
chore: Update dependency
```

### Standar Kode

**Backend (Laravel/PHP):**
- Ikuti standar coding PSR-12
- Jalankan Laravel Pint sebelum commit: `./vendor/bin/pint`
- Tulis test untuk fitur baru
- Dokumentasikan method publik dengan PHPDoc
- Gunakan type hint untuk semua parameter method dan return type

**Mobile (Flutter/Dart):**
- Ikuti panduan style Dart
- Jalankan `flutter analyze` sebelum commit
- Gunakan nama widget dan class yang bermakna
- Tulis widget test untuk komponen UI
- Dokumentasikan API publik

### Strategi Testing

**Testing Backend:**
```bash
# Jalankan semua test
php artisan test

# Jalankan suite spesifik
php artisan test --testsuite=Feature
php artisan test --testsuite=Unit

# Dengan coverage
php artisan test --coverage
```

**Testing Mobile:**
```bash
# Jalankan semua test
flutter test

# Jalankan dengan coverage
flutter test --coverage

# Jalankan test spesifik
flutter test test/widget_test.dart
```

---

## Pengujian

### Testing Backend

**Struktur Test:**
```
tests/
├── Feature/                  # Test integrasi
│   ├── Api/
│   │   ├── AuthTest.php
│   │   ├── WorkshopTest.php
│   │   └── ...
│   └── ...
└── Unit/                     # Unit test
    ├── Services/
    │   ├── PaymentServiceTest.php
    │   └── ...
    └── ...
```

**Menjalankan Test:**
```bash
# Semua test
php artisan test

# Test spesifik
php artisan test --filter AuthTest

# Dengan coverage
php artisan test --coverage --min=80
```

**Contoh Test:**
```php
test('user can login with valid credentials', function () {
    $user = User::factory()->create([
        'password' => bcrypt('password')
    ]);

    $response = $this->postJson('/api/auth/login', [
        'email' => $user->email,
        'password' => 'password'
    ]);

    $response->assertOk()
             ->assertJsonStructure(['data' => ['token', 'user']]);
});
```

### Testing Mobile

**Struktur Test:**
```
test/
├── widget_test.dart          # Widget test
├── unit/                     # Unit test
│   └── models/
│       └── user_test.dart
└── integration/              # Integration test (future)
```

**Menjalankan Test:**
```bash
# Semua test
flutter test

# Test spesifik
flutter test test/widget_test.dart

# Dengan coverage
flutter test --coverage
lcov --summary coverage/lcov.info
```

---

## Deployment

### Deployment Backend

#### Kebutuhan Server Production
- Ubuntu 20.04+ atau distribusi Linux serupa
- Web server Nginx atau Apache
- PHP 8.2+ dengan ekstensi yang diperlukan
- MySQL 8.0+
- Redis (direkomendasikan)
- Sertifikat SSL (Let's Encrypt)

#### Langkah Deployment

**1. Setup Server**
```bash
# Update sistem
sudo apt update && sudo apt upgrade -y

# Install PHP 8.2
sudo apt install php8.2-fpm php8.2-mysql php8.2-mbstring php8.2-xml php8.2-curl

# Install MySQL
sudo apt install mysql-server

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs
```

**2. Deploy Aplikasi**
```bash
# Clone repository
git clone https://github.com/siberbot88/bbihub-platform.git /var/www/bbihub
cd /var/www/bbihub/backend

# Install dependency
composer install --no-dev --optimize-autoloader
npm install && npm run build

# Konfigurasi environment
cp .env.example .env
nano .env  # Edit pengaturan production

# Generate key
php artisan key:generate

# Jalankan migrasi
php artisan migrate --force

# Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set permission
sudo chown -R www-data:www-data /var/www/bbihub
sudo chmod -R 755 /var/www/bbihub/backend/storage
```

**3. Konfigurasi Nginx**
```nginx
server {
    listen 80;
    server_name api.bbihub.com;
    root /var/www/bbihub/backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**4. Konfigurasi SSL**
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Dapatkan sertifikat
sudo certbot --nginx -d api.bbihub.com
```

**5. Queue Worker (Supervisor)**
```ini
[program:bbihub-worker]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/bbihub/backend/artisan queue:work --sleep=3 --tries=3
autostart=true
autorestart=true
user=www-data
numprocs=4
redirect_stderr=true
stdout_logfile=/var/www/bbihub/backend/storage/logs/worker.log
```

**6. Scheduler (Cron)**
```bash
# Edit crontab
sudo crontab -e

# Tambahkan baris
* * * * * cd /var/www/bbihub/backend && php artisan schedule:run >> /dev/null 2>&1
```

### Deployment Mobile

#### Android (Google Play Store)

**1. Build Release APK**
```bash
cd mobile
flutter build apk --release
```

**2. Build App Bundle (Direkomendasikan)**
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

**3. Upload ke Google Play Console**
- Buat aplikasi di Play Console
- Upload file AAB
- Lengkapi store listing
- Submit untuk review

#### iOS (App Store)

**1. Build Release**
```bash
cd mobile
flutter build ios --release
```

**2. Archive di Xcode**
- Buka `ios/Runner.xcworkspace` di Xcode
- Pilih "Any iOS Device" sebagai target
- Product > Archive
- Upload ke App Store Connect

**3. Submission App Store**
- Lengkapi informasi app di App Store Connect
- Submit untuk review

---

## Kontribusi

### Cara Berkontribusi

Kami menyambut kontribusi dari komunitas. Silakan ikuti panduan berikut:

**1. Fork Repository**
```bash
# Fork di GitHub lalu clone
git clone https://github.com/YOUR_USERNAME/bbihub-platform.git
cd bbihub-platform
```

**2. Buat Branch Fitur**
```bash
git checkout develop
git checkout -b feature/nama-fitur-anda
```

**3. Buat Perubahan**
- Ikuti standar coding
- Tulis test untuk fitur baru
- Update dokumentasi sesuai kebutuhan

**4. Commit Perubahan**
```bash
git add .
git commit -m "feat: tambah deskripsi fitur anda"
```

**5. Push dan Buat Pull Request**
```bash
git push origin feature/nama-fitur-anda
```
Kemudian buat pull request di GitHub yang menargetkan branch `develop`.

### Panduan Pull Request

- Berikan deskripsi perubahan yang jelas
- Referensikan issue terkait
- Pastikan semua test berhasil
- Update dokumentasi
- Ikuti konvensi commit message
- Jaga perubahan tetap fokus dan atomic

### Proses Code Review

1. Test otomatis harus berhasil
2. Code review oleh maintainer
3. Tangani feedback review
4. Approval dan merge

---

## Lisensi

Proyek ini dilisensikan di bawah **Lisensi MIT**.

Copyright (c) 2025 Tim Pengembangan BBIHUB

Dengan ini diberikan izin, tanpa biaya, kepada siapa pun yang memperoleh salinan perangkat lunak ini dan file dokumentasi terkait ("Perangkat Lunak"), untuk beroperasi dengan Perangkat Lunak tanpa batasan, termasuk tanpa batasan hak untuk menggunakan, menyalin, memodifikasi, menggabungkan, menerbitkan, mendistribusikan, mensublisensikan, dan/atau menjual salinan Perangkat Lunak, dan untuk mengizinkan orang-orang yang menerima Perangkat Lunak untuk melakukan hal yang sama, dengan tunduk pada kondisi berikut:

Pemberitahuan hak cipta di atas dan pemberitahuan izin ini harus disertakan dalam semua salinan atau bagian substansial dari Perangkat Lunak.

PERANGKAT LUNAK INI DISEDIAKAN "SEBAGAIMANA ADANYA", TANPA JAMINAN APA PUN, BAIK TERSURAT MAUPUN TERSIRAT, TERMASUK NAMUN TIDAK TERBATAS PADA JAMINAN KELAYAKAN UNTUK DIPERDAGANGKAN, KESESUAIAN UNTUK TUJUAN TERTENTU DAN TIDAK ADANYA PELANGGARAN. DALAM KEADAAN APA PUN PENULIS ATAU PEMEGANG HAK CIPTA TIDAK BERTANGGUNG JAWAB ATAS KLAIM, KERUSAKAN ATAU KEWAJIBAN LAINNYA, BAIK DALAM TINDAKAN KONTRAK, PERBUATAN MELAWAN HUKUM ATAU SEBALIKNYA, YANG TIMBUL DARI, DARI ATAU SEHUBUNGAN DENGAN PERANGKAT LUNAK ATAU PENGGUNAAN ATAU PENGOPERASIAN LAIN DALAM PERANGKAT LUNAK.

---

## Dukungan

**Dukungan Teknis:**
- GitHub Issues: [Laporkan bug dan minta fitur](https://github.com/siberbot88/bbihub-platform/issues)
- Dokumentasi: [Wiki](https://github.com/siberbot88/bbihub-platform/wiki)
- Email: support@bbihub.com

**Tim Pengembangan:**
- Lead Developer: [Nama Anda]
- Tim Backend: [Nama]
- Tim Mobile: [Nama]
- DevOps: [Nama]

---

**Dibangun dengan Laravel dan Flutter**

Copyright 2025 Tim Pengembangan BBIHUB. All rights reserved.
