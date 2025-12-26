import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

// Screens
import 'add_service_onsite_page.dart';
import 'service_history_page.dart';
import 'service_logging.dart'; // Ensure this exists
import 'service_detail_page.dart';

// Widgets
import '../widgets/service/service_card_admin.dart';

class ServicePageAdmin extends StatefulWidget {
  const ServicePageAdmin({super.key});

  @override
  State<ServicePageAdmin> createState() => _ServicePageAdminState();
}

class _ServicePageAdminState extends State<ServicePageAdmin> with SingleTickerProviderStateMixin {
  // Top Level Tab (Penjadwalan vs Pencatatan) available via simple toggle or tab
  int _mainMode = 0; // 0 = Penjadwalan (Scheduling), 1 = Pencatatan (Logging)

  // Penjadwalan Filters
  String _selectedStatusFilter = 'Semua'; // Semua, Menunggu, Proses, Selesai
  final List<String> _statusFilters = ['Semua', 'Menunggu', 'Proses', 'Selesai'];
  
  // Dummy Data for Penjadwalan
  final List<Map<String, dynamic>> _dummyServices = [
    {
      'customer': 'Siti Aminah',
      'vehicle': 'Beat Street',
      'licensePlate': 'B 4567 ABC',
      'service': 'Servis Rutin',
      'time': '13:15',
      'status': 'Proses',
      'dateHeader': 'Hari Ini', // Grouping key
    },
    {
      'customer': 'Budi Santoso',
      'vehicle': 'Vario 150',
      'licensePlate': 'B 1234 XYZ',
      'service': 'Ganti Oli, Servis CVT',
      'time': '14:30',
      'status': 'Menunggu',
      'dateHeader': 'Hari Ini',
    },
    {
      'customer': 'Ahmad Rizky',
      'vehicle': 'NMAX 155',
      'licensePlate': 'B 9988 DD',
      'service': 'Ganti Ban, Ganti Oli',
      'time': '10:00', // Previous date usually shows date, but design shows time too
      'status': 'Selesai',
      'dateHeader': '09 Okt 2023',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Cleaner gray
      body: Column( // Use Column instead of Sliver for simpler fixed header if preferred, or Stack.
        children: [
          // Custom Gradient Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDarker, AppColors.primaryRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Daftar Servis",
                      style: AppTextStyles.heading3(color: Colors.white),
                    ),
                    Row(
                      children: [
                        _buildHeaderIcon(Icons.history, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ServiceHistoryAdminPage()),
                          );
                        }),
                        const SizedBox(width: 12),
                        _buildHeaderIcon(Icons.add, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddServiceOnSitePage()),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Switch Penjadwalan / Pencatatan - Inside Header for premium look
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildModeToggle('Penjadwalan', 0)),
                      Expanded(child: _buildModeToggle('Pencatatan', 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _mainMode == 0
                ? _buildPenjadwalanView()
                : const ServiceLoggingPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildModeToggle(String title, int index) {
    bool isSelected = _mainMode == index;
    return GestureDetector(
      onTap: () => setState(() => _mainMode = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium(
            color: isSelected ? AppColors.primaryRed : Colors.white.withOpacity(0.9),
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildPenjadwalanView() {
    return SingleChildScrollView(
       physics: const BouncingScrollPhysics(),
       child: Column(
         children: [
           const SizedBox(height: 16),
           // Filter Tabs
           SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _statusFilters.map((filter) {
                bool isSelected = _selectedStatusFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedStatusFilter = filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryRed : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryRed : Colors.grey.shade300,
                        ),
                        boxShadow: isSelected 
                            ? [BoxShadow(color: AppColors.primaryRed.withOpacity(0.3), blurRadius: 4, offset: const Offset(0,2))]
                            : null,
                      ),
                      child: Text(
                        filter,
                        style: AppTextStyles.bodyMedium(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ).copyWith(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Date Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 20, color: AppColors.primaryRed),
                        const SizedBox(width: 12),
                        Text(
                          "1 Okt - 31 Okt 2023",
                          style: AppTextStyles.bodyMedium(color: Colors.black87)
                              .copyWith(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                  ),
                  child: Icon(Icons.display_settings, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // List
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 80),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _groupedServices.length,
            itemBuilder: (context, index) {
              final group = _groupedServices[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(
                           group['header'],
                           style: AppTextStyles.heading5(),
                         ),
                         if (group['header'] == 'Hari Ini')
                           Text(
                             "10 Okt",
                             style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
                           ),
                       ],
                     ),
                  ),
                  ...group['services'].map<Widget>((service) {
                    return ServiceCardAdmin(
                      customerName: service['customer'],
                      vehicleName: service['vehicleName'] ?? 'Kendaraan',
                      licensePlate: service['licensePlate'] ?? 'B 1234 AAA', // Handle null safely
                      serviceType: service['service'],
                      time: service['time'],
                      status: service['status'],
                      isToday: index == 0, // Assuming first group is "Today" for dummy data
                      onTap: () {
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) => const ServiceDetailPage()),
                         );
                      },
                    );
                  }).toList(),
                ],
              );
            },
          ),
         ],
       ),
    );
  }

  // Helper to group items by dateHeader and filter
  List<Map<String, dynamic>> get _groupedServices {
    // 1. Filter
    final filtered = _selectedStatusFilter == 'Semua' 
        ? _dummyServices 
        : _dummyServices.where((s) => s['status'] == _selectedStatusFilter).toList();
    
    // 2. Group
    final List<Map<String, dynamic>> grouped = [];
    final Set<String> headers = filtered.map((e) => e['dateHeader'] as String).toSet();
    
    for (var header in headers) {
      grouped.add({
        'header': header,
        'services': filtered.where((e) => e['dateHeader'] == header).toList(),
      });
    }
    return grouped;
  }
}
