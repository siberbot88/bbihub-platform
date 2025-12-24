import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Order langsung masuk",
      description:
      "Dapatkan notifikasi pesanan servis dari\n pelanggan secara realtime. tidak perlu repot\n cari pelanggan, cukup tunggu order masuk\n dan siap untuk melayaninya",
      image: 'assets/image/gambar_1.png',
      buttonText: "Lanjutkan",
      blobAsset: 'assets/svg/component1.svg',
      blobScale: 0.864,
      blobHorizontalOffset: 0.138,
      blobVerticalOffset: -0.190,
    ),
    OnboardingPage(
      title: "Atur & Monitoring service",
      description:
      "Tentukan jadwal, alokasikan mekanik dan\n pantau progres servis dengan lebih rapi.\nSemua tercatat otomatis di aplikasi.",
      image: 'assets/image/gambar_2.png',
      buttonText: "Lanjutkan",
      blobAsset: 'assets/svg/component2.svg',
      blobScale: 1,
      blobHorizontalOffset: 0,
      blobVerticalOffset: -0.15,
    ),
    OnboardingPage(
      title: "Kembangkan bengkel",
      description:
      "Dapatkan laporan performa bengkel, tren\npermintaan, hingga masukan pelanggan\n untuk meningkatkan kualitas layanan\n dan menumbuhkan bisnis.",
      image: 'assets/image/gambar_3.png',
      buttonText: "Mulai Sekarang",
      blobAsset: 'assets/svg/component3.svg',
      blobScale: 0.96,
      blobHorizontalOffset: 0,
      blobVerticalOffset: -0.2,
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ================================
  // BUILD UTAMA
  // (Tidak Berubah)
  // ================================
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final availableHeight = screenHeight - statusBarHeight - bottomPadding;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ======= PageView dengan animasi smooth dan lazy =======
          PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            itemBuilder: (context, index) {
              final isActive = _currentPage == index;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeOut,
                child: _buildOnboardingPage(
                  _pages[index],
                  screenHeight,
                  screenWidth,
                  statusBarHeight,
                  bottomPadding,
                  isActive,
                  key: ValueKey(index),
                ),
              );
            },
          ),

          // ======= Indikator titik =======
          Positioned(
            bottom: availableHeight * 0.15,
            left: 0,
            right: 0,
            child: _buildPageIndicator(),
          ),

          // ======= Tombol bawah =======
          Positioned(
            bottom: availableHeight * 0.067,
            left: screenWidth * 0.15,
            right: screenWidth * 0.15,
            child: _buildBottomButton(availableHeight, screenWidth),
          ),
        ],
      ),
    );
  }

  // ================================
  // HALAMAN ONBOARDING
  // (Tidak Berubah)
  // ================================
  Widget _buildOnboardingPage(
      OnboardingPage page,
      double screenHeight,
      double screenWidth,
      double statusBarHeight,
      double bottomPadding,
      bool isActive, {
        required Key key,
      }) {
    final availableHeight = screenHeight - statusBarHeight - bottomPadding;
    final topSpacing = statusBarHeight + (availableHeight * 0.12);
    final illustrationHeight = availableHeight * 0.43;
    final illustrationWidth = screenWidth * 0.92;

    return Container(
      key: key,
      child: Column(
        children: [
          SizedBox(height: topSpacing),

          // ===== Blob + Gambar =====
          AnimatedOpacity(
            opacity: isActive ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: SizedBox(
              height: illustrationHeight,
              width: screenWidth,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -illustrationHeight * page.blobVerticalOffset,
                    left: screenWidth * page.blobHorizontalOffset,
                    child: SvgPicture.asset(
                      page.blobAsset,
                      width: screenWidth * page.blobScale,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFDC2626),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Positioned(
                    left: (screenWidth - illustrationWidth) / 2,
                    top: availableHeight * 0.022,
                    child: AnimatedSlide(
                      offset: isActive ? Offset.zero : const Offset(0.1, 0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      child: AnimatedOpacity(
                        opacity: isActive ? 1 : 0,
                        duration: const Duration(milliseconds: 400),
                        child: Image.asset(
                          page.image,
                          width: illustrationWidth,
                          height: illustrationWidth,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: availableHeight * 0.065),

          // ===== Judul =====
          AnimatedOpacity(
            opacity: isActive ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Text(
              page.title,
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF232323),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: availableHeight * 0.024),

          // ===== Deskripsi =====
          AnimatedOpacity(
            opacity: isActive ? 1 : 0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: Text(
                page.description,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.037,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF232323),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // INDIKATOR TITIK
  // (Tidak Berubah)
  // ================================
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: _currentPage == index ? 16 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFFDC2626)
                : const Color(0xFFD9D9D9),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ================================
  // TOMBOL BAWAH (DENGAN PENINGKATAN LOGIKA)
  // ================================
  Widget _buildBottomButton(double availableHeight, double screenWidth) {
    final String buttonText = _pages[_currentPage].buttonText;

    return SizedBox(
      width: screenWidth * 0.7,
      height: availableHeight * 0.052,
      child: ElevatedButton(
        // --- (FUNGSI INI DI-UPGRADE MENJADI ASYNC) ---
        onPressed: () async {
          if (_currentPage == _pages.length - 1) {

            // --- PENINGKATAN LOGIKA ADA DI SINI ---
            // 1. Dapatkan SharedPreferences
            final prefs = await SharedPreferences.getInstance();

            // 2. Simpan flag bahwa onboarding sudah selesai
            await prefs.setBool('hasSeenOnboarding', true);

            // 3. Navigasi ke login SETELAH disimpan
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
            // --- AKHIR PENINGKATAN ---

          } else {
            // (Logika ini tetap sama)
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
            );
          }
        },
        // --- (Sisa widget tidak berubah) ---
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDC2626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(availableHeight * 0.026),
          ),
          elevation: 0,
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.038,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ===================================
// MODEL DATA
// (Tidak Berubah)
// ===================================
class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final String buttonText;
  final String blobAsset;
  final double blobScale;
  final double blobHorizontalOffset;
  final double blobVerticalOffset;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.buttonText,
    required this.blobAsset,
    required this.blobScale,
    required this.blobHorizontalOffset,
    required this.blobVerticalOffset,
  });
}