import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bengkel_online_flutter/core/providers/service_provider.dart';
import 'package:bengkel_online_flutter/core/models/service.dart';
import 'package:bengkel_online_flutter/core/models/transaction_item.dart';

import '../widgets/work_detail/work_detail_helpers.dart';
import '../widgets/work_detail/work_detail_panels.dart';
import '../widgets/work_detail/work_detail_info.dart';
import '../widgets/work_detail/work_detail_costs.dart';

const _gradStart = Color(0xFF9B0D0D);
const _danger = Color(0xFFDC2626);

class DetailWorkPage extends StatefulWidget {
  final String serviceId;
  const DetailWorkPage({super.key, required this.serviceId});

  @override
  State<DetailWorkPage> createState() => _DetailWorkPageState();
}

class _DetailWorkPageState extends State<DetailWorkPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceProvider>().fetchDetail(widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ServiceProvider>();
    final s = prov.selected;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      appBar: AppBar(
        backgroundColor: _gradStart,
        elevation: 0,
        title: Text(
          s?.code ?? 'Detail Pekerjaan',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: prov.loading
          ? const Center(child: CircularProgressIndicator())
          : prov.lastError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      prov.lastError!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : s == null
                  ? const Center(child: Text('Data tidak ditemukan'))
                  : _Body(service: s),
    );
  }
}

/* ---------------- BODY ---------------- */

class _Body extends StatelessWidget {
  final ServiceModel service;
  const _Body({required this.service});

  num get _partsTotal => (service.items ?? const <TransactionItem>[])
      .fold<num>(0, (a, b) => a + (b.subtotal));
  num get _labor => service.price ?? 0;
  num get _grand => _partsTotal + _labor;

  @override
  Widget build(BuildContext context) {
    final v = service.vehicle;
    final c = service.customer;
    final progress = calculateProgress(service.status);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        // STATUS
        WorkDetailPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const WorkDot(color: _danger),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText(service.status),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation(_danger),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // CUSTOMER
        WorkDetailPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WorkSectionTitle(
                icon: Icons.person_outline,
                text: 'Informasi Customer',
              ),
              const SizedBox(height: 10),
              WorkTwoCol(
                leftTitle: 'Nama lengkap',
                leftValue: c?.name ?? '-',
                rightTitle: 'Alamat',
                rightValue: customerAddressSafe(c),
              ),
              const SizedBox(height: 8),
              WorkTwoCol(
                leftTitle: 'Telepon',
                leftValue: c?.phone ?? '-',
                rightTitle: 'Email',
                rightValue: c?.email ?? '-',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // VEHICLE
        WorkVehicleCard(vehicle: v),
        const SizedBox(height: 12),

        // DETAIL PEKERJAAN
        WorkDetailPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WorkSectionTitle(
                icon: Icons.tips_and_updates_outlined,
                text: 'Detail Pekerjaan',
              ),
              const SizedBox(height: 8),
              Text(
                service.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if ((service.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '${service.description}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              WorkTwoCol(
                leftTitle: 'Kategori',
                leftValue: service.categoryName ??
                    (service.items?.isNotEmpty == true
                        ? (service.items!.first.serviceTypeName ?? '-')
                        : '-'),
                rightTitle: 'Est. Waktu',
                rightValue: formatEstWaktu(service.estimatedTime),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // MEKANIK
        WorkDetailPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WorkSectionTitle(
                icon: Icons.engineering_outlined,
                text: 'Mekanik yang Menangani',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service.mechanicName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: aksi hubungi mekanik (telp / chat)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEDE9FE),
                      foregroundColor: const Color(0xFF7C3AED),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text('Hubungi'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // JADWAL
        WorkDetailPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WorkSectionTitle(
                icon: Icons.event_outlined,
                text: 'Jadwal Pengerjaan',
              ),
              const SizedBox(height: 10),
              WorkTile(
                label: 'Tanggal',
                value: formatDate(service.scheduledDate),
              ),
              WorkTile(
                label: 'Waktu mulai',
                value: formatTime(service.scheduledDate),
              ),
              WorkTile(
                label: 'Est. Selesai',
                value: formatTime(service.estimatedTime),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // SPAREPART
        WorkDetailPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WorkSectionTitle(
                icon: Icons.shopping_cart_outlined,
                text: 'Sparepart yang digunakan',
              ),
              const SizedBox(height: 8),
              if ((service.items ?? const []).isEmpty)
                const Text(
                  'Belum ada item',
                  style: TextStyle(color: Colors.black45),
                )
              else
                ...service.items!.map((e) => WorkPartRow(item: e)),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // CATATAN
        WorkDetailPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WorkSectionTitle(
                icon: Icons.note_alt_outlined,
                text: 'Catatan Penting',
              ),
              const SizedBox(height: 8),
              WorkNote(text: service.note ?? 'Tidak ada catatan'),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // RINCIAN BIAYA
        WorkCostCard(parts: _partsTotal, labor: _labor, total: _grand),
      ],
    );
  }
}
