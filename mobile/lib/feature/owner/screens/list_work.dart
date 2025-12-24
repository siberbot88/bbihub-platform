import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/core/providers/service_provider.dart';

import '../widgets/work/work_card.dart';
import '../widgets/work/work_helpers.dart';
import '../widgets/work/work_filter_sheet.dart';
import '../widgets/work/work_search_bar.dart';
import '../widgets/work/work_pagination.dart';
import '../widgets/custom_header.dart';

const Color _bgDark = Color(0xFF101922);
const Color _bgLight = Color(0xFFF6F7F8);

class ListWorkPage extends StatefulWidget {
  const ListWorkPage({super.key, this.workshopUuid});

  final String? workshopUuid;

  @override
  State<ListWorkPage> createState() => _ListWorkPageState();
}

class _ListWorkPageState extends State<ListWorkPage> {
  final TextEditingController _search = TextEditingController();
  WorkStatus _tabStatus = WorkStatus.pending;
  AdvancedFilter _advancedFilter = AdvancedFilter.empty;

  bool get _hasActiveFilter => !_advancedFilter.isEmpty;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<ServiceProvider>();
      prov.fetchServices(workshopUuid: widget.workshopUuid);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  WorkItem _map(ServiceModel s) {
    final status = _mapStatus(s.status);

    final vehicleName = (() {
      final brand = (s.vehicle?.brand ?? '').trim();
      final model = (s.vehicle?.model ?? '').trim();
      final year = (s.vehicle?.year ?? '').toString().trim();
      final parts = [brand, model, year].where((e) => e.isNotEmpty).toList();
      if (parts.isEmpty) return '-';
      return parts.join(' ');
    })();

    final plate = s.vehicle?.plateNumber ??
        tryOrNull(() => (s as dynamic).vehicle?.plate) ??
        '-';

    return WorkItem(
      id: s.id,
      workOrder: s.code,
      customer: s.customer?.name ?? '-',
      vehicle: vehicleName,
      plate: plate,
      service: s.name,
      schedule: s.scheduledDate,
      mechanic: s.mechanicName.isEmpty ? '-' : s.mechanicName,
      price: s.price,
      status: status,
    );
  }

  WorkStatus _mapStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'in progress':
        return WorkStatus.process;
      case 'completed':
        return WorkStatus.done;
      case 'accept':
      case 'pending':
      default:
        return WorkStatus.pending;
    }
  }

  bool _matchTab(ServiceModel s) {
    final st = s.status.toLowerCase();
    switch (_tabStatus) {
      case WorkStatus.pending:
        return st == 'pending' || st == 'accept' || st.isEmpty;
      case WorkStatus.process:
        return st == 'in progress';
      case WorkStatus.done:
        return st == 'completed';
    }
  }

  DateTime _dateForSort(ServiceModel s) =>
      s.scheduledDate ??
      s.createdAt ??
      DateTime.fromMillisecondsSinceEpoch(0);

  List<WorkItem> _filtered(List<ServiceModel> services) {
    Iterable<ServiceModel> filtered = services.where(_matchTab);

    if (_advancedFilter.vehicleType != null &&
        _advancedFilter.vehicleType!.isNotEmpty) {
      final want = _advancedFilter.vehicleType!.toLowerCase();
      filtered = filtered.where((s) {
        final vt = (s.vehicle?.type ?? '').toLowerCase();
        return vt == want;
      });
    }

    if (_advancedFilter.vehicleCategory != null &&
        _advancedFilter.vehicleCategory!.isNotEmpty) {
      final want = _advancedFilter.vehicleCategory!.toLowerCase();
      filtered = filtered.where((s) {
        final vc = (s.vehicle?.category ?? '').toLowerCase();
        return vc == want;
      });
    }

    final list = filtered.toList();

    if (_advancedFilter.sort == 'newest') {
      list.sort((a, b) => _dateForSort(b).compareTo(_dateForSort(a)));
    } else if (_advancedFilter.sort == 'oldest') {
      list.sort((a, b) => _dateForSort(a).compareTo(_dateForSort(b)));
    }

    var items = list.map(_map).toList();

    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return items;

    items = items.where((e) {
      return e.workOrder.toLowerCase().contains(q) ||
          e.customer.toLowerCase().contains(q) ||
          e.vehicle.toLowerCase().contains(q) ||
          e.plate.toLowerCase().contains(q) ||
          e.mechanic.toLowerCase().contains(q) ||
          e.service.toLowerCase().contains(q);
    }).toList();

    return items;
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return WorkFilterSheet(
          currentFilter: _advancedFilter,
          onApply: (filter) {
            setState(() {
              _advancedFilter = filter;
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? _bgDark : _bgLight;
    final prov = context.watch<ServiceProvider>();
    final list = _filtered(prov.items);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomHeader(
        title: "Daftar Pekerjaan",
        actions: [
          IconButton(
            onPressed: () =>
                prov.fetchServices(workshopUuid: widget.workshopUuid),
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                // Search Bar
                WorkSearchBar(
                  controller: _search,
                  onFilterTap: _openFilterSheet,
                  hasActiveFilter: _hasActiveFilter,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),

                // Filter Chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      WorkStatusChip(
                        label: 'Pending',
                        icon: Icons.error_outline,
                        selected: _tabStatus == WorkStatus.pending,
                        onTap: () =>
                            setState(() => _tabStatus = WorkStatus.pending),
                      ),
                      const SizedBox(width: 12),
                      WorkStatusChip(
                        label: 'Process',
                        icon: Icons.schedule_rounded,
                        selected: _tabStatus == WorkStatus.process,
                        onTap: () =>
                            setState(() => _tabStatus = WorkStatus.process),
                      ),
                      const SizedBox(width: 12),
                      WorkStatusChip(
                        label: 'Selesai',
                        icon: Icons.verified_rounded,
                        selected: _tabStatus == WorkStatus.done,
                        onTap: () =>
                            setState(() => _tabStatus = WorkStatus.done),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Area
          Expanded(
            child: prov.loading
                ? Center(
                    child: CircularProgressIndicator(
                      color: isDark ? Colors.white : const Color(0xFFD72B1C),
                    ),
                  )
                : prov.lastError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            prov.lastError!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      )
                    : list.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: isDark 
                                        ? const Color(0xFF1c2630)
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.assignment_late_outlined,
                                    size: 48,
                                    color: const Color(0xFF9dabb9),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada pekerjaan',
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Coba ubah filter atau cari kata kunci lain',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF9dabb9),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: list.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 16),
                            itemBuilder: (_, i) {
                              return WorkCard(item: list[i]);
                            },
                          ),
          ),

          // Pagination Footer
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1c2630) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: WorkPagination(
                  currentPage: prov.currentPage,
                  totalPages: prov.totalPages,
                  loading: prov.loading,
                  onPrev: () => prov.goToPage(
                    prov.currentPage - 1,
                    workshopUuid: widget.workshopUuid,
                  ),
                  onNext: () => prov.goToPage(
                    prov.currentPage + 1,
                    workshopUuid: widget.workshopUuid,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
