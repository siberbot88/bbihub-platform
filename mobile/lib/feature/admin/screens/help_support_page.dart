import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bengkel_online_flutter/theme/app_theme.dart';
import '../widgets/custom_header.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage>
    with TickerProviderStateMixin {
  final _searchC = TextEditingController();

  // FAQ Data (Admin Context)
  final List<_FaqItem> _allFaqs = const [
    _FaqItem(
      q: "Bagaimana cara menerima pesanan baru?",
      a: "Buka menu 'Pesanan', pilih tiket dengan status 'Pending'. Cek detail keluhan, lalu tekan tombol 'Terima' jika bengkel siap mengerjakannya.",
    ),
    _FaqItem(
      q: "Bagaimana cara menugaskan mekanik?",
      a: "Setelah pesanan diterima, sistem akan meminta Anda memilih mekanik. Pilih mekanik yang statusnya 'Available' atau memiliki antrian paling sedikit.",
    ),
    _FaqItem(
      q: "Apa yang harus dilakukan jika pelanggan membatalkan?",
      a: "Jika pelanggan membatalkan sebelum konfirmasi, pesanan otomatis hilang. Jika pembatalan terjadi saat pengerjaan, hubungi Owner untuk kebijakan refund (jika ada).",
    ),
    _FaqItem(
      q: "Bagaimana cara update status pengerjaan?",
      a: "Status akan otomatis berubah saat mekanik menekan 'Mulai' atau 'Selesai' di aplikasi mereka. Admin hanya memantau progress lewat dashboard.",
    ),
    _FaqItem(
      q: "Cara melihat riwayat servis bulanan?",
      a: "Masuk ke menu 'Riwayat'. Anda bisa memfilter berdasarkan tanggal, status, atau nama pelanggan untuk kebutuhan rekap.",
    ),
  ];

  List<_FaqItem> _filteredFaqs = [];
  int _expandedIndex = -1;
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
      _expandedIndex = -1;
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
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomHeader(
        title: "Pusat Bantuan Admin",
      ),
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.cardDark : Colors.white,
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
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(21),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
              labelStyle: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "FAQ"),
                Tab(text: "Hubungi Owner"),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFaqTab(context, isDark, textColor),
                _buildContactTab(context, isDark, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTab(BuildContext context, bool isDark, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _SearchField(controller: _searchC, isDark: isDark),
          const SizedBox(height: 16),
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

  Widget _buildContactTab(BuildContext context, bool isDark, Color? textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kendala Operasional?",
            style: AppTheme.heading(context: context, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            "Hubungi Owner atau Super Admin jika ada masalah sistem.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          _ContactCard(
            label: "Hubungi Owner",
            value: "owner@bengkel.com",
            icon: Icons.person_rounded,
            color: Colors.blueAccent,
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(height: 16),
          
          _ContactCard(
            label: "IT Support (Pusat)",
            value: "+62 812 3456 7890",
            icon: Icons.support_agent_rounded,
            color: Colors.redAccent,
            isDark: isDark,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/* ====================== Widgets (Reused) ====================== */

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
          hintText: "Cari topik admin...",
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
