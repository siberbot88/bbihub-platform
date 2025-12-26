import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ServiceHistoryAdminPage extends StatefulWidget {
  const ServiceHistoryAdminPage({super.key});

  @override
  State<ServiceHistoryAdminPage> createState() => _ServiceHistoryAdminPageState();
}

class _ServiceHistoryAdminPageState extends State<ServiceHistoryAdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ["Harian", "Mingguan", "Bulanan"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          "Riwayat Servis",
          style: AppTextStyles.heading4(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Tab Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30), // Pill shape based on design
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                  )
                ],
              ),
              labelColor: AppColors.primaryRed,
              unselectedLabelColor: Colors.grey,
              labelStyle: AppTextStyles.bodyMedium().copyWith(fontWeight: FontWeight.bold),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filter Bar
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16),
             child: Row(
               children: [
                 Expanded(
                   child: Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(8),
                       border: Border.all(color: AppColors.border),
                     ),
                     child: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Row(
                           children: [
                             const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                             const SizedBox(width: 8),
                             Text("26 Oktober 2023", style: AppTextStyles.bodyMedium()),
                           ],
                         ),
                         const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                       ],
                     ),
                   ),
                 ),
                 const SizedBox(width: 8),
                 Container(
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(8),
                     border: Border.all(color: AppColors.border),
                   ),
                   child: const Icon(Icons.filter_list, color: Colors.black),
                 ),
                 const SizedBox(width: 8),
                 Container(
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(
                     color: AppColors.primaryRed,
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: const Icon(Icons.download, color: Colors.white),
                 ),
               ],
             ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(isDaily: true),
                _buildList(),
                _buildList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper for animated list item
  Widget _buildAnimatedItem(Widget child, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)), // Staggered delay effect
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)), // Slide up
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildList({bool isDaily = false}) {
    // Dummy Data
    final services = [
      {
        'name': 'Dimas Anggara',
        'vehicle': 'Vario 125 • B 3456 TUV',
        'service': 'Ganti Oli, Kampas Rem',
        'time': 'Selesai: 14:30',
        'price': 'Rp 185.000',
        'status': 'Selesai',
      },
      {
        'name': 'Rina Wati',
        'vehicle': 'Scoopy • B 1122 RRR',
        'service': 'Servis Rutin',
        'time': 'Selesai: 11:15',
        'price': 'Rp 75.000',
        'status': 'Selesai',
      },
       {
        'name': 'Budi Santoso',
        'vehicle': 'NMAX 155 • B 9988 DD',
        'service': 'Ganti Ban Belakang',
        'time': 'Selesai: 16:45',
        'price': 'Rp 350.000',
        'status': 'Selesai',
        'date': '25 Oktober 2023' // Different date
      },
       {
        'name': 'Kevin Sanjaya',
        'vehicle': 'Aerox 155 • B 6789 KL',
        'service': 'Modifikasi CVT',
        'time': '',
        'price': '',
        'status': 'Dibatalkan',
        'reason': 'Oleh Pelanggan'
      },
       // Add more dummy data for scrolling effect
       {
        'name': 'Andi Pratama',
        'vehicle': 'PCX 160 • B 2233 FF',
        'service': 'Servis Besar',
        'time': 'Selesai: 09:00',
        'price': 'Rp 450.000',
        'status': 'Selesai',
        'date': '24 Oktober 2023'
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(), // Smooth scrolling physics
      itemCount: services.length,
      itemBuilder: (context, index) {
        final item = services[index];
        bool showHeader = false;
        String headerText = "";

        // Simplified grouping logic for dummy
        if (index == 0) {
          showHeader = true;
          headerText = "26 Oktober 2023";
        } else if (index == 2) {
          showHeader = true;
          headerText = "25 Oktober 2023";
        } else if (index == 4) {
          showHeader = true;
          headerText = "24 Oktober 2023";
        }

        return _buildAnimatedItem(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(headerText, style: AppTextStyles.heading5(color: Colors.grey[800])),
                      if (index == 0) // Only for today
                         Container(
                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                           decoration: BoxDecoration(
                             color: const Color(0xFFFFEBEE),
                             borderRadius: BorderRadius.circular(4),
                           ),
                           child: Text(
                             "Hari Ini",
                             style: AppTextStyles.bodyMedium(color: AppColors.primaryRed)
                                 .copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                           ),
                         ),
                       if (index == 0)
                        Text("2 Servis Selesai", style: AppTextStyles.bodyMedium(color: Colors.grey)),
                    ],
                  ),
                ),
              
              _buildHistoryCard(item),
            ],
          ),
          index, // Pass index for stagger delay
        );
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    bool isCancelled = item['status'] == 'Dibatalkan';

    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: isCancelled ? AppColors.error : AppColors.success,
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // Matches Owner theme
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                     item['name'],
                     style: AppTextStyles.heading4(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCancelled ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item['status'].toString().toUpperCase(),
                      style: AppTextStyles.bodyMedium(
                        color: isCancelled ? AppColors.error : AppColors.success,
                      ).copyWith(fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item['vehicle'],
                style: AppTextStyles.bodyMedium(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
               Row(
                children: [
                  Icon(Icons.build_circle_outlined, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(item['service'], style: AppTextStyles.bodyMedium(color: Colors.grey[700])),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              if (isCancelled)
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     Row(
                       children: [
                         Icon(Icons.cancel_outlined, size: 16, color: AppColors.textSecondary),
                         const SizedBox(width: 4),
                         Text(item['reason'], style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)),
                       ],
                     ),
                     Text(
                       "Lihat Alasan",
                       style: AppTextStyles.bodyMedium(color: AppColors.primaryRed)
                           .copyWith(fontWeight: FontWeight.bold),
                     )
                   ],
                 )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(item['time'], style: AppTextStyles.bodyMedium(color: AppColors.textSecondary)),
                      ],
                    ),
                    Text(
                      item['price'],
                      style: AppTextStyles.heading4(),
                    )
                  ],
                ),
            ],
          ),
        ),
    );
  }
}
