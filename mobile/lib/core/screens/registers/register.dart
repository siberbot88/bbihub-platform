import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/widgets/custom_alert.dart';
import 'package:bengkel_online_flutter/core/widgets/clean_notification.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

// Helper untuk menampilkan halaman RegisterFlowPage
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register Multi Step',
      theme: ThemeData(
        primaryColor: const Color(0xFFD72B1C),
        scaffoldBackgroundColor: Colors.grey.shade100,
        fontFamily: 'Poppins',
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.red),
      ),
      home: const RegisterFlowPage(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const Scaffold(body: Center(child: Text('Halaman Login'))),
        // Pastikan /main sudah didefinisikan di app utama kamu
      },
    );
  }
}

class RegisterFlowPage extends StatefulWidget {
  const RegisterFlowPage({super.key});
  @override
  State<RegisterFlowPage> createState() => _RegisterFlowPageState();
}

class _RegisterFlowPageState extends State<RegisterFlowPage>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _createdWorkshopId;

  final PageController _pageController = PageController();

  late AnimationController _successAnimCtrl;
  late Animation<double> _successScaleAnim;
  late AnimationController _fadeAnimCtrl;
  late Animation<double> _fadeAnim;
  late AnimationController _slideAnimCtrl;
  late Animation<Offset> _slideAnim;

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(), // step 0
    GlobalKey<FormState>(), // step 1
    GlobalKey<FormState>(), // step 2
  ];

  // controllers
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController workshopController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController decsController = TextEditingController();
  final TextEditingController nibController = TextEditingController();
  final TextEditingController npwpController = TextEditingController();
  final TextEditingController wemailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController openingTimeController = TextEditingController();
  final TextEditingController closingTimeController = TextEditingController();
  final TextEditingController operationalDaysController = TextEditingController();

  int _currentStep = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password Strength & Server Error State
  double _passwordStrength = 0.0;
  Color _strengthColor = Colors.grey;
  String _strengthText = "";
  String? _passwordServerError;

  void _checkStrength(String val) {
    if (val.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _strengthText = "";
        _strengthColor = Colors.grey;
        _passwordServerError = null; // Reset server error on typing
      });
      return;
    }

    double strength = 0;
    if (val.length >= 8) strength += 0.3;
    if (val.contains(RegExp(r'[A-Z]'))) strength += 0.3;
    if (val.contains(RegExp(r'[0-9]')) || val.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.4;

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.3) {
        _strengthText = "Lemah";
        _strengthColor = Colors.red;
      } else if (strength <= 0.6) {
        _strengthText = "Sedang";
        _strengthColor = Colors.orange;
      } else {
        _strengthText = "Kuat";
        _strengthColor = Colors.green;
      }
      _passwordServerError = null; // Reset server error on typing
    });
  }

  @override
  void initState() {
    super.initState();
    _successAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _successScaleAnim = CurvedAnimation(parent: _successAnimCtrl, curve: Curves.elasticOut);
    
    _fadeAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeAnimCtrl, curve: Curves.easeIn));
    
    _slideAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _slideAnimCtrl, curve: Curves.easeOutCubic));
  }

  void _goStep(int step) {
    if (step < 0 || step > 3) return;
    FocusScope.of(context).unfocus();
    setState(() => _currentStep = step);
    _pageController.animateToPage(step, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutCubicEmphasized);
    if (step == 3) {
      _successAnimCtrl
        ..reset()
        ..forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _fadeAnimCtrl
          ..reset()
          ..forward();
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        _slideAnimCtrl
          ..reset()
          ..forward();
      });
    }
  }

  void _onNext() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      _goStep(_currentStep + 1);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _successAnimCtrl.dispose();
    _fadeAnimCtrl.dispose();
    _slideAnimCtrl.dispose();
    fullnameController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    emailController.dispose();
    workshopController.dispose();
    addressController.dispose();
    phoneController.dispose();
    urlController.dispose();
    decsController.dispose();
    nibController.dispose();
    npwpController.dispose();
    wemailController.dispose();
    cityController.dispose();
    provinceController.dispose();
    postalCodeController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    openingTimeController.dispose();
    closingTimeController.dispose();
    operationalDaysController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (!(_formKeys[2].currentState?.validate() ?? false)) {
      CustomAlert.show(
        context,
        title: "Perhatian",
        message: "Harap lengkapi data dokumen.",
        type: AlertType.warning,
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      CustomAlert.show(
        context,
        title: "Perhatian",
        message: "Password dan konfirmasi tidak cocok!",
        type: AlertType.warning,
      );
      _goStep(0);
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final ok = await authProvider.register(
        name: fullnameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        passwordConfirmation: confirmPasswordController.text,
      );
      if (!ok) throw Exception(authProvider.authError ?? 'Registrasi user gagal');

      final workshop = await _apiService.createWorkshop(
        name: workshopController.text.trim(),
        description: decsController.text.trim(),
        address: addressController.text.trim(),
        phone: phoneController.text.trim(),
        email: wemailController.text.trim(),
        mapsUrl: urlController.text.trim(),
        city: cityController.text.trim(),
        province: provinceController.text.trim(),
        country: "Indonesia",
        postalCode: postalCodeController.text.trim(),
        latitude: double.tryParse(latitudeController.text.trim().replaceAll(',', '.')) ?? 0.0,
        longitude: double.tryParse(longitudeController.text.trim().replaceAll(',', '.')) ?? 0.0,
        openingTime: openingTimeController.text.trim(),
        closingTime: closingTimeController.text.trim(),
        operationalDays: operationalDaysController.text.trim(),
      );

      _createdWorkshopId = workshop.id;

      await _apiService.createDocument(
        workshopUuid: _createdWorkshopId!,
        nib: nibController.text.trim(),
        npwp: npwpController.text.trim(),
      );

      // refresh profil agar workshop tampil di AuthProvider.user
      await authProvider.checkLoginStatus();

      if (!mounted) return;
      setState(() => _isLoading = false);
      _goStep(3);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      String msg = e.toString().replaceFirst("Exception: ", "");
      
      // Handle "Data Leak" / Password Validation Error specific from Backend
      if (msg.toLowerCase().contains("password") || msg.toLowerCase().contains("weak")) {
         setState(() {
           _passwordServerError = msg; 
           _goStep(0); // Back to Step 0 if error happens later (though usually validation is immediate)
         });
         
         // Scroll to top or specific location could be added here
      } else {
          CleanNotification.show(
            context,
            title: 'Gagal Memperbarui Data',
            message: _translateErrorMessage(msg),
            type: NotificationType.error,
            actionText: 'Coba Lagi',
            onAction: () => _handleRegister(),
            secondaryActionText: 'Abaikan',
            onSecondaryAction: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          );
      }

      if (!authProvider.isLoggedIn) {
        _goStep(0);
      } else if (_createdWorkshopId == null) {
        _goStep(1);
      }
    }
  }

  String _translateErrorMessage(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('connection') || m.contains('network') || m.contains('socket') || m.contains('clientexception')) {
      return "Gagal terhubung ke server. Periksa koneksi internet Anda.";
    }
    if (m.contains('timeout')) {
      return "Koneksi ke server terlalu lama (timeout). Silakan coba lagi.";
    }
    if (m.contains('unprocessable entity') || m.contains('422')) {
      return "Data yang Anda masukkan tidak valid. Mohon periksa kembali.";
    }
    if (m.contains('internal server error') || m.contains('500')) {
      return "Terjadi kesalahan pada server kami. Mohon coba lagi nanti.";
    }
    if (m.contains('unauthorized') || m.contains('401')) {
      return "Sesi Anda telah berakhir atau tidak valid. Silakan login ulang.";
    }
    // Fallback: If map not found, return original but try to make it friendlier if it's raw
    if (msg.startsWith("Exception:")) return msg.replaceFirst("Exception:", "").trim();
    return msg;
  }

  String? _validateNotEmpty(String? v, String name) => (v == null || v.trim().isEmpty) ? '$name tidak boleh kosong.' : null;
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong.';
    final r = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return r.hasMatch(v.trim()) ? null : 'Format email tidak valid.';
  }
  String? _validateEmailOptional(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final r = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return r.hasMatch(v.trim()) ? null : 'Format email tidak valid.';
  }
  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password tidak boleh kosong.';
    if (v.length < 8) return 'Password minimal 8 karakter.';
    return null;
  }
  String? _validateConfirmPassword(String? v) {
    if (v == null || v.isEmpty) return 'Verifikasi password tidak boleh kosong.';
    if (v != passwordController.text) return 'Password tidak cocok.';
    return null;
  }
  String? _validateTimeFormat(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name tidak boleh kosong.';
    final r = RegExp(r'^\d{2}:\d{2}$');
    return r.hasMatch(v.trim()) ? null : 'Format $name harus HH:MM (08:00).';
  }
  String? _validateNumber(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name tidak boleh kosong.';
    return double.tryParse(v.trim().replaceAll(',', '.')) == null ? '$name harus berupa angka.' : null;
  }
  String? _validateUrl(String? v, String name) {
    if (v == null || v.trim().isEmpty) return '$name tidak boleh kosong.';
    final s = v.trim().toLowerCase();
    return (s.startsWith('http://') || s.startsWith('https://')) ? null : 'Format $name tidak valid (http/https).';
  }

  Widget _buildProgressBar(double width) {
    final segment = width / 3;
    return SizedBox(
      height: 50,
      child: Stack(
        children: [
          Positioned(top: 20, left: segment / 2, right: segment / 2, child: Container(height: 2, color: Colors.red.withAlpha(77))),
          Positioned(
            top: 20,
            left: segment / 2,
            width: segment * math.min(_currentStep, 2.0),
            child: AnimatedContainer(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut, height: 2, color: Colors.red),
          ),
          for (int i = 0; i < 3; i++)
            Positioned(
              left: segment * i + (segment / 2) - 12,
              top: 8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: (i <= _currentStep) ? Colors.red : Colors.white,
                  border: Border.all(color: (i <= _currentStep) ? Colors.red : Colors.red.withAlpha(128)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: (i < _currentStep)
                        ? const Icon(Icons.check, size: 16, color: Colors.white, key: ValueKey('check'))
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ),
              ),
            ),
          for (int i = 0; i < 3; i++)
            Positioned(
              left: segment * i,
              top: 34,
              width: segment,
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: (i == _currentStep) ? Colors.red : Colors.grey,
                    fontWeight: (i == _currentStep) ? FontWeight.bold : FontWeight.normal,
                  ),
                  child: Text(['Data diri', 'Data bengkel', 'Dokumen'][i]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    int maxline = 1,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool? obscureState,
    VoidCallback? onToggleObscure,

    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
       maxLines: maxline,
      obscureText: isPassword ? (obscureState ?? true) : false,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText, // Inject external error text
        labelStyle: GoogleFonts.poppins(color: const Color(0xFFD72B1C), fontSize: 14, fontWeight: FontWeight.w500),
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFFD72B1C), size: 22),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon((obscureState ?? true) ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFD72B1C)),
          onPressed: onToggleObscure,
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD72B1C), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.orange, width: 2),
        ),
        errorStyle: const TextStyle(fontSize: 10, color: Colors.orange),
        filled: true,
        fillColor: Colors.white,
      ),
      style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13),
    );
  }

  Widget _buildFormCard({required Widget child, required double cardWidth}) {
    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), offset: const Offset(0, 0), blurRadius: 22)],
      ),
      child: child,
    );
  }

  Widget _scrollableStep(Widget child) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final kb = MediaQuery.of(context).viewInsets.bottom;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: 16 + kb),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 16 - kb),
            child: Align(alignment: Alignment.topCenter, child: child),
          ),
        );
      },
    );
  }

  Widget _buildStep0(double cardWidth) {
    final content = _buildFormCard(
      cardWidth: cardWidth,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKeys[0],
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD72B1C).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD72B1C).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline, color: Color(0xFFD72B1C), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Isi Data Diri", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text("Buatlah akun pertamamu sebagai Owner", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(controller: fullnameController, label: "Nama Lengkap", hint: "Contoh: Budi Santoso", icon: Icons.person_outline, validator: (v) => _validateNotEmpty(v, "Nama")),
              const SizedBox(height: 16),
              _buildTextField(controller: usernameController, label: "Username", hint: "Contoh: budi123", icon: Icons.account_circle_outlined, validator: (v) => _validateNotEmpty(v, "Username")),
              const SizedBox(height: 16),
              _buildTextField(controller: emailController, label: "Email", hint: "budi@example.com", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: _validateEmail),
              const SizedBox(height: 16),
              _buildTextField(
                controller: passwordController,
                label: "Password",
                hint: "Minimal 8 karakter",
                icon: Icons.lock_outline,
                isPassword: true,
                obscureState: _obscurePassword,
                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                validator: _validatePassword,
                onChanged: _checkStrength, // Listen to typing
                errorText: _passwordServerError, // Show server error here
              ),
              // Password Strength Indicator UI
              if (passwordController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4, right: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: _passwordStrength,
                                backgroundColor: Colors.grey.shade200,
                                color: _strengthColor,
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _strengthText,
                            style: TextStyle(color: _strengthColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (_passwordStrength < 1.0)
                         Padding(
                           padding: const EdgeInsets.only(top: 4.0),
                           child: Text(
                             "Gunakan minimal 8 karakter, huruf besar, dan simbol.",
                             style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                           ),
                         ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: confirmPasswordController,
                label: "Konfirmasi Password",
                hint: "Ulangi password",
                icon: Icons.lock_outline,
                isPassword: true,
                obscureState: _obscureConfirmPassword,
                onToggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                validator: _validateConfirmPassword,
              ),
            ],
          ),
        ),
      ),
    );
    return _scrollableStep(content);
  }

  Widget _buildStep1(double cardWidth) {
    final content = _buildFormCard(
      cardWidth: cardWidth,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKeys[1],
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD72B1C).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD72B1C).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.business_outlined, color: Color(0xFFD72B1C), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Isi Data Bengkel", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text("Daftarkan bengkelmu sekarang untuk menarik lebih banyak pelanggan", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(controller: workshopController, label: "Nama Bengkel", hint: "Contoh: Bengkel Maju Jaya", icon: Icons.business_outlined, validator: (v) => _validateNotEmpty(v, "Nama Bengkel")),
              const SizedBox(height: 16),
              _buildTextField(controller: decsController, label: "Deskripsi", hint: "Spesialisasi, layanan, dll", icon: Icons.description_outlined, maxline: 3, validator: (v) => _validateNotEmpty(v, "Deskripsi")),
              const SizedBox(height: 16),
              _buildTextField(controller: addressController, label: "Alamat Lengkap", hint: "Jl. Sudirman No. 1", icon: Icons.location_on_outlined, maxline: 2, validator: (v) => _validateNotEmpty(v, "Alamat")),
              const SizedBox(height: 16),
              _buildTextField(controller: phoneController, label: "Nomor Telepon", hint: "08123456789", icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => _validateNotEmpty(v, "Telepon")),
              const SizedBox(height: 16),
              _buildTextField(controller: wemailController, label: "Email Bengkel (Opsional)", hint: "bengkel@example.com", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: _validateEmailOptional),
              const SizedBox(height: 16),
              _buildTextField(controller: urlController, label: "Google Maps URL", hint: "https://maps.google.com/...", icon: Icons.map_outlined, validator: (v) => _validateUrl(v, "URL Maps")),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(controller: cityController, label: "Kota", hint: "Jakarta", icon: Icons.location_city_outlined, validator: (v) => _validateNotEmpty(v, "Kota"))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(controller: provinceController, label: "Provinsi", hint: "DKI Jakarta", icon: Icons.flag_outlined, validator: (v) => _validateNotEmpty(v, "Provinsi"))),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(controller: postalCodeController, label: "Kode Pos", hint: "12345", icon: Icons.mail_outline, keyboardType: TextInputType.number, validator: (v) => _validateNotEmpty(v, "Kode Pos")),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(controller: latitudeController, label: "Latitude", hint: "-6.200000", icon: Icons.my_location_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => _validateNumber(v, "Latitude"))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(controller: longitudeController, label: "Longitude", hint: "106.816666", icon: Icons.explore_outlined, keyboardType: const TextInputType.numberWithOptions(decimal: true), validator: (v) => _validateNumber(v, "Longitude"))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(controller: openingTimeController, label: "Buka", hint: "08:00", icon: Icons.access_time_outlined, validator: (v) => _validateTimeFormat(v, "Jam Buka"))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(controller: closingTimeController, label: "Tutup", hint: "17:00", icon: Icons.schedule_outlined, validator: (v) => _validateTimeFormat(v, "Jam Tutup"))),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(controller: operationalDaysController, label: "Hari Operasional", hint: "Senin - Jumat", icon: Icons.calendar_today_outlined, validator: (v) => _validateNotEmpty(v, "Hari Operasional")),
            ],
          ),
        ),
      ),
    );
    return _scrollableStep(content);
  }

  Widget _buildStep2(double cardWidth) {
    final content = _buildFormCard(
      cardWidth: cardWidth,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKeys[2],
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD72B1C).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD72B1C).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.assignment_outlined, color: Color(0xFFD72B1C), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Dokumen Pendukung", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text("Lengkapi dokumen anda untuk verifikasi", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(controller: nibController, label: "Nomor Induk Berusaha (NIB)", hint: "Masukkan NIB", icon: Icons.assignment_outlined, validator: (v) => _validateNotEmpty(v, "NIB")),
              const SizedBox(height: 16),
              _buildTextField(controller: npwpController, label: "NPWP", hint: "Masukkan NPWP", icon: Icons.badge_outlined, validator: (v) => _validateNotEmpty(v, "NPWP")),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.blue.shade200)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(child: Text("Pastikan data dokumen yang Anda masukkan valid dan sesuai dengan legalitas usaha Anda.", style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue.shade800))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return _scrollableStep(content);
  }

  Widget _buildStep3(double cardWidth) {
    return Center(
      child: ScaleTransition(
        scale: _successScaleAnim,
        child: Container(
          width: cardWidth,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            // Minimalist soft shadow
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 40,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clean Icon Animation
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.green.shade600,
                      size: 60,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Minimalist Typography
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Text(
                      "Registrasi Berhasil!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Selamat, akun bengkel Anda telah aktif. \nMulai kelola bisnismu sekarang.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Clean Action Button
              FadeTransition(
                opacity: _fadeAnim,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD72B1C),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Masuk ke Dashboard",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = math.min(size.width * 0.9, 400.0);

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                if (_currentStep < 3)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        if (_currentStep > 0)
                          IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD72B1C)), onPressed: () => _goStep(_currentStep - 1))
                        else
                          IconButton(icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFD72B1C)), onPressed: () => Navigator.pop(context)),
                        const Expanded(child: Center(child: Text("Register Owner", style: TextStyle(color: Color(0xFFD72B1C), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')))),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                if (_currentStep < 3) ...[
                  const SizedBox(height: 20),
                  _buildProgressBar(cardWidth),
                  const SizedBox(height: 20),
                ],
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep0(cardWidth),
                      _buildStep1(cardWidth),
                      _buildStep2(cardWidth),
                      Builder(
                        builder: (context) {
                          // Ensure animations are initialized before building step 3
                          if (_currentStep == 3) {
                            return _buildStep3(cardWidth);
                          }
                          // Return empty container for other steps
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_currentStep < 3)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: cardWidth,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD72B1C), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 8),
                    onPressed: _isLoading ? null : (_currentStep == 2 ? _handleRegister : _onNext),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_currentStep == 2 ? "DAFTAR SEKARANG" : "SELANJUTNYA", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
