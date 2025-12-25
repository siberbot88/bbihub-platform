import 'dart:async';
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/homepage.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/service_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bengkel_online_flutter/core/services/fcm_service.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/core/screens/loading_gate.dart';
import 'package:bengkel_online_flutter/core/screens/login.dart' as login_screen;
import 'package:bengkel_online_flutter/core/screens/suspended_account_screen.dart';

import 'package:bengkel_online_flutter/core/screens/registers/register.dart';
import 'package:bengkel_online_flutter/feature/auth/screens/forgot_password_page.dart' as forgot_pass;
import 'package:bengkel_online_flutter/feature/auth/screens/reset_password_page.dart' as reset_pass;

import 'package:bengkel_online_flutter/core/screens/splash_screen.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/feature/auth/screens/verify_email_page.dart';
import 'package:bengkel_online_flutter/feature/auth/screens/workshop_waiting_page.dart';

// OFFLINE DETECTION
import 'package:bengkel_online_flutter/core/widgets/connectivity_wrapper.dart';

// ADMIN
import 'package:bengkel_online_flutter/feature/admin/screens/dashboard.dart';
import 'package:bengkel_online_flutter/feature/admin/screens/profil_page.dart' as admin_profil;
import 'package:bengkel_online_flutter/feature/admin/widgets/bottom_nav.dart';
import 'package:bengkel_online_flutter/core/screens/registers/change_password.dart' as change_screen;

// OWNER
import 'package:bengkel_online_flutter/feature/owner/providers/employee_provider.dart';
import 'package:bengkel_online_flutter/core/providers/service_provider.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/homepage_owner.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/list_work.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/on_boarding.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/profil_page_owner.dart' as owner_profil;
import 'package:bengkel_online_flutter/feature/owner/screens/report_pages.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/staff_management.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/bottom_nav_owner.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/voucher_page.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/list_voucher_page.dart';



import 'package:bengkel_online_flutter/core/services/notification_provider.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/notification_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  await FcmService.initialize();

  // ✅ Inisialisasi format tanggal (PENTING untuk Voucher)
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
        ChangeNotifierProvider(create: (_) => AdminServiceProvider()),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (context) => NotificationProvider(context.read<AuthProvider>()),
          update: (context, auth, previous) => NotificationProvider(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();
    try {
      final initial = await _appLinks.getInitialAppLink();
      if (initial != null) _handleUri(initial);
    } catch (_) {}

    _linkSub = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleUri(uri);
      },
      onError: (_) {},
    );
  }

  void _handleUri(Uri uri) {
    String target = uri.host;
    if (target.isEmpty && uri.pathSegments.isNotEmpty) {
      target = uri.pathSegments.first;
    }

    if (target == 'login') {
      final email = uri.queryParameters['email'];
      navigatorKey.currentState?.pushNamed(
        '/login',
        arguments: {'email': email},
      );
      return;
    }

    if (target == 'set-password') {
      final token = uri.queryParameters['token'];
      navigatorKey.currentState?.pushNamed(
        '/changePassword',
        arguments: {'token': token},
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityWrapper(
      navigatorKey: navigatorKey,
      child: MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'BBI HUB PLUS',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Poppins',
        textTheme: const TextTheme().apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const SplashScreen(),
        "/onboarding": (context) => const OnboardingScreen(),
        "/login": (context) => const login_screen.LoginPage(),
        "/gate": (context) => const LoadingGate(),
        "/main": (context) => const RoleEntry(),
        "/verify-email": (context) => const VerifyEmailPage(),
        "/workshop-waiting": (context) => const WorkshopWaitingPage(),
        "/suspended": (context) => const SuspendedAccountScreen(),

        "/home": (context) => const DashboardScreen(),
        "/changePassword": (context) => const change_screen.UbahPasswordPage(),
        "/list": (context) => const ListWorkPage(),

        "/dashboard": (context) => const DashboardPage(),
        "/register/owner": (context) => const RegisterFlowPage(),
        "/owner/profile": (context) => owner_profil.ProfilePageOwner(),
        "/voucher": (context) => const VoucherPage(),
        "/voucher/list": (context) => const ListVoucherPage(),
        "/forgot-password": (context) => const forgot_pass.ForgotPasswordPage(),
        "/reset-password": (context) => const reset_pass.ResetPasswordPage(),
        "/notifications": (context) => const NotificationPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/list') {
          final args = (settings.arguments ?? {}) as Map?;
          final providedWs = args?['workshopUuid'] as String?;
          final auth = navigatorKey.currentContext != null
              ? Provider.of<AuthProvider>(navigatorKey.currentContext!, listen: false)
              : null;
          final derivedWs = _pickWorkshopUuid(auth?.user);
          final ws = providedWs ?? derivedWs;
          return MaterialPageRoute(
            builder: (_) => ListWorkPage(workshopUuid: ws),
            settings: settings,
          );
        }
        return null;
      },
      onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const SplashScreen()),
      ),
    );
  }
}

