import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/main.dart' show MainPage;

/// Entry point ke halaman utama sesuai role user.
class RoleEntry extends StatelessWidget {
  const RoleEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.user?.role ?? 'admin'; // fallback aman
    return MainPage(role: role);
  }
}

/// Gate untuk proteksi halaman/fitur berdasarkan role.
class RequireRole extends StatelessWidget {
  final List<String> any; // role yang diizinkan, salah satu cukup
  final Widget child;
  const RequireRole({super.key, required this.any, required this.child});

  @override
  Widget build(BuildContext context) {
    final role = context.select<AuthProvider, String?>((a) => a.user?.role);
    if (role == null) {
      // Bisa tampilkan loader, biar nggak flicker
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (any.contains(role)) return child;
    return const _Forbidden();
  }
}

class _Forbidden extends StatelessWidget {
  const _Forbidden();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('403 · Anda tidak punya akses'),
      ),
    );
  }
}
