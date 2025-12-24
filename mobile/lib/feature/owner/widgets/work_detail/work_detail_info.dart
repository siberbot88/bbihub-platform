import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/models/vehicle.dart';
import 'work_detail_helpers.dart';

const _gradStart = Color(0xFF9B0D0D);
const _gradEnd = Color(0xFFB70F0F);

class WorkTwoCol extends StatelessWidget {
  final String leftTitle, leftValue, rightTitle, rightValue;
  const WorkTwoCol({
    super.key,
    required this.leftTitle,
    required this.leftValue,
    required this.rightTitle,
    required this.rightValue,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle label = const TextStyle(color: Colors.black45, fontSize: 12);
    TextStyle value = const TextStyle(fontWeight: FontWeight.w700);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leftTitle, style: label),
              const SizedBox(height: 4),
              Text(leftValue, style: value),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rightTitle, style: label),
              const SizedBox(height: 4),
              Text(rightValue, style: value),
            ],
          ),
        ),
      ],
    );
  }
}

class WorkTile extends StatelessWidget {
  final String label, value;
  const WorkTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class WorkVehicleCard extends StatelessWidget {
  final Vehicle? vehicle;
  const WorkVehicleCard({super.key, required this.vehicle});

  String _nonEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? '-' : v.trim();

  @override
  Widget build(BuildContext context) {
    final v = vehicle;

    final brand = _nonEmpty(v?.brand);
    final model = _nonEmpty(v?.model);
    final year = _nonEmpty(v?.year?.toString());

    final titleParts = <String>[];
    if (brand != '-') titleParts.add(brand);
    if (model != '-') titleParts.add(model);
    if (year != '-') titleParts.add(year);
    final title = titleParts.isEmpty ? '-' : titleParts.join(' ');

    final plate = _nonEmpty(v?.plateNumber);
    final color = _nonEmpty(v?.color);
    final odo = _nonEmpty(v?.odometer?.toString());

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
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: const [
              Icon(Icons.directions_car, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Informasi Kendaraan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ]),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(31),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Plat: $plate',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(children: [
              WorkKV(title: 'Tahun', value: year),
              WorkKV(title: 'Warna', value: color),
              WorkKV(title: 'Odometer', value: odo),
            ]),
          ],
        ),
      ),
    );
  }
}

class WorkKV extends StatelessWidget {
  final String title, value;
  const WorkKV({super.key, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(31),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ]),
      ),
    );
  }
}

class WorkDot extends StatelessWidget {
  final Color color;
  const WorkDot({super.key, required this.color});
  @override
  Widget build(BuildContext context) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class WorkNote extends StatelessWidget {
  final String text;
  const WorkNote({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sticky_note_2_outlined, color: Colors.black45),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
          const SizedBox(width: 6),
          Text(
            formatTimeNow(),
            style: const TextStyle(color: Colors.black38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
