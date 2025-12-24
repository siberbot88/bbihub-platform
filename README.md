<div align="center">

# 🚀 BBIHUB Platform

### _Modern Workshop Management Ecosystem_

[![Laravel](https://img.shields.io/badge/Laravel-12.x-FF2D20?style=for-the-badge&logo=laravel&logoColor=white)](https://laravel.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![PHP](https://img.shields.io/badge/PHP-8.2+-777BB4?style=for-the-badge&logo=php&logoColor=white)](https://php.net)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

**Platform manajemen bengkel komprehensif dengan Web Dashboard dan Mobile Application**

[Fitur](#-fitur-utama) • [Tech Stack](#-tech-stack) • [Instalasi](#-instalasi) • [Struktur](#-struktur-monorepo) • [Kontribusi](#-kontribusi)

---

</div>

## 📋 Tentang BBIHUB

**BBIHUB** adalah ekosistem manajemen bengkel modern yang dirancang untuk meningkatkan efisiensi operasional bengkel kendaraan di Indonesia. Platform ini terdiri dari:

- **🖥️ Web Dashboard** - Admin panel berbasis Laravel + Livewire untuk superadmin dan manajemen bengkel
- **📱 Mobile App** - Aplikasi Flutter untuk owner bengkel, memungkinkan monitoring dan manajemen on-the-go
- **🔌 REST API** - Backend API yang robust untuk komunikasi mobile app dengan server

### 🎯 Tujuan Aplikasi

BBIHUB hadir untuk menyelesaikan masalah umum dalam manajemen bengkel tradisional:
- ✅ Pengelolaan layanan dan transaksi yang terintegrasi
- ✅ Tracking performa karyawan secara real-time
- ✅ Manajemen inventori sparepart dan kendaraan pelanggan
- ✅ Sistem membership dan voucher otomatis
- ✅ Laporan keuangan dan analitik bisnis
- ✅ Komunikasi dengan pelanggan melalui AI chatbot

## ✨ Fitur Utama

### 🏢 Workshop Management
- **Multi-workshop Support** - Kelola beberapa bengkel dalam satu platform
- **Custom Branding** - Logo, warna, dan identitas unik untuk setiap bengkel
- **Operational Hours** - Manajemen jam operasional yang fleksibel
- **Location Tracking** - Integrasi dengan maps untuk lokasi bengkel

### 🔧 Service Management
- **Service Catalog** - Katalog layanan lengkap dengan kategori (Engine, Body, Electrical, Transmission, AC, Tire, dll.)
- **Dynamic Pricing** - Harga layanan yang dapat disesuaikan per bengkel
- **Service Queue** - Sistem antrian layanan walk-in dan appointment
- **Service History** - Riwayat lengkap layanan per kendaraan

### 💰 Transaction & Payment
- **Invoice Generation** - Pembuatan invoice otomatis dengan detail lengkap
- **Multiple Payment Methods** - Support berbagai metode pembayaran
- **Midtrans Integration** - Payment gateway terintegrasi untuk membership
- **Trial System** - Free trial 7 hari dengan auto-charge
- **Transaction Reports** - Laporan transaksi komprehensif

### 👥 User & Role Management
- **Role-Based Access Control** - Superadmin, Workshop Owner, Manager, Technician
- **Spatie Permission** - Manajemen permission yang granular
- **User Authentication** - Login secure dengan Laravel Sanctum
- **Profile Management** - Kelola profile dan preferensi user

### 🚗 Vehicle Management
- **Customer Vehicles** - Database kendaraan pelanggan lengkap
- **Vehicle Details** - Plat nomor, merk, model, tahun, odometer, dll.
- **Service History** - Tracking semua layanan per kendaraan
- **Sparepart Tracking** - Pencatatan sparepart yang digunakan

### 👷 Employee Management
- **Specialist Assignment** - Assign teknisi berdasarkan spesialisasi
- **Performance Tracking** - Monitor kinerja karyawan
- **Task Management** - Pembagian tugas layanan
- **Attendance System** - Pencatatan kehadiran (future enhancement)

### 🎫 Membership & Voucher
- **Membership Tiers** - Basic, Silver, Gold, Platinum dengan benefit berbeda
- **Trial Period** - Free trial 7 hari untuk membership
- **Voucher System** - Buat dan kelola voucher diskon
- **Auto-renewal** - Perpanjangan membership otomatis via Midtrans

### 📊 Analytics & Reporting
- **Dashboard KPI** - Key Performance Indicators untuk owner
- **Revenue Reports** - Laporan pendapatan harian, mingguan, bulanan
- **Service Statistics** - Statistik layanan yang paling populer
- **Customer Analytics** - Analisis perilaku dan preferensi pelanggan

### 💬 AI Chatbot
- **Live Chat** - Chat dengan admin atau AI assistant
- **Quick Questions** - Template pertanyaan umum
- **Smart Response** - AI-powered response untuk FAQ
- **Chat History** - Riwayat percakapan tersimpan

### 📱 Mobile-Specific Features
- **Offline Support** - Local data persistence dengan SharedPreferences
- **Push Notifications** - Notifikasi real-time untuk update penting
- **Deep Linking** - Navigasi langsung ke fitur tertentu dari notifikasi
- **Image Upload** - Upload foto untuk layanan dan kendaraan
- **PDF Generation** - Generate dan download invoice PDF

## 🛠️ Tech Stack

### Backend (Laravel)
```
Framework:      Laravel 12.x
Language:       PHP 8.2+
Database:       MySQL 8.0+
Authentication: Laravel Sanctum
Authorization:  Spatie Laravel Permission
Real-time:      Laravel Reverb
Queue:          Laravel Queue Worker
```

**Key Packages:**
- `laravel/livewire` - Reactive components untuk web UI
- `livewire/volt` - Single-file Livewire components
- `spatie/laravel-permission` - Role & permission management
- `spatie/laravel-activitylog` - Audit log activities
- `spatie/laravel-query-builder` - Advanced API filtering
- `midtrans/midtrans-php` - Payment gateway integration
- `sentry/sentry-laravel` - Error tracking & monitoring
- `dedoc/scramble` - API documentation generator
- `pusher/pusher-php-server` - Real-time notifications

**Development Tools:**
- `pestphp/pest` - Modern testing framework
- `laravel/pint` - Code style fixer
- `barryvdh/laravel-debugbar` - Debugging toolbar
- `barryvdh/laravel-ide-helper` - IDE autocomplete support

### Frontend (Web Dashboard)
```
Framework:    Livewire Volt 3.x
Styling:      Tailwind CSS 3.x
JavaScript:   Alpine.js
Build Tool:   Vite
```

**Design System:**
- **Typography**: Poppins (body), Fredoka (accents)
- **Colors**: Red Primary (#DC2626), Dark Gray (#1F2937)
- **Components**: Custom Livewire components dengan Tailwind utilities

### Mobile (Flutter)
```
Framework:      Flutter 3.0+
Language:       Dart 3.0+
State:          Provider Pattern
Architecture:   Clean Architecture (partially)
```

**Key Packages:**
- `http` - HTTP client untuk API calls
- `provider` - State management
- `flutter_secure_storage` - Secure token storage
- `shared_preferences` - Local data persistence
- `google_fonts` - Custom typography
- `fl_chart` & `syncfusion_flutter_charts` - Data visualization
- `image_picker` - Image upload functionality
- `webview_flutter` - Midtrans payment webview
- `url_launcher` - External link handling
- `app_links` - Deep linking support
- `connectivity_plus` - Network status monitoring
- `pdf` & `printing` - PDF generation & printing
- `intl` - Internationalization

### Infrastructure & DevOps
```
Version Control:  Git (Monorepo)
API Testing:      Postman Collections
Error Tracking:   Sentry
Payment Gateway:  Midtrans
```

## 📦 Instalasi

### Prerequisites
```bash
# Backend Requirements
PHP >= 8.2
Composer >= 2.0
Node.js >= 18.x
MySQL >= 8.0

# Mobile Requirements
Flutter SDK >= 3.0
Dart SDK >= 3.0
Android Studio / Xcode (for mobile development)
```

### 🚀 Quick Start

#### 1. Clone Repository
```bash
git clone https://github.com/siberbot88/bbihub-platform.git
cd bbihub-platform
git checkout develop
```

#### 2. Setup Backend (Laravel)

```bash
cd backend

# Install PHP dependencies
composer install

# Install Node dependencies
npm install

# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure database in .env file
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=bbihub
# DB_USERNAME=root
# DB_PASSWORD=your_password

# Run migrations and seeders
php artisan migrate --seed

# Link storage
php artisan storage:link

# Build frontend assets
npm run build
```

#### 3. Setup Mobile (Flutter)

```bash
cd ../mobile

# Get Flutter dependencies
flutter pub get

# Generate launcher icons (optional)
flutter pub run flutter_launcher_icons

# Run the app (development)
flutter run

# Or build for specific platform
flutter build apk          # Android
flutter build ios          # iOS (macOS only)
flutter build web          # Web
```

### 🔥 Running Development Servers

#### Backend (3 terminals required)
```bash
# Terminal 1 - Laravel Server
cd backend
php artisan serve
# Access: http://localhost:8000

# Terminal 2 - Queue Worker
cd backend
php artisan queue:listen --tries=1

# Terminal 3 - Vite Dev Server
cd backend
npm run dev
```

**Or use composer script (single terminal):**
```bash
cd backend
composer run dev
```

#### Mobile
```bash
cd mobile
flutter run
# Select device when prompted
```

### 🔑 Default Credentials

**Web Dashboard:**
- **URL**: `http://localhost:8000`
- **Email**: `superadmin@gmail.com`
- **Password**: `password`

**Mobile App:**
- Use seeded owner/workshop credentials
- Check `backend/database/seeders/UserSeeder.php` for details

## 📁 Struktur Monorepo

```
bbihub-platform/
├── backend/                          # Laravel Backend + Web Dashboard
│   ├── app/
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   │   ├── Api/             # RESTful API Controllers
│   │   │   │   └── Web/             # Web Controllers (if any)
│   │   │   ├── Middleware/          # Custom middleware
│   │   │   └── Requests/            # Form request validation
│   │   ├── Livewire/                # Livewire Volt components
│   │   ├── Models/                  # Eloquent models
│   │   ├── Services/                # Business logic services
│   │   └── Providers/               # Service providers
│   ├── database/
│   │   ├── factories/               # Model factories
│   │   ├── migrations/              # Database migrations
│   │   └── seeders/                 # Database seeders
│   ├── resources/
│   │   ├── views/
│   │   │   ├── livewire/            # Livewire Volt pages
│   │   │   ├── layouts/             # Blade layouts
│   │   │   └── errors/              # Custom error pages
│   │   └── css/                     # Stylesheets
│   ├── routes/
│   │   ├── api.php                  # API routes
│   │   ├── web.php                  # Web routes
│   │   └── auth.php                 # Auth routes
│   ├── tests/                       # PHPUnit/Pest tests
│   ├── .env.example
│   ├── composer.json
│   └── package.json
│
├── mobile/                           # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/                  # Data models
│   │   ├── providers/               # Provider state management
│   │   ├── screens/                 # App screens/pages
│   │   ├── services/                # API services
│   │   ├── widgets/                 # Reusable widgets
│   │   └── utils/                   # Utilities & helpers
│   ├── assets/                      # Images, icons, fonts
│   ├── android/                     # Android native code
│   ├── ios/                         # iOS native code
│   ├── test/                        # Widget & unit tests
│   ├── pubspec.yaml                 # Flutter dependencies
│   └── README.md
│
├── postman/                          # API testing collections
│   └── BBIHUB_API.postman_collection.json
│
├── .gitignore                        # Monorepo gitignore
├── README.md                         # This file
└── LICENSE
```

## 🔌 API Documentation

### Base URL
```
Development: http://localhost:8000/api
Production:  https://api.bbihub.com/api
```

### Authentication
Semua endpoint API (kecuali auth) memerlukan Bearer token:
```http
Authorization: Bearer {your_token_here}
```

### Quick API Reference

#### Authentication
```http
POST   /api/auth/register       # Register new user
POST   /api/auth/login          # Login & get token
POST   /api/auth/logout         # Logout & revoke token
GET    /api/auth/me             # Get authenticated user
```

#### Workshops
```http
GET    /api/workshops           # List workshops
POST   /api/workshops           # Create workshop
GET    /api/workshops/{uuid}    # Get workshop details
PUT    /api/workshops/{uuid}    # Update workshop
DELETE /api/workshops/{uuid}    # Delete workshop
```

#### Services
```http
GET    /api/services            # List services
POST   /api/services            # Create service
GET    /api/services/{uuid}     # Get service details
PUT    /api/services/{uuid}     # Update service
DELETE /api/services/{uuid}     # Delete service
```

#### Transactions
```http
GET    /api/transactions        # List transactions
POST   /api/transactions        # Create transaction
GET    /api/transactions/{uuid} # Get transaction details
```

#### Dashboard
```http
GET    /api/dashboard/stats     # Get dashboard statistics
GET    /api/dashboard/revenue   # Get revenue data
GET    /api/dashboard/services  # Get service statistics
```

**Untuk dokumentasi lengkap**, import Postman collection dari folder `postman/`

## 🧪 Testing

### Backend Testing
```bash
cd backend

# Run all tests
php artisan test

# Run specific test suite
php artisan test --testsuite=Feature
php artisan test --testsuite=Unit

# Run with coverage
php artisan test --coverage

# Run specific test file
php artisan test tests/Feature/Api/AuthTest.php
```

### Mobile Testing
```bash
cd mobile

# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

## 🎨 Design System

### Color Palette
```
Primary Red:      #DC2626
Primary Hover:    #B91C1C
Dark Gray:        #1F2937
Light Gray:       #F9FAFB
Success Green:    #10B981
Warning Yellow:   #F59E0B
Danger Red:       #EF4444
```

### Typography
- **Primary Font**: Poppins (Regular, Medium, SemiBold, Bold)
- **Accent Font**: Fredoka (for headings & error codes)

## 🚢 Deployment

### Backend Deployment

**Requirements:**
- VPS/Cloud server (AWS, DigitalOcean, etc.)
- PHP 8.2+, MySQL 8.0+, Nginx/Apache
- SSL Certificate (Let's Encrypt)

**Steps:**
1. Clone repository ke server
2. Install dependencies: `composer install --no-dev`
3. Setup `.env` untuk production
4. Run migrations: `php artisan migrate --force`
5. Build assets: `npm run build`
6. Setup queue worker (Supervisor)
7. Setup cron jobs untuk Laravel scheduler

### Mobile Deployment

**Android (Google Play):**
```bash
cd mobile
flutter build appbundle --release
# Upload to Google Play Console
```

**iOS (App Store):**
```bash
cd mobile
flutter build ipa --release
# Upload via Xcode or Transporter
```

## 🤝 Kontribusi

Kami sangat terbuka untuk kontribusi! Ikuti langkah berikut:

1. **Fork** repository ini
2. Buat **feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Commit** perubahan (`git commit -m 'Add some AmazingFeature'`)
4. **Push** ke branch (`git push origin feature/AmazingFeature`)
5. Buat **Pull Request**

### Coding Standards

**Backend (Laravel):**
- Follow **PSR-12** coding standards
- Use Laravel best practices
- Write tests untuk fitur baru
- Run `composer run pint` sebelum commit

**Mobile (Flutter):**
- Follow **Dart style guide**
- Use meaningful widget/class names
- Write widget tests untuk UI components
- Run `flutter analyze` sebelum commit

### Branch Strategy
```
main        -> Production-ready code
develop     -> Development branch (default)
feature/*   -> Feature branches
bugfix/*    -> Bug fix branches
hotfix/*    -> Urgent production fixes
```

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

## 👥 Tim Pengembang

**BBIHUB Development Team**
- Lead Developer: [Your Name]
- Backend Developer: [Name]
- Mobile Developer: [Name]
- UI/UX Designer: [Name]

## 📞 Support & Contact

- **🐛 Bug Reports**: [GitHub Issues](https://github.com/siberbot88/bbihub-platform/issues)
- **💡 Feature Requests**: [GitHub Discussions](https://github.com/siberbot88/bbihub-platform/discussions)
- **📧 Email**: support@bbihub.com
- **📚 Documentation**: [Wiki](https://github.com/siberbot88/bbihub-platform/wiki)

## 🙏 Acknowledgments

- Laravel Framework & Community
- Flutter Team & Community
- Spatie Packages
- Midtrans Payment Gateway
- All open-source contributors

---

<div align="center">

**Built with ❤️ in Indonesia**

© 2025 BBIHUB Development Team. All rights reserved.

⭐ Star this repo if you find it helpful!

</div>
