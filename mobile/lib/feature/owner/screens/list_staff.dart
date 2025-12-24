import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/feature/owner/screens/add_staff.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'package:bengkel_online_flutter/feature/owner/providers/employee_provider.dart';
import 'package:bengkel_online_flutter/core/widgets/custom_alert.dart';
import 'package:bengkel_online_flutter/core/theme/app_colors.dart';
import 'package:bengkel_online_flutter/core/theme/app_text_styles.dart';

import '../widgets/manajemen_karyawan/staff_edit_sheet.dart';
import '../widgets/manajemen_karyawan/staff_helpers.dart';

class ManajemenKaryawanTablePage extends StatefulWidget {
  const ManajemenKaryawanTablePage({super.key});

  @override
  State<ManajemenKaryawanTablePage> createState() => _ManajemenKaryawanTablePageState();
}

class _ManajemenKaryawanTablePageState extends State<ManajemenKaryawanTablePage> {
  final TextEditingController _searchC = TextEditingController();
  int _currentPage = 1;
  static const int _itemsPerPage = 8;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeeProvider>().fetchOwnerEmployees();
    });
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await context.read<EmployeeProvider>().fetchOwnerEmployees();
  }

  List<Employment> _filter(List<Employment> items) {
    final q = _searchC.text.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((e) {
      return e.name.toLowerCase().contains(q) ||
          e.role.toLowerCase().contains(q) ||
          e.email.toLowerCase().contains(q);
    }).toList();
  }

  int _getTotalPages(int totalItems) {
    return (totalItems / _itemsPerPage).ceil();
  }

  List<Employment> _getPaginatedItems(List<Employment> items) {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    
    if (startIndex >= items.length) return [];
    return items.sublist(
      startIndex,
      endIndex > items.length ? items.length : endIndex,
    );
  }

  Future<void> _toggleActive(Employment e, bool value) async {
    final prov = context.read<EmployeeProvider>();
    try {
      await prov.toggleStatus(e.id, value);
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: "Status Updated",
        message: '${e.name} is now ${value ? 'Active' : 'Inactive'}',
        type: AlertType.success,
      );
    } catch (_) {
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: "Failed",
        message: 'Failed to update status for ${e.name}',
        type: AlertType.error,
      );
    }
  }

  Future<void> _editEmployee(Employment e) async {
    final result = await showModalBottomSheet<StaffEditResult>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StaffEditSheet(employment: e),
    );
    if (result == null) return;
    if (!mounted) return;

    final prov = context.read<EmployeeProvider>();
    try {
      await prov.updateEmployee(
        e.id,
        name: result.name,
        username: result.username,
        email: result.email,
        role: result.role,
        specialist: result.specialist,
        jobdesk: result.jobdesk,
      );
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: "Success",
        message: "Employee data has been updated",
        type: AlertType.success,
      );
    } catch (err) {
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: "Failed",
        message: 'Update failed: $err',
        type: AlertType.error,
      );
    }
  }

  Future<void> _deleteEmployee(Employment e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete "${e.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    if (!mounted) return;

    final prov = context.read<EmployeeProvider>();
    try {
      await prov.deleteEmployee(e.id);
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: "Deleted",
        message: "Employee has been removed",
        type: AlertType.success,
      );
    } catch (err) {
      if (!mounted) return;
      CustomAlert.show(
        context,
        title: "Failed",
        message: 'Delete failed: $err',
        type: AlertType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const gradStart = Color(0xFF9B0D0D);
    const gradEnd = Color(0xFFB70F0F);

    final prov = context.watch<EmployeeProvider>();
    final all = prov.items;
    final filtered = _filter(all);
    final totalPages = _getTotalPages(filtered.length);
    final paginatedItems = _getPaginatedItems(filtered);

    // Reset to page 1 if current page exceeds total pages
    if (_currentPage > totalPages && totalPages > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() => _currentPage = 1);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryRed,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // HEADER with Gradient (without search)
            SliverAppBar(
              pinned: true,
              backgroundColor: gradStart,
              automaticallyImplyLeading: false,
              elevation: 0,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [gradStart, gradEnd],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(Colors.white.withAlpha(64)),
                                  shape: const WidgetStatePropertyAll(CircleBorder()),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'List Karyawan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            '${filtered.length} karyawan',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Search Bar Section (Modern style)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    // Search TextField
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: _searchC,
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: AppTextStyles.bodyMedium(color: AppColors.textHint),
                            prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onChanged: (_) {
                            setState(() {
                              _currentPage = 1; // Reset to page 1 on search
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Button
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.tune_rounded, color: AppColors.textSecondary),
                        onPressed: () {
                          // Filter functionality (placeholder)
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Table Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          border: Border(
                            bottom: BorderSide(color: AppColors.border),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('Name', style: AppTextStyles.label(color: AppColors.textSecondary)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Position', style: AppTextStyles.label(color: AppColors.textSecondary)),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text('Status', style: AppTextStyles.label(color: AppColors.textSecondary)),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Text('Actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Table Body
                      SizedBox(
                        height: 520, // Fixed height for table body
                        child: paginatedItems.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.people_outline, size: 64, color: AppColors.textHint.withAlpha(100)),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No employees found',
                                      style: AppTextStyles.bodyLarge(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(0),
                                itemCount: paginatedItems.length,
                                separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.border),
                                itemBuilder: (context, index) {
                                  final staff = paginatedItems[index];
                                  return _StaffRow(
                                    staff: staff,
                                    onToggle: (value) => _toggleActive(staff, value),
                                    onEdit: () => _editEmployee(staff),
                                    onDelete: () => _deleteEmployee(staff),
                                  );
                                },
                              ),
                      ),

                      // Pagination
                      if (totalPages > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: AppColors.border)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Previous Button
                              _PaginationButton(
                                icon: Icons.chevron_left_rounded,
                                enabled: _currentPage > 1,
                                onPressed: () {
                                  if (_currentPage > 1) {
                                    setState(() => _currentPage--);
                                  }
                                },
                              ),
                              const SizedBox(width: 12),

                              // Page Numbers
                              ..._buildPageNumbers(totalPages),

                              const SizedBox(width: 12),
                              // Next Button
                              _PaginationButton(
                                icon: Icons.chevron_right_rounded,
                                enabled: _currentPage < totalPages,
                                onPressed: () {
                                  if (_currentPage < totalPages) {
                                    setState(() => _currentPage++);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStaffRegisterPage()),
          );
          if (!mounted) return;
          _refresh();
        },
        backgroundColor: AppColors.primaryRed,
        icon: const Icon(Icons.person_add_alt, color: Colors.white),
        label: Text('Add Staff', style: AppTextStyles.button()),
      ),
    );
  }

  List<Widget> _buildPageNumbers(int totalPages) {
    List<Widget> pages = [];
    
    // Show first page
    if (totalPages > 0) {
      pages.add(_PageNumber(
        pageNumber: 1,
        isActive: _currentPage == 1,
        onPressed: () => setState(() => _currentPage = 1),
      ));
    }

    // Show ellipsis or page numbers
    if (totalPages > 5) {
      if (_currentPage > 3) {
        pages.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(fontSize: 16)),
        ));
      }

      // Show current page and neighbors
      for (int i = (_currentPage - 1).clamp(2, totalPages - 1);
          i <= (_currentPage + 1).clamp(2, totalPages - 1);
          i++) {
        pages.add(_PageNumber(
          pageNumber: i,
          isActive: _currentPage == i,
          onPressed: () => setState(() => _currentPage = i),
        ));
      }

      if (_currentPage < totalPages - 2) {
        pages.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('...', style: TextStyle(fontSize: 16)),
        ));
      }

      // Show last page
      if (totalPages > 1) {
        pages.add(_PageNumber(
          pageNumber: totalPages,
          isActive: _currentPage == totalPages,
          onPressed: () => setState(() => _currentPage = totalPages),
        ));
      }
    } else {
      // Show all pages if total pages <= 5
      for (int i = 2; i <= totalPages; i++) {
        pages.add(_PageNumber(
          pageNumber: i,
          isActive: _currentPage == i,
          onPressed: () => setState(() => _currentPage = i),
        ));
      }
    }

    return pages;
  }
}

