import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/service/assign_mechanic_sheet.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/service_logging/logging_helpers.dart';
import 'package:intl/intl.dart';

class ServiceDetailPage extends StatefulWidget {
  final ServiceModel? service; 
  const ServiceDetailPage({super.key, this.service});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  // State to track if mechanic is assigned
  bool isAssigned = false;
  Map<String, dynamic>? assignedMechanic;

  @override
  void initState() {
    super.initState();
    // Pre-fill state if service has mechanic
    if (widget.service?.mechanic != null || widget.service?.mechanicUuid != null) {
        isAssigned = true;
        // Mock assigned structure for now or properly map it
        assignedMechanic = {
            'name': widget.service?.mechanic?.name ?? 'Teknisi',
            'avatar': 'https://i.pravatar.cc/150?u=${widget.service?.mechanicUuid ?? 'mech'}',
            'id': widget.service?.mechanicUuid ?? '',
        };
    }
  }

  // Use the specific colors requested by user
  final Color _primaryRed = const Color(0xFFD92C1C);
  final Color _backgroundLight = const Color(0xFFF8F6F6);
  final Color _statusPending = const Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final s = widget.service;
    final dateStr = s?.scheduledDate != null 
        ? DateFormat('dd MMM yyyy\nhh:mm a').format(s!.scheduledDate!) 
        : '-';

