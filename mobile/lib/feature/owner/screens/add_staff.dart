import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/feature/owner/providers/employee_provider.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';

import '../widgets/staff/staff_form_fields.dart';
import '../widgets/staff/staff_info_header.dart';
import '../widgets/staff/staff_success_screen.dart';
import '../../../../features/membership/presentation/widgets/premium_limit_dialog.dart';
import '../../../../features/membership/presentation/premium_membership_screen.dart';

const _primary = Color(0xFFD72B1C);

class AddStaffRegisterPage extends StatefulWidget {
  const AddStaffRegisterPage({super.key});
  @override
  State<AddStaffRegisterPage> createState() => _AddStaffRegisterPageState();
}

class _AddStaffRegisterPageState extends State<AddStaffRegisterPage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();

  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController specialistController = TextEditingController();
  final TextEditingController jobdeskController = TextEditingController();

  String _selectedRole = 'mechanic'; // admin | mechanic
  String? _errorMessage;
  bool _isSuccess = false;
  bool _saving = false;

  late final AnimationController _successCtrl;
  late final Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _successScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: .9, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween:
            Tween(begin: 1.1, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_successCtrl);
  }

  @override
  void dispose() {
    fullnameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    specialistController.dispose();
    jobdeskController.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    if (fullnameController.text.trim().isEmpty ||
        usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      setState(() {
        _saving = false;
        _errorMessage = "Nama, username, dan email wajib diisi.";
      });
      return;
    }

    final auth = context.read<AuthProvider>();
    final workshops = auth.user?.workshops;
    final String? workshopUuid =
        (workshops != null && workshops.isNotEmpty) ? workshops.first.id : null;

    if (workshopUuid == null) {
      setState(() {
        _errorMessage =
            "Gagal mendapatkan data workshop Anda. Silakan coba lagi.";
        _saving = false;
      });
      return;
    }

    try {
      final Employment emp = await _apiService.createEmployee(
        name: fullnameController.text.trim(),
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        role: _selectedRole,
        workshopUuid: workshopUuid,
        specialist: specialistController.text.trim().isEmpty
            ? null
            : specialistController.text.trim(),
        jobdesk: jobdeskController.text.trim().isEmpty
            ? null
            : jobdeskController.text.trim(),
      );

      if (mounted) {
        context.read<EmployeeProvider>().upsert(emp);
      }

      if (!mounted) return;
      setState(() {
        _saving = false;
        _isSuccess = true;
      });
      _successCtrl
        ..reset()
        ..forward();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        
        final msg = e.toString().replaceFirst("Exception: ", "");
        _errorMessage = msg;

        // Check for limit reached error
        if (msg.contains("Batas staff tercapai") || msg.contains("Upgrade") || msg.contains("LIMIT_REACHED")) {
           showDialog(
             context: context,
             builder: (ctx) => PremiumLimitDialog(
               message: "Maksimal 5 staff untuk paket Gratis. \nSilakan upgrade untuk menambah lebih banyak staff.",
               onUpgrade: () {
                 // Navigate to Premium Screen
                 Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PremiumMembershipScreen(
                        onViewMembershipPackages: () {
                            // Logic to scroll to packages or handling
                        },
                      ),
                    ),
                 );
               },
             ),
           );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Daftar Akun Staff',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: _isSuccess
            ? StaffSuccessScreen(scaleAnimation: _successScale)
            : _buildForm(bottomInset),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 10, 24, 24),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _saving
                ? null
                : (_isSuccess ? () => Navigator.pop(context) : _submit),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              elevation: 2,
              shadowColor: _primary.withAlpha(89), // 0.35 * 255
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _saving
                  ? const SizedBox(
                      key: ValueKey('prg'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.6,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Text(
                      _isSuccess ? 'Lanjutkan' : 'Simpan',
                      key: ValueKey(_isSuccess ? 'lanjut' : 'simpan'),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(double bottomInset) {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + bottomInset),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const StaffInfoHeader(),
          const SizedBox(height: 24),
          StaffTextField(
            controller: fullnameController,
            label: "Nama Lengkap",
            hint: "Masukkan nama lengkap staff",
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 22),
          StaffTextField(
            controller: usernameController,
            label: "Username",
            hint: "Masukkan username staff",
            icon: Icons.account_circle_outlined,
          ),
          const SizedBox(height: 22),
          StaffTextField(
            controller: emailController,
            label: "Email",
            hint: "Masukkan email staff",
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 22),
          StaffRoleDropdown(
            selectedRole: _selectedRole,
            onChanged: (v) => setState(() => _selectedRole = v),
          ),
          const SizedBox(height: 22),
          StaffTextField(
            controller: specialistController,
            label: "Spesialis",
            hint: "Masukkan bidang spesial staff (opsional)",
            icon: Icons.star_outline,
          ),
          const SizedBox(height: 22),
          StaffTextField(
            controller: jobdeskController,
            label: "Jobdesk",
            hint: "Masukkan detail jobdesk",
            icon: Icons.assignment_outlined,
            maxLines: 3,
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}