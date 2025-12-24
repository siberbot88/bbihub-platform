import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/core/services/auth_provider.dart';
import 'package:bengkel_online_flutter/core/providers/service_provider.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/list_work.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/staff_management.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/report_pages.dart';
import '../widgets/dashboard/dashboard_helpers.dart';
import '../widgets/dashboard/owner_mini_dashboard.dart';
import '../widgets/dashboard/owner_quick_menu.dart';
import '../widgets/dashboard/owner_job_card.dart';
import 'package:bengkel_online_flutter/features/membership/presentation/premium_membership_screen.dart';
import 'package:bengkel_online_flutter/features/membership/presentation/membership_selection_screen.dart';
import 'package:bengkel_online_flutter/core/widgets/trial_offer_banner.dart';
import 'package:bengkel_online_flutter/core/services/api_service.dart';
import 'package:bengkel_online_flutter/feature/owner/widgets/notification_badge.dart';

const Color primaryRed = Color(0xFFB70F0F);
const Color gradientRedStart = Color(0xFF9B0D0D);
const Color gradientRedEnd = Color(0xFFB70F0F);


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  SummaryRange _range = SummaryRange.today;

  @override
  void initState() {
    super.initState();
    // ambil data service saat dashboard dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final wsId = pickWorkshopUuid(auth.user);
      context.read<ServiceProvider>().fetchServices(
        workshopUuid: wsId,
        includeExtras: true,
        page: 1,
        perPage: 50,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final auth = context.watch<AuthProvider>();
    final userName = auth.user?.name ?? auth.user?.username ?? 'Owner';

    final now = DateTime.now();
    final tanggal =
        '${dayNameId(now.weekday)}, ${now.day} ${monthNameId(now.month)} ${now.year}';

    final serviceProv = context.watch<ServiceProvider>();
    final services = serviceProv.items;

    final summary = buildSummary(services, _range);
    final latest = services.take(5).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
            // 1. Force sync subscription status
            try {
              await ApiService().checkSubscriptionStatus();
            } catch (_) {}
            
            // 2. Refresh user data (for UI badges)
            await auth.checkLoginStatus();

            // 3. Refresh services
            final wsId = pickWorkshopUuid(auth.user);
            await context.read<ServiceProvider>().fetchServices(
              workshopUuid: wsId,
              includeExtras: true,
              page: 1,
              perPage: 50,
            );
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              backgroundColor: gradientRedStart,
              pinned: true,
              expandedHeight: 420,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [gradientRedStart, gradientRedEnd],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -20,
                        bottom: 0,
                        child: Image.asset(
                          'assets/image/marquez.png',
                          height: 359,
                        ),
                      ),
                      const Positioned(
                         right: 20,
                         top: 60, // Adjust based on SafeArea/AppBar height
                         child: NotificationBadge(),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (auth.user?.isPremium ?? false)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(50),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                            color: Colors.amber, width: 1.5),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.verified,
                                            color: Colors.amber,
                                            size: 16,
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            'Premium Member',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
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
                                        const SizedBox(width: 8), // Spacer
                                        InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    PremiumMembershipScreen(
                                                  isViewOnly: false,
                                                  onViewMembershipPackages: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            const MembershipSelectionScreen(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withAlpha(50),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.amber,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.workspace_premium_rounded,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  Spacer(),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Dashboard Owner',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Hallo, $userName',
                                style: const TextStyle(
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
                              OwnerMiniDashboard(
                                range: _range,
                                onRangeChanged: (r) =>
                                    setState(() => _range = r),
                                pendapatan: summary.revenue,
                                totalJob: summary.totalJob,
                                totalSelesai: summary.totalDone,
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
                    // Trial Offer Banner
                    const TrialOfferBanner(),
                    const Text(
                      'Menu Cepat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OwnerQuickMenuRow(onTapPekerjaan: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListWorkPage(),
                        ),
                      );
                    }, onTapKaryawan: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManajemenKaryawanPage(),
                        ),
                      );
                    }, onTapLaporan: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportPage(),
                        ),
                      );
                    }),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pekerjaan Terbaru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ListWorkPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Lihat semua',
                            style: TextStyle(color: primaryRed),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (serviceProv.loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (latest.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text('Belum ada pekerjaan'),
                        ),
                      )
                    else
                      Column(
                        children: latest.map((s) {
                          final c = s.customer;
                          final v = s.vehicle;
                          final vehicleText = [
                            if ((v?.brand ?? '').isNotEmpty) v!.brand,
                            if ((v?.model ?? '').isNotEmpty) v!.model,
                            if ((v?.year ?? '').toString().isNotEmpty)
                              v!.year.toString(),
                            if ((v?.plateNumber ?? '').isNotEmpty)
                              '- ${v!.plateNumber}',
                          ].whereType<String>().join(' ');
  
                          return OwnerJobCard(
                            orderId: s.code,
                            name: c?.name ?? '-',
                            vehicle: vehicleText.isEmpty ? '-' : vehicleText,
                            service: s.name,
                            timeAgo: timeAgo(s.createdAt ?? s.scheduledDate),
                            status: statusLabel(s.status),
                            statusColor: statusColor(s.status),
                            showRating:
                            s.status.toLowerCase() == 'completed',
                          );
                        }).toList(),
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

/* ===================== END OF MAIN SCREEN ===================== */
