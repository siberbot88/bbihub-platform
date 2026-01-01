import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/service/assign_mechanic_sheet.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/service_logging/logging_helpers.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'invoice_form_screen.dart';
import 'cash_payment_screen.dart';

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

  ServiceModel? _service;
  bool _isLoadingAction = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service;
    
    // Pre-fill state if service has mechanic
    if (_service?.mechanic != null || _service?.mechanicUuid != null) {
        isAssigned = true;
        assignedMechanic = {
            'name': _service?.mechanic?.name ?? 'Teknisi',
            'avatar': _service?.mechanic?.photoUrl ?? 'https://i.pravatar.cc/150?u=${_service?.mechanicUuid ?? 'mech'}',
            'id': _service?.mechanicUuid ?? '',
        };
    }
  }

  Future<void> _refreshService() async {
    if (_service == null) return;
    try {
      final updated = await context.read<AdminServiceProvider>().performFetchServiceDetail(_service!.id);
      setState(() {
        _service = updated;
        if (_service?.mechanic != null || _service?.mechanicUuid != null) {
          isAssigned = true;
          assignedMechanic = {
            'name': _service?.mechanic?.name ?? 'Teknisi',
            'avatar': _service?.mechanic?.photoUrl ?? 'https://i.pravatar.cc/150?u=${_service?.mechanicUuid ?? 'mech'}',
            'id': _service?.mechanicUuid ?? '',
          };
        }
      });
    } catch (e) {
      debugPrint('Error refreshing service: $e');
    }
  }

  // Use the specific colors requested by user
  final Color _primaryRed = AppColors.primaryRed; 
  final Color _backgroundLight = const Color(0xFFF8F6F6);
  final Color _statusPending = const Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final s = _service;
    final dateStr = s?.scheduledDate != null 
        ? DateFormat('dd MMM yyyy\nhh:mm a').format(s!.scheduledDate!) 
        : '-';

    return Scaffold(
      backgroundColor: _backgroundLight,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white.withOpacity(0.95),
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
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
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(
                                  s?.imageUrl ?? "https://placehold.co/600x400/D72B1C/FFFFFF?text=Service",
                                ),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
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
                                color: (s?.transaction != null && (s!.transaction!['status'] == 'success' || s.transaction!['status'] == 'paid')) 
                                    ? Colors.green 
                                    : (s?.acceptanceStatus ?? 'pending') == 'pending' ? _statusPending : Colors.green,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: [
                                  BoxShadow(
                                    color: ((s?.acceptanceStatus ?? 'pending') == 'pending' ? _statusPending : AppColors.primaryRed).withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                (s?.transaction != null && (s!.transaction!['status'] == 'success' || s.transaction!['status'] == 'paid'))
                                  ? "LUNAS"
                                  : (['completed', 'lunas'].contains((s?.status ?? '').toLowerCase()))
                                      ? "SERVICE SELESAI"
                                      : (isAssigned 
                                          ? "MENUNGGU PENGECEKAN" 
                                          : (s?.acceptanceStatus == 'accepted' 
                                              ? "DITERIMA" 
                                              : (s?.status.toUpperCase() ?? "PENDING"))),
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
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(20),
                          border: Border(top: BorderSide(color: Colors.grey.shade100)),
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

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Footer
          if (!['in_progress', 'in progress', 'completed', 'done', 'cancelled', 'lunas'].contains((_service?.status ?? '').toLowerCase()))
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              // Footer Actions / Buttons
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, -4),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: _isLoadingAction 
                  ? const Center(child: CircularProgressIndicator())
                  : _buildActionButtons(),
            ),
          ),
        ],
      ),
      
      // Complete Service Button - Outside main scroll, fixed at bottom
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mechanic Contact Info (if assigned)
          if (_service?.mechanic != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primaryRed.withOpacity(0.1),
                    child: Text(
                      (_service?.mechanic?.name ?? 'T').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Teknisi Bertugas',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _service?.mechanic?.name ?? assignedMechanic?['name'] ?? 'Teknisi',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getMechanicStatusText(_service?.status ?? ''),
                          style: const TextStyle(fontSize: 12, color: AppColors.primaryRed),
                        ),
                      ],
                    ),
                  ),
                  if ((_service?.status ?? '').toLowerCase() == 'in_progress' ||
                      (_service?.status ?? '').toLowerCase() == 'in progress')
                    ElevatedButton(
                      onPressed: _completeService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        minimumSize: const Size(0, 36),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    )
                  else if (['completed', 'lunas'].contains((_service?.status ?? '').toLowerCase()))
                    Builder(
                      builder: (context) {
                        final invoice = _service?.invoice;
                        final isPaid = (invoice != null && invoice['status'] == 'paid') || 
                                       (_service?.status ?? '').toLowerCase() == 'lunas' ||
                                       (_service?.transaction != null && (_service!.transaction!['status'] == 'success' || _service!.transaction!['status'] == 'paid'));
                        
                        // Check if booking (online) vs on-site (walk-in)
                        final isBooking = (_service?.type != 'on-site' && _service?.type != 'ditempat');

                        if (isPaid) {
                           return ElevatedButton.icon(
                             onPressed: () {
                                if (invoice != null) {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => CashPaymentScreen(
                                    invoiceId: invoice['id'],
                                    total: double.tryParse(invoice['total'].toString()) ?? 0.0,
                                    invoiceCode: invoice['invoice_code'] ?? '',
                                    service: _service,
                                  )));
                                }
                             },
                             icon: const Icon(Icons.receipt_long, size: 16),
                             label: const Text("Lihat Nota"),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Colors.green, // Changed to Green for Paid/Done
                               foregroundColor: Colors.white,
                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                               minimumSize: const Size(0, 36),
                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                               elevation: 0,
                             ),
                           );
                        }
                        
                        // Behavior for Unpaid Invoices
                        if (isBooking) {
                            // Online Booking: Admin CANNOT collect payment. Customer pays via app.
                            return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        const Icon(Icons.access_time_rounded, size: 16, color: Colors.orange),
                                        const SizedBox(width: 6),
                                        Text(
                                            "Menunggu Pembayaran",
                                            style: AppTextStyles.caption(color: Colors.orange).copyWith(fontWeight: FontWeight.bold),
                                        ),
                                    ],
                                ),
                            );
                        } else {
                            // Walk-in / On-site: Admin collects payment (Cash/QRIS)
                            return ElevatedButton(
                              onPressed: () {
                                 if (invoice != null) {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => CashPaymentScreen(
                                      invoiceId: invoice['id'],
                                      total: double.tryParse(invoice['total'].toString()) ?? 0.0,
                                      invoiceCode: invoice['invoice_code'] ?? '',
                                      service: _service,
                                    )));
                                 } else {
                                    // Re-use _completeService to go to Invoice Form
                                    _completeService();
                                 }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: invoice != null ? Colors.blue : AppColors.primaryRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Compact
                                minimumSize: const Size(0, 36),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                invoice != null ? 'Bayar' : 'Buat Tagihan',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            );
                        }
                      }
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.call, color: AppColors.primaryRed),
                      onPressed: () {
                        // Call mechanic implementation
                      },
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final s = _service;
    if (s == null) return const SizedBox();

    // Condition: If Pending Booking -> Show Accept/Decline
    // Note: 'on-site' types are usually auto-accepted, but if pending (e.g. data anomaly), 
    // we bypass this and show 'Assign Mechanic' which now handles pending walk-ins gracefully.
    final bool isBooking = (s.type != 'on-site' && s.type != 'ditempat');
    
    if ((s.acceptanceStatus ?? 'pending') == 'pending' && isBooking) {
      return Row(
        children: [
          // Decline Button
          Expanded(
            child: OutlinedButton(
              onPressed: _showDeclineDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                side: BorderSide(color: Colors.grey[300]!),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text("Tolak", style: AppTextStyles.heading5(color: Colors.grey[800])),
            ),
          ),
          const SizedBox(width: 16),
          // Accept Button
          Expanded(
            child: ElevatedButton(
              onPressed: _acceptService,
              style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.green, // Green for accept
                 padding: const EdgeInsets.symmetric(vertical: 16),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                 elevation: 0,
              ),
              child: Text("Terima", style: AppTextStyles.heading5(color: Colors.white)),
            ),
          ),
        ],
      );
    }

    // If service is in progress -> Show Complete button
    if ((s.status ?? '').toLowerCase() == 'in_progress' || 
        (s.status ?? '').toLowerCase() == 'in progress') {
      return ElevatedButton(
        onPressed: _completeService,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text('Selesai', style: AppTextStyles.heading5(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    // Default: Show Assign Mechanic (for Accepted services)
    return ElevatedButton(
      onPressed: _showAssignMechanicSheet,
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryRed,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.engineering_outlined, color: Colors.white),
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
    );
  }

  Future<void> _navigateToLogging() async {
      // Pop until we are back at the main admin dashboard/service list
      // This assumes ServiceDetailPage was pushed from ServicePage
      Navigator.of(context).popUntil((route) => route.isFirst); 
      
      // Ideally we should use a global key or provider to switch the tab in ServicePage
      // but for now, popping back is the safest "Back to List" action
      // If we want to force "Pencatatan" tab, we might need to pass a result back
  }

  Future<void> _acceptService() async {
     if (_service == null) return;
     
     // 1. Set loading
     setState(() => _isLoadingAction = true);
     
     try {
       // 2. Call API
       await context.read<AdminServiceProvider>().acceptServiceAsAdmin(_service!.id);
       
       // 3. Check mounted before using context
       if (!mounted) return;

       // 4. Show success & Navigate back
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Servis diterima!'), backgroundColor: Colors.green, duration: Duration(seconds: 1)),
       );
       
       // Wait slightly for snackbar visibility then pop
       await Future.delayed(const Duration(milliseconds: 300));
       if (mounted) {
          Navigator.of(context).pop(true); // Return true to signal refresh
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Gagal menerima: $e'), backgroundColor: Colors.red),
         );
       }
     } finally {
       if (mounted) setState(() => _isLoadingAction = false);
     }
  }

  void _showDeclineDialog() {
    String selectedReason = 'antrian sedang full';
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Tolak Servis'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedReason,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Alasan'),
                    items: [
                      'antrian sedang full',
                      'jadwal bentrok',
                      'lokasi terlalu jauh',
                      'kendaraan tidak sesuai',
                      'lainnya'
                    ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) {
                       if (v != null) setDialogState(() => selectedReason = v);
                    },
                  ),
                  if (selectedReason == 'lainnya') 
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextFormField(
                        controller: reasonController,
                        decoration: const InputDecoration(
                           labelText: 'Keterangan',
                           border: OutlineInputBorder(),
                        ),
                        validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context);
                    _declineService(selectedReason, reasonController.text);
                  }
                },
                child: const Text('Tolak', style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _declineService(String reason, String desc) async {
     if (_service == null) return;
     setState(() => _isLoadingAction = true);
     try {
       await context.read<AdminServiceProvider>().declineServiceAsAdmin(
         _service!.id, 
         reason: reason, 
         reasonDescription: desc
       );
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Servis ditolak.'), backgroundColor: Colors.grey),
         );
         Navigator.pop(context, true); // Return true to signal refresh/navigation
       }
     } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Gagal menolak: $e'), backgroundColor: Colors.red),
         );
         setState(() => _isLoadingAction = false);
       }
     }
  }

  // Helper widget builder
  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color(0xFFE5DDDC), width: 2)), 
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
           Flexible(
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(assignedMechanic!['avatar'] ?? "https://placehold.co/100"),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignedMechanic!['name'],
                  style: AppTextStyles.heading5(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignMechanicSheet() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (context) => const AssignMechanicSheet(),
    );

    if (result != null && _service != null) {
      final mechanicId = result['id']; 
      
      try {
        // Unified Logic: Accept & Assign or just Assign
        if ((_service!.acceptanceStatus ?? 'pending') == 'pending') {
             await context.read<AdminServiceProvider>().acceptServiceAsAdmin(
              _service!.id, 
              mechanicUuid: mechanicId
            );
        } else {
            await context.read<AdminServiceProvider>().assignMechanicAsAdmin(
              _service!.id, 
              mechanicId,
            );
        }

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Mekanik berhasil ditetapkan!'), backgroundColor: Colors.green),
           );
           
           // Directly navigate to InvoiceFormScreen (Selesaikan Service) as requested
           // "untuk assign mekanik itu akan langsung ke halaman selesaikan service"
           if (mounted && _service != null) {
               // Update local state first to ensure data consistency passed to next screen
               final updatedService = await context.read<AdminServiceProvider>().performFetchServiceDetail(_service!.id);
               
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => InvoiceFormScreen(
                serviceId: updatedService.id, 
                serviceType: updatedService.type ?? 'on-site',
                service: updatedService,
              )));
           }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  /// Navigate to invoice form to complete service
  Future<void> _completeService() async {
    if (_service == null) return;

    // Navigate to invoice form
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InvoiceFormScreen(
            serviceId: _service!.id,
            serviceType: _service!.type ?? 'on-site',
            service: _service, // Pass full object for summary
          ),
        ),
      );

    // Refresh if invoice created / service completed
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service selesai & Tagihan dibuat!'), backgroundColor: Colors.green),
      );
      await _refreshService();
    }
  }

  /// Get mechanic status text based on service status
  String _getMechanicStatusText(String status) {
    final statusLower = status.toLowerCase().replaceAll(' ', '_');
    
    switch (statusLower) {
      case 'completed':
      case 'lunas':
        return 'Pengerjaan Selesai';
      case 'in_progress':
      case 'in progress':
        return 'Sedang Dikerjakan';
      case 'accepted':
      case 'accept':
        return 'Siap Dikerjakan';
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Menunggu Pengerjaan';
    }
  }
}
