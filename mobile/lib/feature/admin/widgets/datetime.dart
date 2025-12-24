import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DateRangeField extends StatefulWidget {
  final TextEditingController startController;
  final TextEditingController endController;
  final Color primaryColor;
  final IconData icon;

  const DateRangeField({
    super.key,
    required this.startController,
    required this.endController,
    required this.primaryColor,
    this.icon = Icons.calendar_today,
  });

  @override
  State<DateRangeField> createState() => _DateRangeFieldState();
}

class _DateRangeFieldState extends State<DateRangeField> {
  Future<void> _selectDateRange() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: SizedBox(
            height: 350,
            width: 350,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              showActionButtons: true,
              onCancel: () => Navigator.pop(context),
              onSubmit: (Object? val) {
                if (val is PickerDateRange) {
                  final DateTime? start = val.startDate;
                  final DateTime? end = val.endDate;

                  if (start != null) {
                    widget.startController.text =
                        DateFormat("dd-MM-yyyy").format(start);
                  }
                  if (end != null) {
                    widget.endController.text =
                        DateFormat("dd-MM-yyyy").format(end);
                  }
                }
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: _selectDateRange,
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          style: GoogleFonts.poppins(color: widget.primaryColor),
          validator: (value) =>
              value == null || value.isEmpty ? "$label wajib diisi" : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: "Pilih $label",
            labelStyle: GoogleFonts.poppins(color: widget.primaryColor),
            hintStyle: GoogleFonts.poppins(color: Colors.grey),
            prefixIcon: Icon(widget.icon, color: widget.primaryColor),

            // ✅ Konsisten sama _buildTextField
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.primaryColor, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.primaryColor),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            errorStyle: GoogleFonts.poppins(
              color: Colors.red,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildField("Waktu Mulai", widget.startController),
        const SizedBox(height: 16),
        _buildField("Waktu Berakhir", widget.endController),
      ],
    );
  }
}
