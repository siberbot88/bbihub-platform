import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bengkel_online_flutter/feature/admin/providers/admin_service_provider.dart';
import 'package:bengkel_online_flutter/feature/owner/providers/employee_provider.dart';
import 'package:bengkel_online_flutter/core/models/employment.dart';

/// 🔹 Popup pertama: pilih teknisi
void showTechnicianSelectDialog(
  BuildContext context, {
  required Function(String mechanicUuid, String mechanicName) onConfirm,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: TechnicianSelectContent(onConfirm: onConfirm),
        ),
      );
    },
  );
}

class TechnicianSelectContent extends StatefulWidget {
  final Function(String, String) onConfirm;

  const TechnicianSelectContent({super.key, required this.onConfirm});

  @override
  State<TechnicianSelectContent> createState() => _TechnicianSelectContentState();
}

class _TechnicianSelectContentState extends State<TechnicianSelectContent> {
  String? selectedTechnicianUuid;
  String selectedTechnicianName = "";
  List<Employment> mechanics = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchMechanics();
  }

  Future<void> _fetchMechanics() async {
    try {
      final employeeProvider = context.read<EmployeeProvider>();
      await employeeProvider.fetchOwnerEmployees(page: 1);
      final employees = employeeProvider.items;
      
      // Filter for mechanics if role is available, otherwise show all or filter by jobdesk/specialist
      // For now, let's assume all employees can be assigned or filter if role contains 'mechanic' or 'teknisi'
      setState(() {
        mechanics = employees.where((e) {
             final r = e.role.toLowerCase();
             final j = (e.jobdesk ?? '').toLowerCase();
             return r.contains('mechanic') || r.contains('teknisi') || r.contains('mekanik') || 
                    j.contains('mechanic') || j.contains('teknisi') || j.contains('mekanik');
        }).toList();
        
        // Fallback: if empty, maybe roles are not set correctly, show all for debugging?
        // Or keep empty.
        if (mechanics.isEmpty && employees.isNotEmpty) {
             // Debug fallback: show all if strict filter has 0 results but we have employees
             // This helps if role naming isn't exactly 'mechanic'
             mechanics = employees;
        }
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const mainColor = Color(0xFFDC2626);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            "Tetapkan Mekanik",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          "Pilih Teknisi untuk servis ini",
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        const SizedBox(height: 6),

        if (loading)
           const Center(child: Padding(
             padding: EdgeInsets.all(8.0),
             child: CircularProgressIndicator(),
           ))
        else if (error != null)
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Text("Error: $error", style: TextStyle(color: Colors.red)),
           )
        else if (mechanics.isEmpty)
           Padding(
             padding: const EdgeInsets.all(8.0),
             child: Text("Tidak ada teknisi tersedia.", style: TextStyle(color: Colors.grey)),
           )
        else
          DropdownButtonFormField<String>(
            value: selectedTechnicianUuid,
            items: mechanics.map((e) {
              return DropdownMenuItem(
                value: e.userUuid, // Using userUuid as mechanic identifier
                child: Text(
                  e.name,
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                selectedTechnicianUuid = val;
                selectedTechnicianName = mechanics.firstWhere((e) => e.userUuid == val).name;
              });
            },
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              hintText: "Pilih Teknisi",
              hintStyle: GoogleFonts.poppins(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: mainColor, width: 2),
              ),
            ),
          ),

        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: Colors.grey.shade400,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  "Batalkan",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: selectedTechnicianUuid == null
                    ? null
                    : () {
                        Navigator.pop(context); // close first dialog
                        showAssignConfirmDialog(
                          context,
                          selectedTechnicianName,
                          onConfirm: () => widget.onConfirm(selectedTechnicianUuid!, selectedTechnicianName),
                        ); 
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Lanjutkan",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 🔹 Popup kedua: konfirmasi assign teknisi
void showAssignConfirmDialog(
  BuildContext context, 
  String technician, {
  required VoidCallback onConfirm,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.grey[200], // warna latar belakang dialog
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.engineering, size: 50, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                "Apakah anda yakin untuk assign teknisi\n$technician pada service ini?",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Tombol Batal
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Batalkan",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tombol Yakin
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // tutup popup konfirmasi
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB70F0F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Yakin",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
}
