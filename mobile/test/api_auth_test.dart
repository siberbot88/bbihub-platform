import 'package:flutter_test/flutter_test.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';

void main() {
  late ApiService apiService;

  setUp(() {
    apiService = ApiService();
  });

  group('API Service - Configuration Tests', () {
    test('should have correct base URL for Android emulator', () {
      expect(apiService.baseUrl, equals('http://10.0.2.2:8000/api/v1/'));
    });

    test('should construct correct register endpoint', () {
      final registerEndpoint = '${apiService.baseUrl}auth/register';
      expect(registerEndpoint, equals('http://10.0.2.2:8000/api/v1/auth/register'));
    });

    test('should construct correct login endpoint', () {
      final loginEndpoint = '${apiService.baseUrl}auth/login';
      expect(loginEndpoint, equals('http://10.0.2.2:8000/api/v1/auth/login'));
    });

    test('should construct correct logout endpoint', () {
      final logoutEndpoint = '${apiService.baseUrl}auth/logout';
      expect(logoutEndpoint, equals('http://10.0.2.2:8000/api/v1/auth/logout'));
    });

    test('should construct correct fetch user endpoint', () {
      final fetchUserEndpoint = '${apiService.baseUrl}auth/user';
      expect(fetchUserEndpoint, equals('http://10.0.2.2:8000/api/v1/auth/user'));
    });
  });

  group('API Service - Endpoint Validation', () {
    test('register endpoint should not have trailing slash', () {
      final endpoint = '${apiService.baseUrl}auth/register';
      expect(endpoint.endsWith('/register'), isTrue);
      expect(endpoint.endsWith('/register/'), isFalse);
    });

    test('login endpoint should not have trailing slash', () {
      final endpoint = '${apiService.baseUrl}auth/login';
      expect(endpoint.endsWith('/login'), isTrue);
      expect(endpoint.endsWith('/login/'), isFalse);
    });

    test('base URL should have version prefix', () {
      expect(apiService.baseUrl.contains('/v1/'), isTrue);
    });

    test('base URL should use correct protocol for Android emulator', () {
      expect(apiService.baseUrl.startsWith('http://'), isTrue);
    });
  });

  group('API Service - Request Data Structure', () {
    test('register should require all mandatory fields', () {
      // This test validates the register method signature
      expect(
        () => apiService.register(
          name: 'Test User',
          username: 'testuser',
          email: 'test@example.com',
          password: 'password',
          passwordConfirmation: 'password',
        ),
        returnsNormally,
      );
    });

    test('login should require email and password', () {
      // This test validates the login method signature
      expect(
        () => apiService.login('test@example.com', 'password'),
        returnsNormally,
      );
    });
  });

  group('API Service - Method Availability', () {
    test('should have register method', () {
      expect(apiService.register, isA<Function>());
    });

    test('should have login method', () {
      expect(apiService.login, isA<Function>());
    });

    test('should have logout method', () {
      expect(apiService.logout, isA<Function>());
    });

    test('should have fetchUser method', () {
      expect(apiService.fetchUser, isA<Function>());
    });

    test('should have changePassword method', () {
      expect(apiService.changePassword, isA<Function>());
    });
  });
}
