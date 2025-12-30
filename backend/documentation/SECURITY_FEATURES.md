# BBI HUB - Security Features Documentation

## 📋 Overview

This document provides a comprehensive list of security features implemented in the BBI HUB platform to protect against common vulnerabilities and ensure data integrity, confidentiality, and availability.

---

## 🛡️ Security Features Implemented

### 1. **Authentication & Authorization**

#### a. Laravel Sanctum Multi-Guard Authentication
- **Guards Implemented:**
  - `web`: For SuperAdmin (web dashboard)
  - `sanctum`: For Owner, Admin, Mechanic (mobile API)
- **Token-Based Auth**: Stateless API authentication with expirable tokens
- **Session-Based Auth**: Secure cookie-based authentication for web admin
- **Protection Against**: Session hijacking, unauthorized API access

#### b. Role-Based Access Control (RBAC)
- **Spatie Permission Package**: Laravel-permission for granular access control
- **Roles**: SuperAdmin, Owner, Admin, Mechanic
- **Middleware**: Role and permission checks on every route
- **Protection Against**: Privilege escalation, unauthorized feature access

#### c. Password Security
- **Bcrypt Hashing**: Industry-standard password hashing
- **Password Policy**:
  - Minimum 8 characters
  - Requires uppercase, lowercase, numbers
  - Password confirmation on registration
- **Must Change Password**: Force password change for default accounts
- **Protection Against**: Brute force attacks, weak passwords, rainbow table attacks

---

### 2. **Authorization & Access Control**

#### a. Laravel Policy-Based Authorization
- **Implemented Policies:**
  - `ServicePolicy`: Ensures users only access their workshop's services
  - `WorkshopPolicy`: Prevents cross-workshop data access
  - `InvoicePolicy`: Restricts invoice access to authorized users
  - `TransactionPolicy`: Financial data protection

**Example Protection:**
```php
// User can only view services from their own workshop
$this->authorize('view', $service);

// Backend automatically filters:
if ($user->hasRole('admin')) {
    $query->where('workshop_uuid', $user->employment->workshop_uuid);
}
```

**Protection Against**: **IDOR (Insecure Direct Object Reference)**

#### b. Multi-Tenancy Workshop Isolation
- **Workshop UUID Filtering**: All queries auto-filtered by workshop
- **Employment Records**: Admins/Mechanics linked to specific workshops
- **Owner Segregation**: Owners can only see their own workshops
- **Protection Against**: Cross-tenant data leakage, unauthorized workshop access

---

### 3. **Data Protection & Encryption**

#### a. HTTPS/TLS Encryption
- **Forced HTTPS**: Production environment enforces HTTPS
- **TLS 1.2+**: Modern encryption protocols
- **Certificate Pinning**: (Recommended for production)
- **Protection Against**: **MITM (Man-in-the-Middle) attacks**, eavesdropping

#### b. Environment Variable Security
- **Sensitive Data in `.env`**:
  - Database credentials
  - API keys (Midtrans, FCM, Groq AI)
  - Encryption keys
- **`.gitignore`**: Prevents `.env` from being committed
- **Protection Against**: Credential exposure, API key leakage

#### c. Database Security
- **Prepared Statements**: Eloquent ORM prevents SQL injection
- **Parameterized Queries**: All user input sanitized
- **UUID Primary Keys**: Non-sequential IDs prevent enumeration
- **Protection Against**: **SQL Injection**, database enumeration attacks

---

### 4. **Input Validation & Sanitization**

#### a. Laravel Form Requests
- **Custom Request Classes**: Centralized validation logic
- **Validation Rules**: Type checking, format validation, range checks
- **Example:**
```php
$request->validate([
    'email' => 'required|email|unique:users',
    'phone' => 'required|regex:/^[0-9]{10,15}$/',
    'amount' => 'required|numeric|min:0',
]);
```
**Protection Against**: **XSS (Cross-Site Scripting)**, injection attacks, malformed data

#### b. CSRF Protection
- **Laravel CSRF Tokens**: Automatic token generation for all forms
- **SameSite Cookies**: Prevents CSRF via cookie settings
- **Double Submit Cookie**: Laravel's built-in protection
- **Protection Against**: **CSRF (Cross-Site Request Forgery)**

#### c. Mass Assignment Protection
- **Fillable/Guarded**: Only allowed fields can be mass-assigned
```php
protected $fillable = ['name', 'email', 'phone'];
protected $guarded = ['id', 'is_admin', 'balance'];
```
**Protection Against**: Mass assignment vulnerabilities, privilege escalation

---

### 5. **API Security**

#### a. Rate Limiting
- **Throttle Middleware**: Limits requests per minute
```php
Route::middleware('throttle:60,1')->group(function () {
    // API routes limited to 60 requests/minute
});
```
- **Login Throttling**: Prevents brute force on login
- **Protection Against**: **DDoS**, brute force attacks, API abuse

