import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceServiceList extends StatelessWidget {
  final List<Map<String, dynamic>> serviceList;
  final List<String> jenisOptions;
  final Color mainColor;
  final VoidCallback onAdd;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final Function(int, String) onJenisChanged;

  const InvoiceServiceList({
    super.key,
    required this.serviceList,
    required this.jenisOptions,
    required this.mainColor,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onJenisChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Input Servis Form",
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            InkWell(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: mainColor, borderRadius: BorderRadius.circular(8)),
                child: SvgPicture.asset('assets/icons/plus.svg',
                    width: 16,
                    height: 16,
                    colorFilter:
                        const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text("Nama Servis / Jenis / Harga",
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black87)),
        const SizedBox(height: 10),
        Column(
          children: List.generate(serviceList.length, (index) {
            final item = serviceList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: _ServiceRow(
                item: item,
                index: index,
                jenisOptions: jenisOptions,
                mainColor: mainColor,
                onEdit: () => onEdit(index),
                onDelete: () => onDelete(index),
                onJenisChanged: (value) => onJenisChanged(index, value),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final List<String> jenisOptions;
  final Color mainColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Function(String) onJenisChanged;

  const _ServiceRow({
    required this.item,
    required this.index,
    required this.jenisOptions,
    required this.mainColor,
    required this.onEdit,
    required this.onDelete,
    required this.onJenisChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Nama Servis
        Expanded(
          flex: 38,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: mainColor, width: 1.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              item['nama'].isEmpty ? "Isi nama servis..." : item['nama'],
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600, color: mainColor),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Jenis
        Expanded(
          flex: 30,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: mainColor, width: 1.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: item['jenis'],
                icon: SvgPicture.asset(
                  'assets/icons/dropdown.svg',
                  width: 16,
                  height: 16,
                ),
                items: jenisOptions
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: GoogleFonts.poppins(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => onJenisChanged(v!),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Harga
        Expanded(
          flex: 32,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: mainColor, width: 1.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              "Rp. ${item['harga']}",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Tombol Aksi
        Row(
          children: [
            InkWell(
              onTap: onDelete,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  'assets/icons/delete.svg',
                  colorFilter:
                      const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 48,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  'assets/icons/edit.svg',
                  colorFilter:
                      const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
