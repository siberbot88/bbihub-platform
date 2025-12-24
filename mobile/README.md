# 🚗 BBI Hub Mobile App

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A comprehensive mobile application for **BBI Hub** (Bengkel Bisa Indonesia Hub), designed to streamline workshop management operations. This app provides role-based interfaces for Workshop Owners, Admins, and Mechanics to manage services, customers, employees, analytics, and more.

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Architecture](#-architecture)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Configuration](#-configuration)
- [User Roles](#-user-roles)
- [Screenshots](#-screenshots)
- [Contributing](#-contributing)

---

## ✨ Features

### 🔐 Authentication & Authorization
- **Secure Login/Logout** with JWT token-based authentication
- **Role-based Access Control** (Owner, Admin, Mechanic)
- **Password Management** with first-time login flow
- **Secure Token Storage** using FlutterSecureStorage

### 👔 Owner Features
- **Dashboard Analytics**
  - Real-time revenue, jobs, and occupancy metrics
  - Service breakdown by category
  - Peak hours analysis with hourly distribution
  - Growth trends (vs previous period)
  - Operational health indicators
- **Staff Management**
  - Employee CRUD operations
  - Staff performance tracking
  - Role assignment
- **Service Management**
  - Create, view, update, delete services
  - Service status tracking (pending, in progress, completed, cancelled)
  - Filter by status and date range
- **Report Generation**
  - Interactive charts (line, bar) for analytics visualization
  - PDF export for reports
  - Multiple time ranges (daily, weekly, monthly)
  - Empty state handling for new workshops
- **Premium Membership**
  - Subscription management
  - Payment integration (Midtrans)
  - Membership status tracking
  - Auto-renewal handling

### 👨‍💼 Admin Features
- **Employee Management** (view, create, update, delete)
- **Service Oversight** (view all services, update status)
- **Staff Performance Dashboard**
  - Individual employee metrics
  - Performance comparison
  - Efficiency tracking

### 🔧 Mechanic Features
- **Service Queue** (view assigned services)
- **Service Status Updates** (mark as in progress, completed)
- **Customer Communication**

### 🛠️ General Features
- **Offline Support** with connectivity detection
- **Pull-to-Refresh** for real-time data sync
- **Image Picker** for profile photos and service images
- **WebView Integration** for payment processing
- **Deep Linking** for payment callbacks
- **Custom Theming** with Poppins font family

---

## 🛠️ Tech Stack

### **Framework & Language**
- **Flutter** 3.0+ - Cross-platform mobile framework
- **Dart** 3.0+ - Programming language

### **State Management**
- **Provider** 6.1.2 - Lightweight and scalable state management

### **UI & Design**
- **Material Design 3** - Modern UI components
- **Google Fonts** (Poppins) - Custom typography
- **FL Chart** 0.68.0 - Beautiful interactive charts
- **Syncfusion Charts** 31.2.3 - Advanced chart visualizations
- **Syncfusion DatePicker** - Date range selection

### **Backend Communication**
- **HTTP** 1.5.0 - RESTful API integration
- **JSON Serialization** - Manual parsing with type safety

### **Security & Storage**
- **Flutter Secure Storage** 9.2.2 - Encrypted key-value storage
- **Shared Preferences** 2.0.0 - Non-sensitive local storage

### **Media & Files**
- **Image Picker** 1.2.0 - Camera and gallery access
- **PDF** 3.10.8 - PDF generation
- **Printing** 5.12.0 - PDF export and sharing
- **Path Provider** 2.1.2 - File system paths

### **Navigation & Linking**
- **App Links** 5.0.0 - Deep linking support
- **URL Launcher** 6.3.2 - External URLs
- **WebView Flutter** 4.13.0 - In-app browser

### **Utilities**
- **Connectivity Plus** 6.0.5 - Network status monitoring
- **Intl** 0.19.0 - Internationalization and date formatting

---

## 🏗️ Architecture

The app follows a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI Screens, Widgets, ViewModels)      │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│          Business Logic Layer           │
│     (Providers, State Management)       │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│         Data Access Layer               │
│   (Repositories, API Services)          │
└────────────────┬────────────────────────┘
                 │
┌────────────────▼────────────────────────┐
│          External Services              │
│    (REST API, Storage, Payment)         │
└─────────────────────────────────────────┘
```

### **Key Architectural Principles**

1. **Provider Pattern** - Centralized state management with `ChangeNotifier`
2. **Repository Pattern** - Abstraction layer for data sources
3. **Service Layer** - API communication and business logic
4. **Model-View-ViewModel** - Clean separation of UI and business logic

### **Data Flow**

```
User Action → UI Widget → Provider → Repository → API Service → Backend
                ↑                                                    │
                └──────────── Response ← Parse JSON ←───────────────┘
```

---

## 📁 Project Structure

```
mobile/
├── lib/
│   ├── core/                        # Core functionality
│   │   ├── models/                  # Data models
│   │   │   ├── user.dart
│   │   │   ├── service.dart
│   │   │   ├── employment.dart
│   │   │   └── ...
│   │   ├── providers/               # State management
│   │   │   ├── service_provider.dart
│   │   │   └── ...
│   │   ├── repositories/            # Data access layer
│   │   │   ├── analytics_repository.dart
│   │   │   └── ...
│   │   └── services/                # Business logic services
│   │       ├── api_service.dart
│   │       ├── auth_provider.dart
│   │       └── report_pdf_service.dart
│   │
│   ├── feature/                     # Feature modules (legacy structure)
│   │   ├── admin/
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   ├── owner/
│   │   │   ├── screens/
│   │   │   │   ├── homepage_owner.dart
│   │   │   │   ├── report_pages.dart
│   │   │   │   ├── staff_management.dart
│   │   │   │   └── ...
│   │   │   └── widgets/
│   │   │       ├── dashboard/
│   │   │       ├── report/
│   │   │       └── staff/
│   │   └── mechanic/
│   │
│   ├── features/                    # Feature modules (new structure)
│   │   └── membership/
│   │       └── presentation/
│   │           ├── premium_membership_screen.dart
│   │           ├── payment_screen.dart
│   │           └── webview_payment_screen.dart
│   │
│   ├── theme/                       # App theming
│   │   └── app_theme.dart
│   │
│   └── main.dart                    # App entry point
│
├── assets/                          # Static assets
│   ├── fonts/                       # Custom fonts (Poppins)
│   ├── icons/                       # App icons
│   ├── image/                       # Images
│   └── svg/                         # SVG assets
│
├── android/                         # Android-specific code
├── ios/                             # iOS-specific code
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

### **Feature Organization**

Each feature module contains:
- **screens/** - Full-page UI components
- **widgets/** - Reusable UI components specific to the feature
- **models/** (optional) - Feature-specific data models

---

## 🚀 Getting Started

### **Prerequisites**

- Flutter SDK 3.0 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode (for emulators)
- Android SDK (API level 21+) / iOS 12.0+

### **Installation**

1. **Clone the repository**
   ```bash
   cd mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation (if needed)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure backend API**
   
   Update `lib/core/services/api_service.dart`:
   ```dart
   static const String baseUrl = 'http://your-backend-url:8000/api/v1';
   ```

5. **Run the app**
   ```bash
   # List available devices
   flutter devices
   
   # Run on specific device
   flutter run -d <device-id>
   
   # Run in release mode
   flutter run --release
   ```

---

## ⚙️ Configuration

### **Environment Variables**

The app connects to the backend API. Configure the base URL in:

**`lib/core/services/api_service.dart`**
```dart
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8000/api/v1'; // iOS Simulator
  // static const String baseUrl = 'https://api.bbihub.com/api/v1'; // Production
  
  // ... rest of the code
}
```

### **Deep Linking Setup**

For payment callbacks, configure deep linking:

**Android (`android/app/src/main/AndroidManifest.xml`)**
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="bbihub"
        android:host="payment" />
</intent-filter>
```

**iOS (`ios/Runner/Info.plist`)**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>bbihub</string>
        </array>
    </dict>
</array>
```

### **Debugging**

Enable debug mode for API logging in `api_service.dart`:
```dart
if (kDebugMode) {
  print('[API_REQUEST] $method $url');
  print('[API_RESPONSE] Status: ${response.statusCode}');
}
```

---

## 👥 User Roles

### **Owner Role**
- Full access to all features
- Dashboard with analytics
- Staff and service management
- Report generation and export
- Premium membership management

### **Admin Role**
- Employee management (CRUD)
- Service oversight
- Staff performance tracking
- Cannot modify owner settings

### **Mechanic Role**
- View assigned services
- Update service status
- Limited to operational tasks

### **Role-Based Navigation**

```dart
// Example: route to appropriate homepage based on role
Widget getHomeScreen(String role) {
  switch (role) {
    case 'owner':
      return DashboardScreen(); // Owner dashboard
    case 'admin':
      return AdminHomeScreen(); // Admin dashboard
    case 'mechanic':
      return MechanicHomeScreen(); // Mechanic tasks
    default:
      return LoginScreen();
  }
}
```

---

## 📸 Screenshots

### Owner Dashboard
![Dashboard](docs/screenshots/dashboard.png)
*Real-time analytics with revenue, jobs, and occupancy metrics*

### Analytics Report
![Analytics](docs/screenshots/analytics.png)
*Interactive charts with line graphs and peak hour visualization*

### Staff Management
![Staff](docs/screenshots/staff_management.png)
*Employee management with performance tracking*

### Premium Membership
![Membership](docs/screenshots/membership.png)
*Subscription management with Midtrans payment integration*

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### **Code Style**

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` to check for issues
- Run `flutter format .` before committing
- Write meaningful commit messages

### **Testing**

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📞 Support

For support, email support@bbihub.com or create an issue in the repository.

---

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **Syncfusion** - For beautiful chart libraries
- **Midtrans** - For payment gateway integration
- **BBI Hub Team** - For continuous support and feedback

---

**Built with ❤️ by BBI Hub Development Team**