#### b. API Authentication
- **Bearer Token**: All API requests require valid Sanctum token
- **Token Expiration**: Configurable token lifetime
- **Token Revocation**: Users can revoke tokens on logout
- **Protection Against**: Unauthorized API access, session fixation

#### c. CORS (Cross-Origin Resource Sharing)
- **Configured Allowed Origins**: Only trusted domains can access API
- **Preflight Requests**: Validates cross-origin requests
- **Protection Against**: Unauthorized cross-origin API access

---

### 6. **File Upload Security**

#### a. Validation
- **File Type Restrictions**: Only allowed MIME types (images for profiles)
- **File Size Limits**: Max upload size enforced
- **Example:**
```php
'photo' => 'nullable|image|mimes:jpeg,png,jpg|max:2048'
```
**Protection Against**: Malicious file uploads, shell script execution

#### b. Storage Security
- **Spatie Media Library**: Secure file handling
- **Non-Public Storage**: Files stored outside webroot when needed
- **Signed URLs**: Temporary access to protected files
- **Protection Against**: Arbitrary file upload, directory traversal

---

### 7. **Session Security**

#### a. Secure Cookie Configuration
```php
'secure' => env('SESSION_SECURE_COOKIE', true),  // HTTPS only
'http_only' => true,                             // No JavaScript access
'same_site' => 'lax',                            // CSRF protection
```
**Protection Against**: Session hijacking, XSS cookie theft

#### b. Session Timeout
- **Configurable Lifetime**: Auto-logout after inactivity
- **Remember Me**: Optional extended session with secure token
- **Protection Against**: Unattended session exploitation

---

### 8. **Error Handling & Logging**

#### a. Secure Error Pages
- **Production Mode**: Hides detailed error messages
- **Custom Error Pages**: User-friendly error display
- **Example:** `APP_DEBUG=false` in production
- **Protection Against**: Information disclosure, stack trace leakage

#### b. Comprehensive Logging
- **Sentry Integration**: Real-time error tracking
- **Laravel Log**: File-based logging with rotation
- **Audit Logs**: Track critical actions (future enhancement)
- **Protection Against**: Undetected breaches, post-incident forensics

---

### 9. **Payment Security**

#### a. Midtrans Integration
- **Server Key Protection**: Stored securely in `.env`
- **Signature Verification**: Validates webhook authenticity
```php
$signatureKey = hash('sha512', $orderId . $statusCode . $grossAmount . $serverKey);
if ($signatureKey !== $request->signature_key) {
    abort(403, 'Invalid signature');
}
```
- **HTTPS Required**: All payment requests over TLS
- **Protection Against**: Payment fraud, webhook spoofing, **MITM attacks**

#### b. PCI DSS Compliance (via Midtrans)
- **No Card Storage**: Card data never touches our servers
- **Tokenization**: Midtrans handles sensitive payment data
- **Protection Against**: Credit card theft, PCI non-compliance fines

---

### 10. **Mobile App Security**

#### a. Certificate Pinning (Recommended)
- **Future Enhancement**: Pin backend TLS certificate
- **Protection Against**: **MITM attacks**, SSL stripping

#### b. Secure Storage
- **Hive Encryption**: Local database encrypted
- **Secure Token Storage**: Auth tokens stored securely
- **Protection Against**: Local data tampering, token theft on rooted devices

#### c. Code Obfuscation
- **ProGuard/R8**: Android code obfuscation
- **Flutter Obfuscation**: Release builds with `--obfuscate`
- **Protection Against**: Reverse engineering, intellectual property theft

---

### 11. **Infrastructure Security**

#### a. Environment Separation
- **Development**: `APP_ENV=local` with debug enabled
- **Production**: `APP_ENV=production` with all protections
- **Staging**: Separate environment for testing
- **Protection Against**: Production data exposure in dev

#### b. Dependency Security
- **Composer**: Regular dependency updates
- **`composer audit`**: Checks for known vulnerabilities
- **npm audit**: Frontend dependency scanning
- **Protection Against**: **Zero-day exploits**, known CVEs

#### c. Security Headers
```php
// SecurityHeaders Middleware
'X-Frame-Options' => 'SAMEORIGIN',              // Clickjacking protection
'X-Content-Type-Options' => 'nosniff',          // MIME sniffing protection
'X-XSS-Protection' => '1; mode=block',          // XSS filter
'Strict-Transport-Security' => 'max-age=31536000', // HSTS
```
**Protection Against**: **Clickjacking**, MIME sniffing, XSS

---

### 12. **Real-Time Security (Pusher)**

#### a. Private Channels
- **Channel Authentication**: Laravel authenticates Pusher connections
- **Per-User Channels**: `private-user.{userId}`
- **Protection Against**: Unauthorized websocket access, message interception

#### b. Event Authorization
- **Broadcasting Auth**: Checks permissions before broadcasting
```php
public function broadcastOn(): array {
    return [new PrivateChannel('user.'.$this->user->id)];
}
```
**Protection Against**: Unauthorized real-time data access

---

