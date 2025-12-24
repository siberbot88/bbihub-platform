import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/feature/owner/providers/employee_provider.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/add_staff.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/list_staff.dart';
import 'package:bengkel_online_flutter/feature/owner/screens/staff_performance_screen.dart';

const Color _grad1 = Color(0xFF510606);
const Color _grad2 = Color(0xFF9B0D0D);
const Color _grad3 = Color(0xFFB70F0F);
const Color _primaryRed = Color(0xFFB70F0F);

class ManajemenKaryawanPage extends StatefulWidget {
  const ManajemenKaryawanPage({super.key});

  @override
  State<ManajemenKaryawanPage> createState() => _ManajemenKaryawanPageState();
}

class _ManajemenKaryawanPageState extends State<ManajemenKaryawanPage> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<EmployeeProvider>().fetchOwnerEmployees();
    });
  }

  Future<void> _refresh() async {
    await context.read<EmployeeProvider>().fetchOwnerEmployees();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    final prov = context.watch<EmployeeProvider>();
    final List<Employment> items = prov.items;

    final filtered = items.where((e) {
      final q = _searchQuery.toLowerCase();
      final name = (e.user?.name ?? '').toLowerCase();
      final role = e.role.toLowerCase();
      final specialist = (e.specialist ?? '').toLowerCase();
      final jobdesk = (e.jobdesk ?? '').toLowerCase();
      return name.contains(q) ||
          role.contains(q) ||
          specialist.contains(q) ||
          jobdesk.contains(q);
    }).toList();

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator.adaptive(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: _grad2,
              elevation: 0,
              expandedHeight: 280,
              automaticallyImplyLeading: canPop,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_grad2, _grad3],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          // Judul ditaruh di tengah, independen dari tombol back
                          const Center(
                            child: Text(
                              'Manajemen Staff',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            '${items.length} Karyawan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Kelola staff bengkel Anda dengan mudah',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Quick actions
                          Material(
                            elevation: 6,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding:
                              const EdgeInsets.symmetric(vertical: 18),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceEvenly,
                                children: [
                                  _FeatureButton(
                                    icon: Icons.person_add,
                                    label: 'Add Staff',
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const AddStaffRegisterPage(),
                                        ),
                                      );
                                      await _refresh();
                                    },
                                  ),
                                  _FeatureButton(
                                    icon: Icons.list,
                                    label: 'List Staff',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const ManajemenKaryawanTablePage(),
                                        ),
                                      );
                                    },
                                  ),
                                  _FeatureButton(
                                    icon: Icons.analytics_outlined,
                                    label: 'Kinerja Staff',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                          const StaffPerformanceScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Search
            SliverToBoxAdapter(
              child: _searchSection(
                outerPadding:
                const EdgeInsets.fromLTRB(16, 12, 16, 12),
                innerPadding:
                const EdgeInsets.symmetric(horizontal: 20),
                fieldContentPadding:
                const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverToBoxAdapter(child: _listHeaderSection()),

            // List
            if (prov.loading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (filtered.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text('Belum ada karyawan')),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, i) {
                    final e = filtered[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: _StaffCard(
                        name: e.user?.name ?? '-',
                        role: e.role.isEmpty ? '-' : e.role,
                        specialist: (e.specialist ?? '').isEmpty
                            ? '-'
                            : e.specialist!,
                        jobdesk: (e.jobdesk ?? '').isEmpty
                            ? '-'
                            : e.jobdesk!,
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _searchSection({
    required EdgeInsets outerPadding,
    required EdgeInsets innerPadding,
    required EdgeInsets fieldContentPadding,
  }) {
    return Padding(
      padding: outerPadding,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFF0F1F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: innerPadding,
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: fieldContentPadding,
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _searchQuery = ''),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listHeaderSection() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'List Jobdesk Staff',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            'Lainnya',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFDC2626),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Icon(icon, color: _primaryRed, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final String name;
  final String role;
  final String specialist;
  final String jobdesk;

  const _StaffCard({
    required this.name,
    required this.role,
    required this.specialist,
    required this.jobdesk,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [_grad1, _grad2, _grad3],
          stops: [0.13, 0.59, 0.79],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withAlpha(26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  role,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (specialist.isNotEmpty && specialist != '-')
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text(
                specialist,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(
            jobdesk,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
