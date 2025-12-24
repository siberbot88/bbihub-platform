import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/core/services/auth_provider.dart';

class LoadingGate extends StatefulWidget {
  const LoadingGate({super.key});

  @override
  State<LoadingGate> createState() => _LoadingGateState();
}

class _LoadingGateState extends State<LoadingGate>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _logoController;
  late final AnimationController _loadingController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animations then bootstrap
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 100));
    _logoController.forward();

    // Wait a bit before checking auth
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    await auth.checkLoginStatus();
    if (!mounted) return;

    // Small delay to let animations complete
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    if (auth.isLoggedIn) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (_) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with scale and fade animation
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withAlpha(20),
                          blurRadius: 40,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withAlpha(6),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/icons/logo_splash.png',
                      width: 70,
                      height: 70,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App title with fade
              FadeTransition(
                opacity: _textFade,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF1A1A1A),
                            Color(0xFF404040),
                          ],
                        ).createShader(bounds);
                      },
                      child: const Text(
                        'BBI Hub',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.0,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) {
                        return const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF9B0D0D),
                            Color(0xFFDC2626),
                          ],
                        ).createShader(bounds);
                      },
                      child: const Text(
                        '+',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Status text
              FadeTransition(
                opacity: _textFade,
                child: const Text(
                  'Menyiapkan akun dan data Anda',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF999999),
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 40),

              // Loading indicator
              FadeTransition(
                opacity: _textFade,
                child: _LoadingDots(controller: _loadingController),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Loading dots indicator (same as splash screen)
class _LoadingDots extends StatelessWidget {
  final AnimationController controller;

  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              final delay = index * 0.15;
              final value = (controller.value + delay) % 1.0;
              final bounce = (value < 0.5)
                  ? Curves.easeOut.transform(value * 2)
                  : Curves.easeIn.transform((1 - value) * 2);

              return Transform.translate(
                offset: Offset(0, -bounce * 12),
                child: child,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF9B0D0D),
                    Color(0xFFDC2626),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDC2626).withAlpha(40),
                    blurRadius: 6,
                    spreadRadius: 0,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
