import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'service_page.dart';
import '../widgets/dashboard/admin_mini_dashboard.dart';
import '../widgets/dashboard/admin_quick_menu.dart';

import 'package:provider/provider.dart';
import '../providers/admin_analytics_provider.dart';
import '../services/banner_service.dart' as banner_svc;

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

  List<banner_svc.Banner> banners = []; // Will hold Banner objects from API
  banner_svc.Banner? characterImage;
  bool isLoadingBanners = true;
  bool autoScroll = true;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
    
    // Fetch dashboard stats on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminAnalyticsProvider>().fetchQuickStats();
    });
  }

  Future<void> _fetchBanners() async {
    setState(() => isLoadingBanners = true);
    
    try {
      final fetchedBanners = await banner_svc.BannerService.getAdminHomepageBanners();
      final fetchedCharacter = await banner_svc.BannerService.getAdminCharacterImage();
      
      if (mounted) {
        setState(() {
          banners = fetchedBanners;
          characterImage = fetchedCharacter;
          isLoadingBanners = false;
        });
        
        // Start auto-scroll after banners loaded
        if (autoScroll && banners.isNotEmpty) {
          _startAutoScroll();
        }
      }
    } catch (e) {
      print('Error loading banners: $e');
      if (mounted) {
        setState(() => isLoadingBanners = false);
      }
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || banners.isEmpty) return;
      final next = (_currentBannerIndex + 1) % banners.length;
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      }
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
          await Future.wait([
            context.read<AdminAnalyticsProvider>().fetchQuickStats(),
            _fetchBanners(),
          ]);
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
                              const AdminMiniDashboard(),
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

                    const SizedBox(height: 16),

                    // Banner PageView - Modern Design
                    SizedBox(
                      height: 320,
                      child: isLoadingBanners
                          ? Center(
                              child: CircularProgressIndicator(
                                color: primaryRed,
                                strokeWidth: 3,
                              ),
                            )
                          : banners.isEmpty
                              ? Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Colors.grey[50],
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported_outlined,
                                          size: 64,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Belum ada banner promo',
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Banner akan ditampilkan di sini',
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : PageView.builder(
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
                                        left: 4,
                                        right: index == banners.length - 1 ? 4 : 16,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 16,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              b.imageUrl,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  color: Colors.grey[100],
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                              loadingProgress.expectedTotalBytes!
                                                          : null,
                                                      color: primaryRed,
                                                      strokeWidth: 3,
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    gradient: _getBannerGradient(index),
                                                  ),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(24.0),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.broken_image_rounded,
                                                            color: Colors.white.withOpacity(0.9),
                                                            size: 56,
                                                          ),
                                                          const SizedBox(height: 16),
                                                          Text(
                                                            b.title,
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 18,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                          if (b.description != null) ...[
                                                            const SizedBox(height: 8),
                                                            Text(
                                                              b.description!,
                                                              style: TextStyle(
                                                                color: Colors.white.withOpacity(0.85),
                                                                fontSize: 13,
                                                              ),
                                                              textAlign: TextAlign.center,
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            // Subtle gradient overlay
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withOpacity(0.1),
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
                    ),

                    const SizedBox(height: 16),

                    // Modern Dots indicator
                    if (banners.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(banners.length, (i) {
                          final isActive = _currentBannerIndex == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive ? primaryRed : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: primaryRed.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),

                    const SizedBox(height: 32),
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