## 🚨 Vulnerabilities NOT Present

### ✅ IDOR (Insecure Direct Object Reference)
**Protected by:**
- Laravel Policies (`$this->authorize()`)
- Workshop UUID filtering
- Employment-based access control

**Example:**
```
❌ Before: /api/services/123 (any user could access)
✅ After: Policy checks if service belongs to user's workshop
```

### ✅ SQL Injection
**Protected by:**
- Eloquent ORM with parameterized queries
- Query Builder bindings
- No raw SQL with user input

### ✅ XSS (Cross-Site Scripting)
**Protected by:**
- Blade templating auto-escapes output
- Input validation and sanitization
- Content Security Policy (recommended)

### ✅ CSRF (Cross-Site Request Forgery)
**Protected by:**
- Laravel CSRF tokens on all forms
- SameSite cookie configuration
- API uses Sanctum tokens (stateless)

### ✅ MITM (Man-in-the-Middle)
**Protected by:**
- Forced HTTPS in production
- TLS 1.2+ encryption
- HSTS header
- (Recommended: Certificate pinning for mobile)

### ✅ Session Hijacking
**Protected by:**
- HTTPOnly cookies
- Secure cookie flag (HTTPS only)
- Session regeneration on login
- IP tracking (optional future enhancement)

### ✅ Mass Assignment
**Protected by:**
- `$fillable` and `$guarded` model properties
- Form Request validation

### ✅ Authentication Bypass
**Protected by:**
- Sanctum middleware on protected routes
- Multi-guard system
- Role-based middleware

### ✅ Privilege Escalation
**Protected by:**
- Spatie Permission package
- Granular permission checks
- Separate guards for different user types

---

## 📊 Security Testing Performed

### Manual Testing
- ✅ RBAC Testing (see `SANCTUM_MANUAL_TESTING.md`)
- ✅ Password Policy Testing (see `password-policy-test.md`)
- ✅ API Authentication Testing
- ✅ Cross-workshop access attempts (all blocked)

### Automated Security Checks
- ✅ `composer audit` - No known vulnerabilities
- ✅ Laravel Security Checker
- ✅ Dependency scanning

### Pending Security Audits
- ⏳ Penetration testing
- ⏳ Third-party security audit
- ⏳ OWASP ZAP scanning

---

## 🔐 Security Best Practices Followed

1. **Principle of Least Privilege**: Users only get minimum necessary permissions
2. **Defense in Depth**: Multiple layers of security (auth + authorization + validation)
3. **Secure by Default**: Production defaults are secure, must opt-in to less secure options
4. **Input Validation**: Never trust user input, validate everything
5. **Output Encoding**: Escape all output to prevent XSS
6. **Fail Securely**: Errors default to denying access, not granting it
7. **Keep Secrets Secret**: All sensitive data in `.env`, never in code
8. **Update Dependencies**: Regular security updates
9. **Logging & Monitoring**: Track security events via Sentry
10. **Encryption Everywhere**: HTTPS, bcrypt passwords, encrypted storage

---

## 📝 Compliance & Standards

### Frameworks & Standards
- ✅ **OWASP Top 10 2021**: Protection against all major threats
- ✅ **PCI DSS**: Via Midtrans payment gateway
- ⏳ **GDPR**: Data protection and privacy (basic implementation)
- ⏳ **ISO 27001**: Information security management (future goal)

### Security Certifications
- Midtrans PCI DSS Level 1 Certified
- Laravel Security Best Practices

---

## 🚀 Future Security Enhancements

### Planned Improvements
1. **Two-Factor Authentication (2FA)**: SMS or TOTP-based
2. **API Security:**
   - JWT with refresh tokens
   - GraphQL query depth limiting
   - Advanced rate limiting per user
3. **Advanced Logging:**
   - Audit trails for all sensitive actions
   - Real-time security alerts
4. **Mobile Security:**
   - Certificate pinning implementation
   - Root/jailbreak detection
   - Anti-tampering checks
5. **Infrastructure:**
   - Web Application Firewall (WAF)
   - DDoS protection (Cloudflare)
   - Automated security scanning in CI/CD
6. **Encryption:**
   - Database-level encryption for sensitive fields
   - End-to-end encryption for chat (if implemented)

---

## 📞 Security Contact

For security vulnerabilities or concerns:
- **Email**: security@bbihub.com
- **Response Time**: 24-48 hours
- **Disclosure Policy**: Responsible disclosure encouraged

---

## 📚 References

- [Laravel Security Documentation](https://laravel.com/docs/10.x/security)
- [OWASP Top 10 2021](https://owasp.org/Top10/)
- [Spatie Laravel Permission](https://spatie.be/docs/laravel-permission)
- [Laravel Sanctum](https://laravel.com/docs/10.x/sanctum)
- [PCI DSS Requirements](https://www.pcisecuritystandards.org/)

---

**Last Updated**: December 29, 2025
**Version**: 1.0.0
**Maintained By**: BBI HUB Security Team
