import 'package:flutter/material.dart';
import 'work_helpers.dart';

class WorkFilterSheet extends StatefulWidget {
  final AdvancedFilter currentFilter;
  final Function(AdvancedFilter) onApply;

  const WorkFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<WorkFilterSheet> createState() => _WorkFilterSheetState();
}

class _WorkFilterSheetState extends State<WorkFilterSheet> {
  late String? tempType;
  late String? tempCat;
  late String tempSort;

  @override
  void initState() {
    super.initState();
    tempType = widget.currentFilter.vehicleType;
    tempCat = widget.currentFilter.vehicleCategory;
    tempSort = widget.currentFilter.sort;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Text(
            'Filter Pekerjaan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          const Text('Jenis Kendaraan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildTypeChip('Semua', ''),
              _buildTypeChip('Mobil', 'mobil'),
              _buildTypeChip('Motor', 'motor'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Kategori Kendaraan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildCatChip('Matic', 'matic'),
              _buildCatChip('Sport', 'sport'),
              _buildCatChip('Bebek', 'bebek'),
              _buildCatChip('SUV', 'suv'),
              _buildCatChip('MPV', 'mpv'),
              _buildCatChip('Hatchback', 'hatchback'),
              _buildCatChip('Sedan', 'sedan'),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Urutkan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSortChip('Terbaru', 'newest'),
              _buildSortChip('Terlama', 'oldest'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.onApply(AdvancedFilter.empty);
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                  ),
                  onPressed: () {
                    final typeValue = (tempType ?? '').isEmpty ? null : tempType;
                    final catValue = (tempCat ?? '').isEmpty ? null : tempCat;
                    widget.onApply(AdvancedFilter(
                      vehicleType: typeValue,
                      vehicleCategory: catValue,
                      sort: tempSort,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Terapkan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, String value) {
    final sel = tempType == value;
    return ChoiceChip(
      label: Text(label),
      selected: sel,
      onSelected: (v) {
        setState(() {
          tempType = v ? value : null;
          if (tempType == null) tempCat = null;
        });
      },
    );
  }

  Widget _buildCatChip(String label, String value) {
    final sel = tempCat == value;
    return ChoiceChip(
      label: Text(label),
      selected: sel,
      onSelected: (v) {
        setState(() {
          tempCat = v ? value : null;
        });
      },
    );
  }

  Widget _buildSortChip(String label, String value) {
    final sel = tempSort == value;
    return ChoiceChip(
      label: Text(label),
      selected: sel,
      onSelected: (v) {
        setState(() {
          tempSort = v ? value : 'none';
        });
      },
    );
  }
}