/// ✅ Logic Update: RoleEntry sekarang membaca arguments (index tab)
class RoleEntry extends StatelessWidget {
  const RoleEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.user?.role ?? 'guest';
    final mustChange = auth.mustChangePassword;

    // 1. Tangkap arguments (misal: 3 untuk Profile)
    final args = ModalRoute.of(context)?.settings.arguments;
    int initialIndex = 0;
    if (args is int) {
      initialIndex = args;
    }

    if (!auth.isLoggedIn || role == 'guest') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Cek status email verify
    if (!auth.isEmailVerified) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/verify-email');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 3. Cek status suspended (hanya owner) - CHECK INI DULUAN!
    if (role == 'owner' && auth.isSuspended) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/suspended');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 4. Cek status workshop verification (hanya owner)
    if (role == 'owner' && !auth.isWorkshopVerified) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/workshop-waiting');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (mustChange && role == 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/changePassword');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Kirim initialIndex ke MainPage
    return MainPage(role: role, initialIndex: initialIndex);
  }
}

/// ✅ Logic Update: MainPage menerima initialIndex
class MainPage extends StatefulWidget {
  final String role;
  final int initialIndex; // Parameter baru

  const MainPage({
    super.key,
    required this.role,
    this.initialIndex = 0 // Default ke 0 (Dashboard)
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // ✅ Set tab awal berdasarkan parameter yang dikirim
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    late final List<Widget> pages;
    late final Widget bottomNavBar;

    switch (widget.role) {
      case "owner":
        pages = [
          const DashboardScreen(),
          const ManajemenKaryawanPage(),
          const ReportPage(),
          owner_profil.ProfilePageOwner(),
        ];
        bottomNavBar = CustomBottomNavBarOwner(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
        break;

      case "admin":
        pages = [
          const HomePage(),
          const ServicePageAdmin(),
          const DashboardPage(),
          const admin_profil.ProfilePageAdmin(),
        ];
        bottomNavBar = CustomBottomNavBarAdmin(
          selectedIndex: _selectedIndex,
          onTap: _onItemTapped,
        );
        break;

      default:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: bottomNavBar,
    );
  }
}

String? _pickWorkshopUuid(dynamic user) {
  if (user == null) return null;
  try {
    final ws = user.workshops as List?;
    if (ws != null && ws.isNotEmpty) {
      final first = ws.first;
      try {
        final id = (first.id ?? first['id']) as String?;
        if (id != null && id.isNotEmpty) return id;
      } catch (_) {}
    }
  } catch (_) {}

  try {
    final emp = user.employment;
    final w = emp?.workshop ?? emp['workshop'];
    if (w != null) {
      try {
        final id = (w.id ?? w['id']) as String?;
        if (id != null && id.isNotEmpty) return id;
      } catch (_) {}
    }
  } catch (_) {}

  return null;
}