    return Scaffold(
      backgroundColor: _backgroundLight,
      body: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            slivers: [
              // Sticky App Bar
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white.withOpacity(0.95),
                elevation: 0,
                scrolledUnderElevation: 0, // No shadow change on scroll
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Or hover effect logic
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                title: Text(
                  "Detail Servis",
                  style: AppTextStyles.heading4(color: AppColors.textPrimary),
                ),
                centerTitle: true,
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(1),
                    child: Container(color: Colors.grey[200], height: 1),
                ),
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Image with Badge
                      Stack(
                        children: [
                          Container(
                            height: 240,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20), // More rounded
                              image: const DecorationImage(
                                image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuAjS_7c4F66-DyJU_0f-49tu1YfQRZKcxhyKMm2Ao7z04GdTFFpYeHdmzfDOyPSU1r8HHwv4z8PMPOFHwE4Lm5pXHgaIMDErB8JZJ1S1UXQpkDnE2zHDU54NFj_iqLHkg4NXbxpEW2HZSj181HJR7h2g1asH7rUFMyFXw0hjh-f5JPcAn4jkkj0Ykm0zYwlqA_aC-9NCCW61XcUNgUsUV_Q138Ju-XpfZwseLX5hyPjXySUlofo9cffook2cE2c7wjhfp4jbvfuf2s"),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1), // Increased opacity
                                  blurRadius: 20, // Increased blur
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: _statusPending,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: _statusPending.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                isAssigned ? "MENUNGGU PENGECEKAN" : (s?.status.toUpperCase() ?? "PENDING"),
                                style: AppTextStyles.caption(color: Colors.white).copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),

                      // Info Grid
                      Builder(
                        builder: (context) {
                          return GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 2.5,
                            mainAxisSpacing: 24,
                            crossAxisSpacing: 16,
                            children: [
                              _buildInfoItem(Icons.directions_car_outlined, "Model", s?.displayVehicleName ?? "Unknown"),
                              _buildInfoItem(Icons.pin_drop_outlined, "Plat No", s?.displayVehiclePlate ?? "-"),
                              _buildInfoItem(Icons.person_outline, "Customer", s?.displayCustomerName ?? "-"),
                              _buildInfoItem(Icons.calendar_today_outlined, "Date", dateStr),
                            ],
                          );
                        }
                      ),

                      const SizedBox(height: 32),

                      // Complaint Section
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB), // Very light gray, cleaner
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _primaryRed.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.error_outline, color: _primaryRed, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  "Keluhan",
                                  style: AppTextStyles.heading5(color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              s?.complaint ?? s?.description ?? "-",
                              style: AppTextStyles.bodyMedium(color: const Color(0xFF4A403F)).copyWith(
                                height: 1.6,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (isAssigned) ...[
                         const SizedBox(height: 32),
                         // Empty State for Pricing/Check
                         Center(
                           child: Column(
                             children: [
                               Container(
                                 padding: const EdgeInsets.all(24),
                                 decoration: BoxDecoration(
                                   color: Colors.white,
                                   shape: BoxShape.circle,
                                   boxShadow: [
                                     BoxShadow(
                                       color: Colors.black.withOpacity(0.05),
                                       blurRadius: 15,
                                       offset: const Offset(0, 4),
                                     ),
                                   ],
                                 ),
                                 child: Icon(Icons.pending_actions_outlined, size: 48, color: Colors.grey[400]),
                               ),
                               const SizedBox(height: 16),
                               Text(
                                 "Menunggu Pengecekan",
                                 style: AppTextStyles.heading4(),
                               ),
                               const SizedBox(height: 8),
                               Text(
                                 "Rincian sparepart yang diganti dan biaya service\nakan tercatat otomatis di sini\nsetelah teknisi melakukan pemeriksaan.",
                                 textAlign: TextAlign.center,
                                 style: AppTextStyles.bodyMedium(color: Colors.grey),
                               ),
                             ],
                           ),
                         ),
                         const SizedBox(height: 24),
                      ],

                      // Bottom Padding for Footer
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08), // Stronger shadow
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: isAssigned 
                  ? _buildAssignedMechanicCard()
                  : ElevatedButton(
                      onPressed: _showAssignMechanicSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 18), // Taller button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0, // Flat material elevation, use shadow
                        shadowColor: Colors.transparent, // Disable default shadow
                      ).copyWith(
                        // Add custom shadow via Container if needed, 
                        // or just rely on the button's color. User wants "Heroicons" style.
                        // Let's keep it simple flat red button as per modern design
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.engineering_outlined, color: Colors.white), // Outlined icon
                          const SizedBox(width: 10),
                          Text(
                            "Tetapkan Mekanik",
                            style: AppTextStyles.heading5(color: Colors.white).copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFFE5DDDC), width: 2)), // Vertical divider line style
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Row(
             children: [
               Icon(icon, size: 16, color: AppColors.textSecondary),
               const SizedBox(width: 6),
               Text(
                 label.toUpperCase(),
                 style: AppTextStyles.caption(color: AppColors.textSecondary).copyWith(
                   fontWeight: FontWeight.bold,
                   letterSpacing: 0.5,
                 ),
               ),
             ],
           ),
           const SizedBox(height: 4),
           Flexible( // Handle long text
             child: Text(
               value,
               style: AppTextStyles.heading5(color: AppColors.textPrimary).copyWith(fontSize: 15),
               maxLines: 2,
               overflow: TextOverflow.ellipsis,
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildAssignedMechanicCard() {
    if (assignedMechanic == null) return const SizedBox();

    return Row(
      children: [
         // Avatar
         CircleAvatar(
           radius: 24,
           backgroundImage: NetworkImage(assignedMechanic!['avatar']),
         ),
         const SizedBox(width: 12),
         // Info
         Expanded(
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 "Teknisi Bertugas",
                 style: AppTextStyles.caption(color: AppColors.textSecondary),
               ),
               Text(
                 assignedMechanic!['name'],
                 style: AppTextStyles.heading5(),
               ),
               Row(
                 children: [
                   Container(
                     width: 8,
                     height: 8,
                     decoration: const BoxDecoration(
                       color: Color(0xFFD92C1C), // Red or Orange depending on status
                       shape: BoxShape.circle,
                     ),
                   ),
                   const SizedBox(width: 6),
                   Text(
                     "Menunggu Pengerjaan", // Or status from mechanic
                     style: AppTextStyles.caption(color: const Color(0xFFD92C1C)),
                   ),
                 ],
               ),
             ],
           ),
         ),
         // Call Button
         Container(
           decoration: BoxDecoration(
             color: const Color(0xFFFFEBEE), // Light red bg
             shape: BoxShape.circle,
           ),
           child: IconButton(
             icon: const Icon(Icons.call, color: Color(0xFFD92C1C)),
             onPressed: () {
               // Call action
             },
           ),
         ),
      ],
    );
  }

  void _showAssignMechanicSheet() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height control
      backgroundColor: Colors.transparent,
      builder: (context) => const AssignMechanicSheet(),
    );

    if (result != null) {
      setState(() {
        assignedMechanic = result;
        isAssigned = true;
      });
    }
  }
}
