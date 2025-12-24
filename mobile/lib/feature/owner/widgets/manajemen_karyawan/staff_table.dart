import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';
import 'staff_helpers.dart';

class StaffTable extends StatelessWidget {
  const StaffTable({
    super.key,
    required this.rows,
    required this.headerController,
    required this.bodyHController,
    required this.bodyVController,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Employment> rows;

  final ScrollController headerController;
  final ScrollController bodyHController;
  final ScrollController bodyVController;

  final Future<void> Function(Employment, bool) onToggleActive;
  final Future<void> Function(Employment) onEdit;
  final Future<void> Function(Employment) onDelete;

  static const double wAvatar = 64; // kolom foto
  static const double wName = 220;
  static const double wPos = 180;
  static const double wEmail = 240;
  static const double wStatus = 140;
  static const double wActions = 120;

  static const double rowHeight = 64;

  static double get totalWidth => wAvatar + wName + wPos + wEmail + wStatus + wActions;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(10), // radius kecil
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // radius kecil
          border: Border.all(color: const Color(0xFFE6EAF0)),
        ),
        child: Column(
          children: [
            // Header
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Container(
                color: const Color(0xFFF9FAFB),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SingleChildScrollView(
                  controller: headerController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: max(totalWidth, MediaQuery.of(context).size.width - 32),
                    child: Row(
                      children: [
                        // Icon saja agar tidak overflow (hilangin tulisan Photo)
                        _headerCell(
                          width: wAvatar,
                          child: const Icon(Icons.person, size: 18, color: Color(0xFF475467)),
                        ),
                        _headerCell(width: wName, label: 'NAME'),
                        _headerCell(width: wPos, label: 'Position'),
                        _headerCell(width: wEmail, label: 'E-Mail'),
                        _headerCell(width: wStatus, label: 'Status'),
                        _headerCell(width: wActions, label: ''),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 1),

            // Body (dibikin lebih tinggi)
            SizedBox(
              height: min(680.0, MediaQuery.of(context).size.height * 0.72),
              child: Scrollbar(
                controller: bodyVController,
                radius: const Radius.circular(10),
                thickness: 6,
                child: SingleChildScrollView(
                  controller: bodyHController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(
                    width: max(totalWidth, MediaQuery.of(context).size.width - 32),
                    child: ListView.separated(
                      controller: bodyVController,
                      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      itemBuilder: (context, i) {
                        final e = rows[i];
                        return StaffRow(
                          data: e,
                          onToggleActive: (v) => onToggleActive(e, v),
                          onEdit: () => onEdit(e),
                          onDelete: () => onDelete(e),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: rows.length,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell({required double width, String? label, Widget? child}) {
    const style = TextStyle(
      fontSize: 12,
      color: Color(0xFF475467),
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: child ?? Text(label ?? '', style: style),
        ),
      ),
    );
  }
}

class StaffRow extends StatelessWidget {
  const StaffRow({
    super.key,
    required this.data,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final Employment data;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const double wAvatar = StaffTable.wAvatar;
  static const double wName = StaffTable.wName;
  static const double wPos = StaffTable.wPos;
  static const double wEmail = StaffTable.wEmail;
  static const double wStatus = StaffTable.wStatus;
  static const double wActions = StaffTable.wActions;

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;

    return SizedBox(
      height: StaffTable.rowHeight,
      child: Row(
        children: [
          // AVATAR
          SizedBox(
            width: wAvatar,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: staffAvatarBg(data.name),
                child: Text(
                  staffInitials(data.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          // NAME (tanpa kotak ungu)
          SizedBox(
            width: wName,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE6EAF0)),
                  borderRadius: BorderRadius.circular(8), // lebih kotak
                ),
                child: Text(
                  data.name.isEmpty ? '-' : data.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ts.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          // POSITION
          SizedBox(
            width: wPos,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                data.role.isEmpty ? '-' : data.role,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ts.bodyMedium?.copyWith(
                  color: const Color(0xFF344054),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // EMAIL
          SizedBox(
            width: wEmail,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                data.email.isEmpty ? '-' : data.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ts.bodyMedium?.copyWith(color: const Color(0xFF344054)),
              ),
            ),
          ),
          // STATUS
          SizedBox(
            width: wStatus,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: StaffStatusPill(active: data.isActive),
                    ),
                  ),
                  Switch.adaptive(
                    value: data.isActive,
                    onChanged: onToggleActive,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeTrackColor: const Color(0xFF16A34A),
                  ),
                ],
              ),
            ),
          ),
          // ACTIONS
          SizedBox(
            width: wActions,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Edit',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StaffStatusPill extends StatelessWidget {
  const StaffStatusPill({super.key, required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9);
    final textColor = active ? const Color(0xFF166534) : const Color(0xFF475467);
    final label = active ? 'Active' : 'Inactive';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6EAF0)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600)),
    );
  }
}
