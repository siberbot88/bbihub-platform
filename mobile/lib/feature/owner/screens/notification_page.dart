
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/core/theme/app_colors.dart';
import 'package:bengkel_online_flutter/core/widgets/custom_alert.dart';
import 'package:bengkel_online_flutter/core/services/notification_provider.dart';
import 'package:bengkel_online_flutter/core/models/notification_model.dart';
import '../widgets/custom_header.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/list_work.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Refresh on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
      context.read<NotificationProvider>().markAsRead('all'); // Optional: Mark all read on open? Or manual?
      // Let's keep manual mark read for individual items or specific action
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F5),
      appBar: CustomHeader(
        title: 'Notifikasi',
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            tooltip: 'Tandai semua sudah dibaca',
            onPressed: () {
               context.read<NotificationProvider>().markAsRead('all');
               CustomAlert.show(
                 context,
                 title: 'Berhasil',
                 message: 'Semua notifikasi ditandai sudah dibaca',
                 type: AlertType.success,
               );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryRed,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primaryRed,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: "Semua"),
                Tab(text: "Operasional"),
                Tab(text: "Info/Laporan"),
              ],
            ),
          ),
          Expanded(
            child: Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.notifications.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Belum ada notifikasi', style: GoogleFonts.poppins(color: Colors.grey[500])),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(provider.notifications),
                    _buildList(provider.notifications.where((n) => 
                        ['transaction', 'task_assignment', 'task_completed', 'service_logged', 'booking']
                        .contains(n.type)).toList()),
                    _buildList(provider.notifications.where((n) => 
                        ['report_ready', 'reminder', 'system', 'feedback_received', 'voucher_active']
                        .contains(n.type)).toList()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<NotificationModel> list) {
    if (list.isEmpty) {
      return Center(child: Text("Tidak ada notifikasi", style: GoogleFonts.poppins(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<NotificationProvider>().fetchNotifications();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final notif = list[index];
          return _NotificationCard(notif: notif);
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notif;

  const _NotificationCard({required this.notif});

  IconData _getIcon() {
    switch (notif.type) {
      case 'transaction': return Icons.receipt_long;
      case 'task_assignment': return Icons.assignment_ind;
      case 'task_completed': return Icons.check_circle_outline;
      case 'report_ready': return Icons.analytics_outlined;
      case 'service_logged': return Icons.build;
      case 'booking': return Icons.calendar_today;
      case 'system': return Icons.info_outline;
      default: return Icons.notifications;
    }
  }

  Color _getColor() {
    switch (notif.type) {
      case 'report_ready': return Colors.purple;
      case 'task_assignment': return Colors.orange;
      case 'task_completed': return Colors.green;
      case 'transaction': return Colors.blue;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: notif.isRead ? Colors.white : const Color(0xFFFFF9F9), // Slight red tint for unread
      child: InkWell(
        onTap: () {
          if (!notif.isRead) {
            context.read<NotificationProvider>().markAsRead(notif.id);
          }
          
          // Navigation Logic (Jumper)
          if (notif.data != null && notif.data!['screen'] == 'service_detail') {
             // Example: Navigate to Service Detail (Replace with actual route if available)
             Navigator.pushNamed(context, '/work-list'); // Assuming '/work-list' or similar
          } else if (notif.type == 'task_assignment' || notif.type == 'service_logged') {
             // Fallback for Admin Service types
             Navigator.push(
               context,
               MaterialPageRoute(builder: (_) => const ListWorkPage()), // Import needed? already imported?
             );
          } else {
             // Default handling
             CustomAlert.show(
               context,
               title: 'Info',
               message: 'Detail untuk ${notif.title} belum tersedia.',
               type: AlertType.info,
             );
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getColor().withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_getIcon(), color: _getColor(), size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: GoogleFonts.poppins(
                              fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 14,
                              color: notif.isRead ? Colors.black87 : Colors.black,
                            ),
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.message,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notif.timeAgo,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