// Staff Row Widget
class _StaffRow extends StatelessWidget {
  final Employment staff;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _StaffRow({
    required this.staff,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Avatar + Name
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: staffAvatarBg(staff.name),
                  child: Text(
                    staffInitials(staff.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.name,
                        style: AppTextStyles.heading5().copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        staff.email,
                        style: AppTextStyles.caption(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Position
          Expanded(
            flex: 2,
            child: Text(
              staff.role,
              style: AppTextStyles.bodyMedium(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: staff.isActive ? AppColors.success : AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    staff.isActive ? 'Active' : 'Inactive',
                    style: AppTextStyles.bodyMedium(
                      color: staff.isActive ? AppColors.success : AppColors.error,
                    ).copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Actions (Dropdown)
          Expanded(
            flex: 1,
            child: Center(
              child: PopupMenuButton(
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(
                          staff.isActive ? Icons.toggle_on : Icons.toggle_off,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Text(staff.isActive ? 'Deactivate' : 'Activate'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: const [
                        Icon(Icons.edit_outlined, color: AppColors.info),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: const [
                        Icon(Icons.delete_outline, color: AppColors.error),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'toggle':
                      onToggle(!staff.isActive);
                      break;
                    case 'edit':
                      onEdit();
                      break;
                    case 'delete':
                      onDelete();
                      break;
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Pagination Button Widget
class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width > 600 ? 44.0 : 40.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: enabled ? Colors.white : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20),
        color: enabled ? AppColors.textPrimary : AppColors.textHint,
        onPressed: enabled ? onPressed : null,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// Page Number Widget
class _PageNumber extends StatelessWidget {
  final int pageNumber;
  final bool isActive;
  final VoidCallback onPressed;

  const _PageNumber({
    required this.pageNumber,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryRed : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? AppColors.primaryRed : AppColors.border),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          '$pageNumber',
          style: AppTextStyles.bodyMedium(
            color: isActive ? Colors.white : AppColors.textPrimary,
          ).copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
