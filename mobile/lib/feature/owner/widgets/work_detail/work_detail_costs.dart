import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/models/transaction_item.dart';
import 'work_detail_helpers.dart';

const _gradStart = Color(0xFF9B0D0D);
const _gradEnd = Color(0xFFB70F0F);

class WorkPartRow extends StatelessWidget {
  final TransactionItem item;
  const WorkPartRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final name = item.name ?? item.serviceTypeName ?? 'Item';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  'Qty: ${item.quantity}  @ ${formatRupiah(item.price)}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            formatRupiah(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class WorkCostCard extends StatelessWidget {
  final num parts, labor, total;
  const WorkCostCard({
    super.key,
    required this.parts,
    required this.labor,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_gradStart, _gradEnd]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Rincian Biaya',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            WorkRowCost(
                label: 'Biaya sparepart',
                value: formatRupiah(parts),
                bold: false),
            WorkRowCost(
                label: 'Biaya  jasa', value: formatRupiah(labor), bold: false),
            const Divider(color: Colors.white24),
            WorkRowCost(
                label: 'Subtotal', value: formatRupiah(total), bold: false),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(31),
                borderRadius: BorderRadius.circular(10),
              ),
              child: WorkRowCost(
                  label: 'Total Biaya',
                  value: formatRupiah(total),
                  bold: true),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkRowCost extends StatelessWidget {
  final String label, value;
  final bool bold;
  const WorkRowCost({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(color: Colors.white.withAlpha(230)),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
        ),
      ),
    ]);
  }
}
