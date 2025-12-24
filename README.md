# BBIHUB Platform

**Modern Workshop Management Ecosystem**

A comprehensive platform for automotive workshop management, consisting of web-based administrative dashboard and mobile application for workshop owners.

[![Laravel](https://img.shields.io/badge/Laravel-12.x-FF2D20?style=flat-square&logo=laravel&logoColor=white)](https://laravel.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![PHP](https://img.shields.io/badge/PHP-8.2+-777BB4?style=flat-square&logo=php&logoColor=white)](https://php.net)
[![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=flat-square&logo=mysql&logoColor=white)](https://www.mysql.com)

---

## Table of Contents

- [Introduction](#introduction)
- [System Architecture](#system-architecture)
- [Application Flow](#application-flow)
- [Platform Components](#platform-components)
  - [Web Dashboard](#web-dashboard)
  - [Mobile Application](#mobile-application)
- [Core Features](#core-features)
- [Technology Stack](#technology-stack)
- [Security Implementation](#security-implementation)
- [Installation Guide](#installation-guide)
- [API Documentation](#api-documentation)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

---

## Introduction

### Overview

BBIHUB is an enterprise-grade workshop management platform designed to digitalize and streamline automotive workshop operations in Indonesia. The platform addresses common challenges in traditional workshop management by providing integrated solutions for service tracking, transaction management, employee performance monitoring, and customer relationship management.

### Problem Statement

Traditional automotive workshops face several operational challenges:
- Manual service and transaction recording leading to data inconsistency
- Lack of real-time business insights and analytics
- Inefficient employee task management and performance tracking
- Limited customer engagement and retention strategies
- Absence of integrated payment and membership systems
- Difficulty in managing multi-workshop operations

### Solution

BBIHUB provides a comprehensive ecosystem that includes:
- **Web Dashboard**: Centralized administrative panel for superadmin and workshop management
- **Mobile Application**: On-the-go management tools for workshop owners
- **REST API**: Robust backend infrastructure for seamless data synchronization
- **Payment Integration**: Automated billing and payment processing via Midtrans
- **AI Chatbot**: Intelligent customer service automation

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Client Layer                             │
├──────────────────────┬──────────────────────────────────────┤
│   Web Dashboard      │      Mobile Application              │
│   (Livewire + Blade) │      (Flutter)                       │
└──────────┬───────────┴──────────────┬───────────────────────┘
           │                          │
           │      HTTPS/REST API      │
           │                          │
┌──────────▼──────────────────────────▼───────────────────────┐
│              Application Layer (Laravel 12)                  │
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
│                   Data Layer                                 │
├──────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   MySQL DB   │  │  File Storage│  │   Cache (Redis)  │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└──────────────────────────────────────────────────────────────┘
           │
┌──────────▼──────────────────────────────────────────────────┐
│                External Services                             │
├──────────────────────────────────────────────────────────────┤
│  Midtrans Payment │  Sentry Monitoring  │  Pusher Realtime  │
└──────────────────────────────────────────────────────────────┘
```

### Architecture Patterns

**Backend Architecture:**
- **MVC Pattern**: Model-View-Controller for web dashboard
- **Repository Pattern**: Data access abstraction layer
- **Service Layer Pattern**: Business logic separation
- **Event-Driven Architecture**: Asynchronous task processing with queues

**Mobile Architecture:**
- **Provider Pattern**: State management
- **Repository Pattern**: API data abstraction
- **Clean Architecture**: Separation of concerns (partially implemented)

### Data Flow

1. **Authentication Flow:**
   ```
   Client Request → Middleware (Sanctum) → Controller → Service → Model → Database
   ```

2. **API Request Flow:**
   ```
   Mobile App → HTTP Client → API Endpoint → Validation → Business Logic → Response
   ```

3. **Transaction Processing:**
   ```
   User Action → Controller → Service → Payment Gateway → Database Update → Event Dispatch → Queue Worker
   ```

---

## Application Flow

### User Journey - Workshop Owner

#### 1. Registration & Onboarding
```
Registration → Email Verification → Workshop Creation → Trial Membership Setup → Dashboard Access
```

#### 2. Service Management
```
Define Services → Set Pricing → Assign Categories → Activate Services → Monitor Analytics
```

#### 3. Transaction Processing
```
Customer Arrival → Service Selection → Invoice Generation → Payment Processing → Service Completion → Customer Notification
```

#### 4. Employee Management
```
Add Employee → Assign Roles → Define Specializations → Assign Tasks → Track Performance
```

#### 5. Membership & Payment
```
Free Trial (7 days) → Payment Setup (Midtrans) → Auto-charge → Active Membership → Auto-renewal
```

### User Journey - Superadmin

#### 1. System Administration
```
Login → Dashboard Overview → User Management → Workshop Approval → System Configuration
```

#### 2. Monitoring & Analytics
```
Platform Metrics → Revenue Reports → User Activity → Transaction Monitoring → System Health
```

### Mobile App User Flow

```
App Launch
    ↓
Authentication Check
    ↓
┌───Login Required───┐       ┌───Authenticated───┐
│                    │       │                   │
│ Login Screen       │────→  │  Dashboard        │
│ Registration       │       │                   │
└────────────────────┘       └─────────┬─────────┘
                                       │
                   ┌───────────────────┼───────────────────┐
                   ↓                   ↓                   ↓
            ┌──────────┐        ┌──────────┐       ┌──────────┐
            │ Services │        │ Orders   │       │ Vehicles │
            └──────────┘        └──────────┘       └──────────┘
                   ↓                   ↓                   ↓
            ┌──────────┐        ┌──────────┐       ┌──────────┐
            │ Add/Edit │        │ Process  │       │ Add/View │
            └──────────┘        │ Payment  │       └──────────┘
                                └──────────┘
```

---

## Platform Components

### Web Dashboard

The web dashboard serves as the primary administrative interface for superadmin and workshop management.

#### Target Users
- **Superadmin**: Platform administrators with full system access
- **Workshop Managers**: Workshop staff with limited administrative capabilities

#### Key Modules

**1. Dashboard Overview**
- Real-time business metrics (KPI cards)
- Revenue analytics with charts
- Service statistics
- Employee performance summary
- Recent transactions and notifications

**2. Workshop Management**
- Workshop profile configuration
- Operating hours settings
- Location and contact management
- Branding customization (logo, colors)
- Multi-workshop support

**3. Service Management**
- Service catalog creation and editing
- Category-based organization (Engine, Body, Electrical, Transmission, AC, Tire, etc.)
- Dynamic pricing configuration
- Service activation/deactivation
- Service history tracking

**4. Transaction Management**
- Invoice generation and management
- Payment status tracking
- Transaction history
- Refund processing
- Financial reports

**5. User & Role Management**
- User account creation
- Role-based access control (RBAC)
- Permission management via Spatie Permission
- Employee profile management

**6. Vehicle & Customer Management**
- Customer database
- Vehicle registration
- Service history per vehicle
- Customer engagement tracking

**7. Membership & Voucher System**
- Membership tier configuration (Basic, Silver, Gold, Platinum)
- Trial management
- Voucher creation and distribution
- Discount rule configuration

**8. Analytics & Reporting**
- Revenue reports (daily, weekly, monthly, yearly)
- Service popularity analysis
- Employee performance metrics
- Customer behavior analytics
- Export capabilities (PDF, Excel)

#### Technical Implementation

**Frontend Stack:**
- **Livewire Volt**: Reactive single-file components for dynamic interfaces
- **Tailwind CSS**: Utility-first styling with custom design system
- **Alpine.js**: Lightweight JavaScript for interactive behaviors
- **Chart.js/ApexCharts**: Data visualization

**Design System:**
- **Typography**: Poppins (primary), Fredoka (accents)
- **Color Scheme**: Red primary (#DC2626), Dark gray (#1F2937), Tailwind palette
- **Components**: Custom reusable Livewire components
- **Responsive**: Mobile-first approach with breakpoint optimization

### Mobile Application

Native-quality mobile application built with Flutter for workshop owners and managers.

#### Target Users
- **Workshop Owners**: Business owners managing one or multiple workshops
- **Workshop Managers**: Authorized staff with management permissions

#### Key Features

**1. Authentication & Security**
- Secure login with token-based authentication (Laravel Sanctum)
- Biometric authentication support
- Auto-logout on inactivity
- Secure credential storage via Flutter Secure Storage

**2. Dashboard**
- Mini dashboard with critical KPIs
- Revenue overview
- Pending services count
- Employee performance summary
- Quick action buttons
- Real-time data synchronization

**3. Service Management**
- Browse service catalog
- Add/edit services
- Update service pricing
- View service statistics
- Service queue management

**4. Order & Transaction Processing**
- Walk-in service registration
- Appointment scheduling
- Invoice generation
- Payment processing with Midtrans WebView
- Transaction history
- PDF invoice download

**5. Vehicle Management**
- Vehicle registration
- Customer vehicle database
- Service history per vehicle
- Odometer tracking
- Vehicle photo management

**6. Employee Management**
- Employee directory
- Specialist assignment
- Task delegation
- Performance tracking
- Attendance overview (future)

**7. Membership Management**
- View membership status
- Trial activation
- Payment via Midtrans
- Membership history
- Auto-renewal settings

**8. Customer Interaction**
- AI-powered chatbot
- Live chat with admin
- Quick FAQ responses
- Chat history

**9. Notifications**
- Push notifications for important events
- Deep linking to relevant screens
- Notification history
- Notification preferences

**10. Offline Support**
- Local data persistence with SharedPreferences
- Offline mode for critical features
- Data synchronization on network restore

#### Technical Implementation

**Architecture:**
- **State Management**: Provider pattern for reactive state
- **Navigation**: Flutter Navigator 2.0
- **API Layer**: HTTP client with interceptors for authentication
- **Local Storage**: SharedPreferences (app data), Flutter Secure Storage (tokens)
- **Image Handling**: Image picker with compression

**UI/UX:**
- **Material Design 3**: Modern Material components
- **Custom Theme**: Consistent with brand guidelines
- **Responsive Layouts**: Adaptive to various screen sizes
- **Animations**: Smooth transitions and micro-interactions

---

## Core Features

### Authentication & Authorization

**Web Dashboard:**
- Superadmin-only access for web interface
- Multi-factor authentication support (future)
- Session management with secure cookies
- CSRF protection

**Mobile Application:**
- Email and password authentication
- Token-based authentication via Laravel Sanctum
- Biometric authentication (fingerprint/face ID)
- Auto token refresh mechanism
- Secure token storage

**Role-Based Access Control:**
- Spatie Laravel Permission integration
- Granular permission system
- Role hierarchy: Superadmin > Workshop Owner > Manager > Technician
- Dynamic permission assignment

### Service Management

**Service Catalog:**
- Hierarchical categorization
- Custom service creation
- Price configuration per workshop
- Service duration estimation
- Required employee specialization

**Service Queue:**
- Walk-in service registration
- Appointment scheduling
- Queue prioritization
- Real-time status updates
- Service completion tracking

**Service Categories:**
- Engine Services
- Body & Paint
- Electrical Systems
- Transmission
- Air Conditioning
- Tire Services
- General Maintenance

### Transaction & Payment

**Invoice Management:**
- Automated invoice generation
- Itemized billing
- Tax calculation
- Discount application
- Multi-currency support (future)

**Payment Processing:**
- Midtrans payment gateway integration
- Multiple payment methods (credit card, e-wallet, bank transfer)
- Real-time payment status updates
- Webhook handling for payment notifications
- Automatic receipt generation

**Payment Flow:**
```
Service Selection → Invoice Creation → Payment Gateway (Midtrans) → Payment Confirmation → 
Receipt Generation → Service Activation
```

### Membership System

**Membership Tiers:**
1. **Basic** (Free Trial)
   - 7-day trial period
   - Limited features
   - Single workshop

2. **Silver**
   - Standard features
   - Up to 2 workshops
   - Basic analytics

3. **Gold**
   - Advanced features
   - Up to 5 workshops
   - Advanced analytics
   - Priority support

4. **Platinum**
   - All features
   - Unlimited workshops
   - Custom branding
   - Dedicated support

**Trial & Subscription Flow:**
```
Registration → Free Trial (7 days) → Payment Setup (Rp 0 transaction) → 
Auto-charge after trial → Active Subscription → Monthly Auto-renewal
```

### Voucher System

**Voucher Types:**
- Percentage discount (e.g., 10% off)
- Fixed amount discount (e.g., Rp 50,000 off)
- Service-specific vouchers
- First-time customer vouchers

**Voucher Management:**
- Creation with expiry dates
- Usage limit configuration
- Automatic expiry handling
- Usage tracking and analytics

### Employee Management

**Employee Profiles:**
- Personal information
- Specialization tags (Engine Specialist, Body Specialist, etc.)
- Contact details
- Employment status

**Task Assignment:**
- Service-based task allocation
- Workload balancing
- Real-time task status
- Completion tracking

**Performance Tracking:**
- Completed services count
- Customer ratings
- Average service time
- Revenue contribution

### Vehicle & Customer Management

**Customer Database:**
- Customer profiles
- Contact information
- Service history
- Vehicle ownership

**Vehicle Management:**
- Vehicle registration (license plate, make, model, year)
- Odometer tracking
- Service history
- Sparepart usage history
- Vehicle photos

### Analytics & Reporting

**Business Intelligence:**
- Revenue tracking (daily, weekly, monthly, yearly)
- Service popularity analysis
- Customer retention metrics
- Employee performance benchmarking
- Workshop comparison (multi-workshop owners)

**Export Capabilities:**
- PDF reports
- Excel spreadsheets
- Custom date ranges
- Scheduled reports (future)

### AI Chatbot

**Capabilities:**
- Natural language processing
- FAQ automation
- Service inquiry handling
- Appointment booking assistance
- Escalation to human agents

**Integration:**
- Real-time chat interface
- Chat history persistence
- Multi-language support (future)

---

## Technology Stack

### Backend Technologies

**Core Framework:**
- **Laravel 12.x**: Modern PHP framework with latest features
- **PHP 8.2+**: Type-safe, modern PHP

**Database:**
- **MySQL 8.0+**: Relational database for structured data
- **Redis**: Caching and session management (optional)

**Authentication & Authorization:**
- **Laravel Sanctum**: API token authentication
- **Spatie Laravel Permission**: Role and permission management

**Real-time & Queue:**
- **Laravel Queue**: Asynchronous job processing
- **Laravel Reverb**: Real-time event broadcasting
- **Pusher**: Alternative real-time service

**Payment Integration:**
- **Midtrans**: Indonesian payment gateway

**Monitoring & Analytics:**
- **Sentry**: Error tracking and performance monitoring
- **Laravel Telescope**: Development debugging tool

**Key Packages:**
```json
{
  "laravel/sanctum": "API authentication",
  "spatie/laravel-permission": "RBAC implementation",
  "spatie/laravel-activitylog": "Audit logging",
  "spatie/laravel-query-builder": "Advanced API filtering",
  "midtrans/midtrans-php": "Payment gateway SDK",
  "sentry/sentry-laravel": "Error monitoring",
  "dedoc/scramble": "API documentation generator",
  "livewire/livewire": "Reactive components",
  "livewire/volt": "Single-file components"
}
```

**Development Tools:**
```json
{
  "pestphp/pest": "Modern testing framework",
  "laravel/pint": "Code style fixer (PSR-12)",
  "barryvdh/laravel-debugbar": "Development debugging",
  "barryvdh/laravel-ide-helper": "IDE autocomplete"
}
```

### Frontend Technologies (Web Dashboard)

**UI Framework:**
- **Livewire Volt 3.x**: Reactive single-file components
- **Blade**: Template engine
- **Alpine.js**: Lightweight JavaScript framework

**Styling:**
- **Tailwind CSS 3.x**: Utility-first CSS framework
- **Custom Design System**: Brand-specific styles

**Build Tools:**
- **Vite**: Next-generation frontend build tool
- **PostCSS**: CSS processing

**Assets:**
- **Google Fonts**: Poppins, Fredoka typography
- **Heroicons**: Icon library

### Mobile Technologies

**Framework:**
- **Flutter 3.0+**: Cross-platform mobile framework
- **Dart 3.0+**: Programming language

**State Management:**
- **Provider**: Reactive state management

**Networking:**
- **http**: HTTP client for API calls
- **connectivity_plus**: Network status monitoring

**Storage:**
- **flutter_secure_storage**: Encrypted credential storage
- **shared_preferences**: Key-value local storage

**UI Components:**
- **Material Design 3**: Modern UI components
- **google_fonts**: Custom typography
- **flutter_svg**: SVG asset rendering

**Charts & Visualization:**
- **fl_chart**: Lightweight charts
- **syncfusion_flutter_charts**: Advanced charts
- **syncfusion_flutter_datepicker**: Date selection

**Utilities:**
- **intl**: Internationalization and formatting
- **image_picker**: Camera and gallery access
- **url_launcher**: External URL handling
- **webview_flutter**: In-app browser (Midtrans payment)
- **app_links**: Deep linking
- **pdf & printing**: PDF generation and printing

**Testing:**
- **flutter_test**: Widget and unit testing
- **flutter_driver**: Integration testing (future)

### Infrastructure

**Version Control:**
- **Git**: Source control
- **Monorepo Structure**: Unified codebase management

**API Testing:**
- **Postman**: API collection and testing

**Deployment:**
- **Backend**: VPS (DigitalOcean, AWS, etc.), Nginx/Apache, PHP-FPM
- **Mobile**: Google Play Store, Apple App Store

**CI/CD (Planned):**
- **GitHub Actions**: Automated testing and deployment
- **Laravel Forge**: Server management (optional)

---

## Security Implementation

### Authentication Security

**Token-Based Authentication:**
- Laravel Sanctum for stateless API authentication
- Token expiration and rotation
- Secure token storage in mobile app (Flutter Secure Storage with AES encryption)
- HTTPOnly cookies for web sessions

**Password Security:**
- Bcrypt hashing algorithm (cost factor 10)
- Minimum password length enforcement
- Password complexity requirements
- Password reset with time-limited tokens
- Account lockout after failed attempts (future)

**Session Security:**
- CSRF token protection for web forms
- Secure session cookies (HTTP-only, Secure flag)
- Session timeout and automatic logout
- Concurrent session management

### Authorization Security

**Role-Based Access Control (RBAC):**
- Spatie Permission package for granular permissions
- Role hierarchy enforcement
- Permission caching for performance
- Dynamic permission checking at route and action level

**API Authorization:**
- Middleware-based authorization
- Resource-level permission checks
- Owner-based access control (users can only access their own data)
- Admin override capabilities with audit logging

### Data Security

**Data Encryption:**
- Database column encryption for sensitive data (future enhancement)
- HTTPS/TLS for all data in transit
- Encrypted storage for authentication tokens

**Database Security:**
- Parameterized queries (Eloquent ORM) preventing SQL injection
- Database user with minimal required privileges
- No direct database exposure to public network
- Regular database backups with encryption

**Input Validation:**
- Form Request validation for all user inputs
- XSS prevention through Laravel's automatic escaping
- File upload validation (type, size, extension whitelist)
- API request validation with custom rules

**Output Sanitization:**
- Blade template automatic escaping
- JSON response sanitization
- HTML Purifier for rich text content (where applicable)

### Application Security

**Middleware Protection:**
- Authentication middleware for protected routes
- Rate limiting to prevent brute force attacks
- CORS configuration for API access control
- Request throttling by IP and user

**API Security:**
- API versioning for backward compatibility
- Request signing (planned)
- API key rotation capability
- Webhook signature verification (Midtrans)

**File Upload Security:**
- Mime type validation
- File size limits
- Virus scanning (planned)
- Secure file storage outside public directory
- Unique filename generation

### Payment Security

**Midtrans Integration:**
- Server-side validation of payment notifications
- Webhook signature verification
- Idempotency checks to prevent double processing
- PCI DSS compliance through Midtrans

**Transaction Security:**
- Database transactions for atomicity
- Duplicate transaction prevention
- Fraud detection hooks (future)
- Transaction audit logging

### Infrastructure Security

**Server Configuration:**
- Firewall configuration (UFW/iptables)
- SSH key-based authentication
- Fail2ban for intrusion prevention
- Regular security updates

**Environment Security:**
- Environment variables for sensitive configuration
- .env file excluded from version control
- Separate environments (development, staging, production)
- Environment-specific security settings

**Monitoring & Logging:**
- Sentry for error tracking and alerting
- Activity logging with Spatie Activity Log
- Authentication attempt logging
- Security event monitoring
- GDPR-compliant log retention

### Mobile Security

**App Security:**
- Certificate pinning for API communication (planned)
- Root detection and jailbreak detection (planned)
- Code obfuscation for release builds
- Secure local storage with encryption

**Network Security:**
- TLS 1.3 for all network communications
- Certificate validation
- Proxy detection (planned)
- VPN detection (planned)

### Compliance & Best Practices

**Security Standards:**
- OWASP Top 10 mitigation
- Laravel security best practices
- Regular security audits (planned)
- Dependency vulnerability scanning

**Data Privacy:**
- GDPR-ready architecture (user data export/deletion)
- Indonesian data privacy regulation compliance
- Clear privacy policy
- User consent management

**Audit Trail:**
- Comprehensive activity logging
- User action tracking
- Admin action logging
- Immutable audit logs

---

## Installation Guide

### Prerequisites

**Backend Requirements:**
```
PHP >= 8.2
Composer >= 2.0
Node.js >= 18.x
npm >= 9.x
MySQL >= 8.0
Git
```

**Mobile Requirements:**
```
Flutter SDK >= 3.0
Dart SDK >= 3.0
Android Studio (for Android development)
Xcode (for iOS development, macOS only)
```

### Backend Installation

#### 1. Clone Repository
```bash
git clone https://github.com/siberbot88/bbihub-platform.git
cd bbihub-platform/backend
```

#### 2. Install PHP Dependencies
```bash
composer install
```

#### 3. Install Node Dependencies
```bash
npm install
```

#### 4. Environment Configuration
```bash
cp .env.example .env
php artisan key:generate
```

#### 5. Database Configuration
Edit `.env` file:
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=bbihub
DB_USERNAME=root
DB_PASSWORD=your_secure_password
```

Create database:
```bash
mysql -u root -p
CREATE DATABASE bbihub CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

#### 6. Database Migration & Seeding
```bash
php artisan migrate --seed
```

#### 7. Storage Linking
```bash
php artisan storage:link
```

#### 8. Build Frontend Assets
```bash
npm run build
```

#### 9. Queue Configuration (Optional but Recommended)
Edit `.env`:
```env
QUEUE_CONNECTION=database
```

Run queue worker:
```bash
php artisan queue:table
php artisan migrate
```

### Mobile Installation

#### 1. Navigate to Mobile Directory
```bash
cd ../mobile
```

#### 2. Install Flutter Dependencies
```bash
flutter pub get
```

#### 3. Configure API Endpoint
Edit `lib/services/api_service.dart` or equivalent configuration file:
```dart
static const String baseUrl = 'http://your-backend-url.com/api';
```

#### 4. Generate App Icons (Optional)
```bash
flutter pub run flutter_launcher_icons
```

#### 5. Run Application
```bash
# For development
flutter run

# Select target device when prompted
```

### Development Server

#### Backend Development Server (3 options)

**Option 1: Single Command (Recommended)**
```bash
cd backend
composer run dev
```
This runs Laravel server, queue worker, and Vite dev server concurrently.

**Option 2: Manual (3 separate terminals)**

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

**Option 3: Laravel Sail (Docker)**
```bash
cd backend
./vendor/bin/sail up
```

#### Access Points

- Web Dashboard: `http://localhost:8000`
- API Endpoint: `http://localhost:8000/api`
- Default credentials: `superadmin@gmail.com` / `password`

### Mobile Development

```bash
cd mobile
flutter run

# For specific device
flutter devices
flutter run -d <device_id>

# For hot reload during development, press 'r' in terminal
# For hot restart, press 'R'
```

---

## API Documentation

### Base URL

```
Development: http://localhost:8000/api
Production: https://api.bbihub.com/api
```

### Authentication

All endpoints except authentication routes require Bearer token authentication.

**Header:**
```http
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

### Authentication Endpoints

#### Register
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
  "message": "Registration successful"
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
  "message": "Login successful"
}
```

#### Logout
```http
POST /api/auth/logout
Authorization: Bearer {token}

Response: 200 OK
{
  "message": "Logged out successfully"
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

### Core API Endpoints

#### Workshops
```http
GET    /api/workshops              # List all workshops
POST   /api/workshops              # Create workshop
GET    /api/workshops/{uuid}       # Get workshop details
PUT    /api/workshops/{uuid}       # Update workshop
DELETE /api/workshops/{uuid}       # Delete workshop
```

#### Services
```http
GET    /api/services               # List all services
POST   /api/services               # Create service
GET    /api/services/{uuid}        # Get service details
PUT    /api/services/{uuid}        # Update service
DELETE /api/services/{uuid}        # Delete service
GET    /api/services/categories    # Get service categories
```

#### Transactions
```http
GET    /api/transactions           # List transactions
POST   /api/transactions           # Create transaction
GET    /api/transactions/{uuid}    # Get transaction details
PUT    /api/transactions/{uuid}    # Update transaction status
POST   /api/transactions/{uuid}/pay # Process payment
```

#### Vehicles
```http
GET    /api/vehicles               # List vehicles
POST   /api/vehicles               # Register vehicle
GET    /api/vehicles/{uuid}        # Get vehicle details
PUT    /api/vehicles/{uuid}        # Update vehicle
DELETE /api/vehicles/{uuid}        # Delete vehicle
```

#### Employees
```http
GET    /api/employees              # List employees
POST   /api/employees              # Add employee
GET    /api/employees/{uuid}       # Get employee details
PUT    /api/employees/{uuid}       # Update employee
DELETE /api/employees/{uuid}       # Remove employee
GET    /api/employees/{uuid}/performance # Get performance metrics
```

#### Dashboard
```http
GET    /api/dashboard/stats        # Get dashboard statistics
GET    /api/dashboard/revenue      # Get revenue data
GET    /api/dashboard/services     # Get service statistics
GET    /api/dashboard/employees    # Get employee performance
```

#### Membership
```http
GET    /api/membership/status      # Get current membership
POST   /api/membership/trial       # Start free trial
POST   /api/membership/subscribe   # Subscribe to plan
GET    /api/membership/history     # Get subscription history
```

### Pagination

List endpoints support pagination:
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

### Error Responses

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email has already been taken."]
  }
}
```

### Postman Collection

Import the Postman collection from `postman/` directory for complete API documentation with examples.

---

## Project Structure

```
bbihub-platform/
├── backend/                          # Laravel Backend
│   ├── app/
│   │   ├── Console/                  # Artisan commands
│   │   ├── Exceptions/               # Exception handlers
│   │   ├── Http/
│   │   │   ├── Controllers/
│   │   │   │   ├── Api/             # RESTful API controllers
│   │   │   │   │   ├── AuthController.php
│   │   │   │   │   ├── WorkshopController.php
│   │   │   │   │   ├── ServiceController.php
│   │   │   │   │   ├── TransactionController.php
│   │   │   │   │   └── ...
│   │   │   │   └── Web/             # Web controllers (minimal)
│   │   │   ├── Middleware/          # Custom middleware
│   │   │   └── Requests/            # Form request validation
│   │   ├── Livewire/                # Livewire Volt components
│   │   │   ├── Auth/
│   │   │   ├── Dashboard/
│   │   │   ├── Workshops/
│   │   │   └── ...
│   │   ├── Models/                  # Eloquent models
│   │   │   ├── User.php
│   │   │   ├── Workshop.php
│   │   │   ├── Service.php
│   │   │   ├── Transaction.php
│   │   │   └── ...
│   │   ├── Providers/               # Service providers
│   │   └── Services/                # Business logic services
│   │       ├── AuthService.php
│   │       ├── PaymentService.php
│   │       └── ...
│   ├── bootstrap/                   # Framework bootstrap
│   ├── config/                      # Configuration files
│   ├── database/
│   │   ├── factories/               # Model factories
│   │   ├── migrations/              # Database migrations
│   │   └── seeders/                 # Database seeders
│   ├── public/                      # Public assets
│   ├── resources/
│   │   ├── css/                     # Stylesheets
│   │   ├── js/                      # JavaScript
│   │   └── views/
│   │       ├── components/          # Blade components
│   │       ├── layouts/             # Layouts
│   │       ├── livewire/            # Livewire views
│   │       └── errors/              # Error pages
│   ├── routes/
│   │   ├── api.php                  # API routes
│   │   ├── web.php                  # Web routes
│   │   └── auth.php                 # Auth routes
│   ├── storage/                     # File storage
│   │   ├── app/
│   │   ├── framework/
│   │   └── logs/
│   ├── tests/                       # PHPUnit/Pest tests
│   │   ├── Feature/
│   │   └── Unit/
│   ├── .env.example
│   ├── composer.json
│   ├── package.json
│   └── phpunit.xml
│
├── mobile/                           # Flutter Mobile App
│   ├── android/                      # Android native code
│   ├── ios/                          # iOS native code
│   ├── lib/
│   │   ├── main.dart                # App entry point
│   │   ├── models/                  # Data models
│   │   │   ├── user.dart
│   │   │   ├── workshop.dart
│   │   │   ├── service.dart
│   │   │   └── ...
│   │   ├── providers/               # Provider state management
│   │   │   ├── auth_provider.dart
│   │   │   ├── workshop_provider.dart
│   │   │   └── ...
│   │   ├── screens/                 # App screens
│   │   │   ├── auth/
│   │   │   ├── dashboard/
│   │   │   ├── services/
│   │   │   ├── transactions/
│   │   │   └── ...
│   │   ├── services/                # API services
│   │   │   ├── api_service.dart
│   │   │   ├── auth_service.dart
│   │   │   └── ...
│   │   ├── utils/                   # Utilities
│   │   │   ├── constants.dart
│   │   │   ├── helpers.dart
│   │   │   └── ...
│   │   └── widgets/                 # Reusable widgets
│   │       ├── custom_button.dart
│   │       ├── custom_card.dart
│   │       └── ...
│   ├── assets/                      # Images, icons, fonts
│   ├── test/                        # Widget & unit tests
│   ├── pubspec.yaml
│   └── README.md
│
├── postman/                          # API testing
│   ├── BBIHUB_API.postman_collection.json
│   └── README.md
│
├── .gitignore
├── README.md
└── LICENSE
```

---

## Development Workflow

### Git Workflow

**Branch Strategy:**
```
main           # Production-ready code
develop        # Development integration branch (default)
feature/*      # Feature development branches
bugfix/*       # Bug fix branches
hotfix/*       # Urgent production fixes
release/*      # Release preparation branches
```

**Feature Development:**
```bash
# Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/new-feature-name

# Make changes, commit
git add .
git commit -m "feat: add new feature"

# Push and create pull request
git push origin feature/new-feature-name
```

**Commit Message Convention:**
```
feat: Add new feature
fix: Fix bug in service processing
docs: Update API documentation
style: Format code with Pint
refactor: Refactor payment service
test: Add unit tests for AuthController
chore: Update dependencies
```

### Code Standards

**Backend (Laravel/PHP):**
- Follow PSR-12 coding standards
- Run Laravel Pint before committing: `./vendor/bin/pint`
- Write tests for new features
- Document public methods with PHPDoc
- Use type hints for all method parameters and return types

**Mobile (Flutter/Dart):**
- Follow Dart style guide
- Run `flutter analyze` before committing
- Use meaningful widget and class names
- Write widget tests for UI components
- Document public APIs

### Testing Strategy

**Backend Testing:**
```bash
# Run all tests
php artisan test

# Run specific suite
php artisan test --testsuite=Feature
php artisan test --testsuite=Unit

# With coverage
php artisan test --coverage
```

**Mobile Testing:**
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/widget_test.dart
```

---

## Testing

### Backend Testing

**Test Structure:**
```
tests/
├── Feature/                  # Integration tests
│   ├── Api/
│   │   ├── AuthTest.php
│   │   ├── WorkshopTest.php
│   │   └── ...
│   └── ...
└── Unit/                     # Unit tests
    ├── Services/
    │   ├── PaymentServiceTest.php
    │   └── ...
    └── ...
```

**Running Tests:**
```bash
# All tests
php artisan test

# Specific test
php artisan test --filter AuthTest

# With coverage
php artisan test --coverage --min=80
```

**Example Test:**
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

### Mobile Testing

**Test Structure:**
```
test/
├── widget_test.dart          # Widget tests
├── unit/                     # Unit tests
│   └── models/
│       └── user_test.dart
└── integration/              # Integration tests (future)
```

**Running Tests:**
```bash
# All tests
flutter test

# Specific test
flutter test test/widget_test.dart

# With coverage
flutter test --coverage
lcov --summary coverage/lcov.info
```

---

## Deployment

### Backend Deployment

#### Production Server Requirements
- Ubuntu 20.04+ or similar Linux distribution
- Nginx or Apache web server
- PHP 8.2+ with required extensions
- MySQL 8.0+
- Redis (recommended)
- SSL certificate (Let's Encrypt)

#### Deployment Steps

**1. Server Setup**
```bash
# Update system
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

**2. Deploy Application**
```bash
# Clone repository
git clone https://github.com/siberbot88/bbihub-platform.git /var/www/bbihub
cd /var/www/bbihub/backend

# Install dependencies
composer install --no-dev --optimize-autoloader
npm install && npm run build

# Configure environment
cp .env.example .env
nano .env  # Edit production settings

# Generate key
php artisan key:generate

# Run migrations
php artisan migrate --force

# Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set permissions
sudo chown -R www-data:www-data /var/www/bbihub
sudo chmod -R 755 /var/www/bbihub/backend/storage
```

**3. Configure Nginx**
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

**4. SSL Configuration**
```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Get certificate
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

# Add line
* * * * * cd /var/www/bbihub/backend && php artisan schedule:run >> /dev/null 2>&1
```

### Mobile Deployment

#### Android (Google Play Store)

**1. Build Release APK**
```bash
cd mobile
flutter build apk --release
```

**2. Build App Bundle (Recommended)**
```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

**3. Upload to Google Play Console**
- Create application in Play Console
- Upload AAB file
- Complete store listing
- Submit for review

#### iOS (App Store)

**1. Build Release**
```bash
cd mobile
flutter build ios --release
```

**2. Archive in Xcode**
- Open `ios/Runner.xcworkspace` in Xcode
- Select "Any iOS Device" as target
- Product > Archive
- Upload to App Store Connect

**3. App Store Submission**
- Complete app information in App Store Connect
- Submit for review

---

## Contributing

### How to Contribute

We welcome contributions from the community. Please follow these guidelines:

**1. Fork the Repository**
```bash
# Fork on GitHub then clone
git clone https://github.com/YOUR_USERNAME/bbihub-platform.git
cd bbihub-platform
```

**2. Create Feature Branch**
```bash
git checkout develop
git checkout -b feature/your-feature-name
```

**3. Make Changes**
- Follow coding standards
- Write tests for new features
- Update documentation as needed

**4. Commit Changes**
```bash
git add .
git commit -m "feat: add your feature description"
```

**5. Push and Create Pull Request**
```bash
git push origin feature/your-feature-name
```
Then create pull request on GitHub targeting `develop` branch.

### Pull Request Guidelines

- Provide clear description of changes
- Reference related issues
- Ensure all tests pass
- Update documentation
- Follow commit message conventions
- Keep changes focused and atomic

### Code Review Process

1. Automated tests must pass
2. Code review by maintainers
3. Address review feedback
4. Approval and merge

---

## License

This project is licensed under the **MIT License**.

Copyright (c) 2025 BBIHUB Development Team

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

## Support

**Technical Support:**
- GitHub Issues: [Report bugs and request features](https://github.com/siberbot88/bbihub-platform/issues)
- Documentation: [Wiki](https://github.com/siberbot88/bbihub-platform/wiki)
- Email: support@bbihub.com

**Development Team:**
- Lead Developer: [Your Name]
- Backend Team: [Names]
- Mobile Team: [Names]
- DevOps: [Names]

---

**Built with Laravel and Flutter**

Copyright 2025 BBIHUB Development Team. All rights reserved.
