import 'package:bengkel_online_flutter/core/theme/app_colors.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class WorkshopVerificationWaitingPage extends StatefulWidget {
  const WorkshopVerificationWaitingPage({super.key});

  @override
  State<WorkshopVerificationWaitingPage> createState() => _WorkshopVerificationWaitingPageState();
}

class _WorkshopVerificationWaitingPageState extends State<WorkshopVerificationWaitingPage> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print("WorkshopVerification: initState call");
    }
    _controller = AnimationController(
      duration: const Duration(seconds: 1), // Faster rotation
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      
      // Force refresh user data from server
      await auth.checkLoginStatus();

      if (!mounted) return;
      
      // Check if workshop is now verified
      final workshops = auth.user?.workshops;
      if (workshops != null && workshops.isNotEmpty) {
        final workshop = workshops.first;
        if (kDebugMode) {
          print('Workshop status: ${workshop.status}');
        }
        
        if (workshop.status == 'verified' || workshop.status == 'active') {
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bengkel Anda sudah diverifikasi! ✅'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            
            // Wait a bit for user to see the message
            await Future.delayed(const Duration(seconds: 1));
            
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
            }
          }
        } else {
          // Still not verified, show message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Status: ${workshop.status}. Masih dalam proses verifikasi.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking status: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memeriksa status. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final workshop = auth.user?.workshops?.firstOrNull;
    final workshopName = workshop?.name ?? 'Bengkel Anda';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Waiting Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryRed.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: RotationTransition(
                    turns: _controller,
                    child: Icon(
                      Icons.hourglass_empty,
                      size: 60,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Menunggu Verifikasi Bengkel',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Workshop Name
                Text(
                  workshopName,
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.primaryRed,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Description
                Text(
                  'Bengkel Anda sedang dalam proses verifikasi oleh tim kami. '
                  'Proses ini biasanya memakan waktu 1-3 hari kerja.\n\n'
                  'Anda akan menerima notifikasi melalui email setelah bengkel Anda diverifikasi.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Check Status Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _checkStatus,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.refresh, color: Colors.white),
                    label: Text(
                      _isLoading ? 'Memeriksa...' : 'Cek Status Verifikasi',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Logout Button
                TextButton.icon(
                  onPressed: () async {
                    await auth.logout();
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                  },
                  icon: const Icon(Icons.logout, color: Colors.grey),
                  label: const Text(
                    'Keluar',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
