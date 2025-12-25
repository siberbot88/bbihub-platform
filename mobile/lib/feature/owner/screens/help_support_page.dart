import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bengkel_online_flutter/theme/app_theme.dart';
import '../widgets/custom_header.dart';
import 'live_chat_page.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage>
    with TickerProviderStateMixin {
  final _searchC = TextEditingController();
  
  // FAQ Data (Bahasa Indonesia)
  final List<_FaqItem> _allFaqs = const [
    _FaqItem(
      q: "Bagaimana cara mengubah profil bengkel?",
      a: "Masuk ke menu 'Profil', lalu tekan tombol 'Edit Profil'. Anda dapat mengubah foto, alamat, dan jam operasional di sana.",
    ),
    _FaqItem(
      q: "Bagaimana cara mencetak laporan keuangan?",
      a: "Buka menu 'Laporan', pilih periode yang diinginkan, lalu tekan tombol 'Cetak Laporan' di bagian bawah layar. Pastikan Anda memiliki paket Premium.",
    ),
    _FaqItem(
      q: "Apa yang harus dilakukan jika ada komplain pelanggan?",
      a: "Anda dapat melihat detail komplain di menu 'Riwayat Service'. Hubungi pelanggan melalui fitur chat atau telepon yang tersedia untuk penyelesaian.",
    ),
    _FaqItem(
      q: "Bagaimana cara menambah mekanik baru?",
      a: "Pergi ke menu 'Manajemen Staff', tekan tombol '+', dan isi data diri mekanik. Mekanik akan menerima email untuk login.",
    ),
    _FaqItem(
      q: "Apakah data transaksi saya aman?",
      a: "Ya, kami menggunakan enkripsi standar industri untuk melindungi semua data transaksi dan informasi pribadi Anda.",
    ),
    _FaqItem(
      q: "Bagaimana cara mengelola layanan bengkel?",
      a: "Buka menu 'Layanan', Anda dapat menambah, mengedit, atau menghapus layanan. Setiap layanan dapat diatur harganya dan ditampilkan ke pelanggan.",
    ),
    _FaqItem(
      q: "Apakah ada batasan jumlah staff untuk paket gratis?",
      a: "Ya, paket gratis dibatasi maksimal 2 staff. Untuk menambah lebih banyak staff, silakan upgrade ke paket Premium.",
    ),
    _FaqItem(
      q: "Bagaimana cara mengaktifkan trial membership?",
      a: "Setelah registrasi, Anda akan ditawarkan trial 7 hari gratis. Klik 'Mulai Trial' dan lengkapi proses checkout Rp 0. Setelah trial berakhir, Anda akan ditagih otomatis.",
    ),
    _FaqItem(
      q: "Bagaimana cara membatalkan membership?",
      a: "Masuk ke menu 'Membership', pilih paket aktif, lalu klik 'Batalkan Langganan'. Anda tetap dapat menggunakan fitur premium hingga akhir periode billing.",
    ),
    _FaqItem(
      q: "Apa perbedaan antara Admin dan Mekanik?",
      a: "Admin memiliki akses penuh ke keuangan dan laporan, sedangkan Mekanik fokus pada pengelolaan service dan tugas perbaikan. Pilih role sesuai tanggung jawab staff.",
    ),
    _FaqItem(
      q: "Bagaimana cara mengatur jam operasional bengkel?",
      a: "Di menu 'Profil Bengkel', edit jam buka dan tutup serta hari operasional. Informasi ini akan ditampilkan kepada pelanggan.",
    ),
    _FaqItem(
      q: "Apakah saya bisa melihat performa staff?",
      a: "Ya, menu 'Staff' menyediakan data performa setiap staff termasuk jumlah service yang ditangani dan rating dari pelanggan.",
    ),
    _FaqItem(
      q: "Bagaimana cara menangani pembayaran dari pelanggan?",
      a: "Sistem terintegrasi dengan metode pembayaran digital. Pelanggan dapat bayar langsung di aplikasi, dan Anda akan menerima notifikasi real-time.",
    ),
    _FaqItem(
      q: "Apakah ada fitur untuk backup data?",
      a: "Data otomatis ter-backup di cloud server kami setiap hari. Anda juga bisa export laporan dalam format PDF untuk arsip manual.",
    ),
    _FaqItem(
      q: "Bagaimana jika lupa password?",
      a: "Klik 'Lupa Password' di halaman login, masukkan email Anda, dan ikuti instruksi reset password yang dikirim ke email.",
    ),
    _FaqItem(
      q: "Apakah workshop saya bisa terlihat di pencarian pelanggan?",
      a: "Ya, workshop Anda otomatis muncul di aplikasi pelanggan berdasarkan lokasi dan layanan yang ditawarkan. Pastikan profil workshop lengkap.",
    ),
    _FaqItem(
      q: "Bagaimana cara mengatur harga layanan?",
      a: "Di menu 'Layanan', pilih layanan yang ingin diatur, lalu masukkan harga. Anda bisa set harga berbeda untuk setiap jenis kendaraan atau layanan.",
    ),
    _FaqItem(
      q: "Apakah saya bisa lihat riwayat transaksi?",
      a: "Ya, semua transaksi tercatat di menu 'Laporan' dengan filter berdasarkan tanggal, status, dan jenis pembayaran untuk memudahkan monitoring.",
    ),
    _FaqItem(
      q: "Bagaimana cara menghubungi customer support?",
      a: "Anda bisa email ke support@bbihub.com atau gunakan fitur 'Hubungi Kami' di tab ini. Kami siap membantu 24/7.",
    ),
  ];

  List<_FaqItem> _filteredFaqs = [];
  int _expandedIndex = -1; // Default tertutup semua
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _filteredFaqs = _allFaqs;
    _tabController = TabController(length: 2, vsync: this);
    _searchC.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchC.text.toLowerCase();
    setState(() {
      _filteredFaqs = _allFaqs.where((item) {
        return item.q.toLowerCase().contains(query) || 
               item.a.toLowerCase().contains(query);
      }).toList();
      _expandedIndex = -1; // Reset ekspansi saat search berubah
    });
  }

  @override
  void dispose() {
    _searchC.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      // Menggunakan CustomHeader sesuai request (pastikan import benar)
      appBar: const CustomHeader(
        title: "Bantuan & Dukungan",
      ),
      body: Column(
        children: [
          // Custom Tab Bar Container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFFD72B1C),
                borderRadius: BorderRadius.circular(21),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD72B1C).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "FAQ"),
                Tab(text: "Hubungi Kami"),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ======= TAB: FAQ =======
                _buildFaqTab(context, isDark),

                // ======= TAB: Hubungi Kami =======
                _buildContactTab(context, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTab(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          
          // Search Bar Smooth
          _SearchField(controller: _searchC, isDark: isDark),
          
          const SizedBox(height: 16),

          // FAQ List with Animation
          Expanded(
            child: _filteredFaqs.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text("Tidak ditemukan hasil", style: TextStyle(color: Colors.grey[500])),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredFaqs.length,
                  padding: const EdgeInsets.only(bottom: 24),
                  itemBuilder: (ctx, i) {
                    final item = _filteredFaqs[i];
                    final isExpanded = _expandedIndex == i;
                    
                    return _FaqCard(
                      item: item,
                      isExpanded: isExpanded,
                      isDark: isDark,
                      onTap: () {
                        setState(() {
                          _expandedIndex = (isExpanded) ? -1 : i;
                        });
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Butuh bantuan lebih lanjut?",
            style: AppTheme.heading(context: context, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            "Tim support kami siap membantu Anda 24/7.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          _ContactCard(
            label: "Email Support",
            value: "support@bbihub.com",
            icon: Icons.email_rounded,
            color: Colors.blueAccent,
            isDark: isDark,
            onTap: () {
              // Implementasi launch url email
            },
          ),
          const SizedBox(height: 16),
          
          _ContactCard(
            label: "WhatsApp / Telepon",
            value: "+62 812 3456 7890",
            icon: Icons.chat_bubble_rounded,
            color: Colors.green,
            isDark: isDark,
            onTap: () {
              // Implementasi launch url wa
            },
          ),
          const SizedBox(height: 16),
          
          _ContactCard(
            label: "Jam Operasional Live Chat",
            value: "Senin - Minggu (08:00 - 22:00 WIB)",
            icon: Icons.access_time_filled_rounded,
            color: Colors.orange,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LiveChatPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* ====================== Widgets ====================== */

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  
  const _SearchField({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.manrope(fontSize: 14, color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: isDark ? Colors.grey[400] : Colors.grey[500]),
          hintText: "Cari topik bantuan...",
          hintStyle: GoogleFonts.manrope(color: Colors.grey[500], fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          border: InputBorder.none,
          suffixIcon: controller.text.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: controller.clear,
              )
            : null,
        ),
      ),
    );
  }
}

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});
}

class _FaqCard extends StatelessWidget {
  final _FaqItem item;
  final bool isExpanded;
  final bool isDark;
  final VoidCallback onTap;

  const _FaqCard({
    required this.item,
    required this.isExpanded,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? AppTheme.primary.withValues(alpha: 0.3) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(isExpanded ? 0.08 : 0),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          if (!isExpanded)
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppTheme.primary.withValues(alpha: 0.05),
          highlightColor: AppTheme.primary.withValues(alpha: 0.02),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.q,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isExpanded 
                              ? AppTheme.primary 
                              : (isDark ? Colors.white : const Color(0xFF1A0E0E)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isExpanded ? AppTheme.primary : Colors.grey,
                      ),
                    ),
                  ],
                ),
                // Smooth content expansion
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      item.a,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        height: 1.5,
                        color: isDark ? Colors.grey[300] : const Color(0xFF4A4A4A),
                      ),
                    ),
                  ),
                  crossFadeState: isExpanded 
                      ? CrossFadeState.showSecond 
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  const _ContactCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: GoogleFonts.manrope(
                              fontSize: 12, 
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(value,
                          style: GoogleFonts.manrope(
                              fontSize: 15, 
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1A0E0E))),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios_rounded, 
                      size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
