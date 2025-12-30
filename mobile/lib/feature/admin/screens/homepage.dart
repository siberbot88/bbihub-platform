import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'service_page.dart';
import '../widgets/dashboard/admin_mini_dashboard.dart';
import '../widgets/dashboard/admin_quick_menu.dart';

const Color primaryRed = Color(0xFFB70F0F);
const Color gradientRedStart = Color(0xFF9B0F0D);
const Color gradientRedEnd = Color(0xFFB70F0F);

// Admin Homepage - Modern redesign matching owner homepage
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController = PageController();
  Timer? _autoScrollTimer;
  int _currentBannerIndex = 0;

  final List<BannerData> banners = [
    BannerData(imagePath: 'assets/image/banner1.png'),
    BannerData(imagePath: 'assets/image/banner2.png'),
    BannerData(imagePath: 'assets/image/banner3.png'),
    BannerData(imagePath: 'assets/image/banner4.png'),
  ];

  bool autoScroll = true;

  @override
  void initState() {
    super.initState();
    if (autoScroll) _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || banners.isEmpty) return;
      final next = (_currentBannerIndex + 1) % banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _bannerController.dispose();
    super.dispose();
  }

  LinearGradient _getBannerGradient(int index) {
    switch (index % 5) {
      case 0:
        return const LinearGradient(
            colors: [Color(0xFFDC2626), Color(0xFF991B1B)]);
      case 1:
        return const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)]);
      case 2:
        return const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF047857)]);
      case 3:
        return const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)]);
      case 4:
      default:
        return const LinearGradient(
            colors: [Color(0xFFEA580C), Color(0xFFC2410C)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final now = DateTime.now();
    final days = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
                     'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    final tanggal = '${days[now.weekday]}, ${now.day} ${months[now.month]} ${now.year}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          // Add refresh logic here
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              backgroundColor: gradientRedStart,
              pinned: true,
              expandedHeight: 400,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4A0909), // Dark maroon
                        Color(0xFF8B1A1A), // Maroon
                        Color(0xFF9B0D0D), // Red-maroon
                        Color(0xFFB70F0F), // Red
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Workshop ornament decorations (subtle)
                      Positioned(
                        left: 20,
                        top: 80,
                        child: Transform.rotate(
                          angle: -0.3,
                          child: Icon(
                            Icons.build,
                            size: 60,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 40,
                        bottom: 100,
                        child: Transform.rotate(
                          angle: 0.5,
                          child: Icon(
                            Icons.settings,
                            size: 80,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 100,
                        top: 120,
                        child: Icon(
                          Icons.handyman,
                          size: 50,
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                      Positioned(
                        left: 80,
                        top: 200,
                        child: Transform.rotate(
                          angle: 0.8,
                          child: Icon(
                            Icons.construction,
                            size: 45,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 150,
                        bottom: 50,
                        child: Icon(
                          Icons.engineering,
                          size: 55,
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                      // Marquez character image
                      Positioned(
                        right: -20,
                        bottom: 0,
                        child: Image.asset(
                          'assets/image/marquez.png',
                          height: 339,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(),
                        ),
                      ),
                      // Notification badge
                      Positioned(
                        right: 20,
                        top: 60,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      // Main content
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'BBI HUB +',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Dashboard Admin',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Hallo, Admin',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                tanggal,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 20),
                              const Spacer(),
                              const AdminMiniDashboard(
                                servisHariIni: '24',
                                perluAssign: '12',
                                feedback: '5',
                                selesai: '2',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // BODY
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Menu Cepat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AdminQuickMenu(
                      onTapRiwayat: () {},
                      onTapTerimaJadwal: () {},
                      onTapFeedback: () {},
                    ),
                    const SizedBox(height: 28),

                    // Warning card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ServicePageAdmin(),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: Image.asset(
                                  'assets/icons/antrian.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Color(0xFF5C36F4),
                                    size: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Cek list antrian pelanggan kamu!!",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Klik tombol dibawah ini untuk masuk menu Service",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Banner carousel section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Promo & Banner',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Banner PageView
                    SizedBox(
                      height: 300,
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: _bannerController,
                            itemCount: banners.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentBannerIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final b = banners[index];
                              return Container(
                                margin: EdgeInsets.only(
                                  right: index == banners.length - 1 ? 0 : 12,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        b.imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              gradient: _getBannerGradient(index),
                                            ),
                                            child: const Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 14.0,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withAlpha(115)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Progress indicator
                          Positioned(
                            top: 8,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: LinearProgressIndicator(
                                value: banners.isEmpty
                                    ? 0
                                    : (_currentBannerIndex + 1) / banners.length,
                                color: primaryRed,
                                backgroundColor: primaryRed.withAlpha(31),
                                minHeight: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(banners.length, (i) {
                        final isActive = _currentBannerIndex == i;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isActive ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? primaryRed
                                : Colors.grey.withAlpha(64),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Banner data model
class BannerData {
  final String imagePath;
  BannerData({required this.imagePath});
}
