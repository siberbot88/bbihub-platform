import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';
import '../widgets/invoice/invoice_customer_header.dart';
import '../widgets/invoice/invoice_service_info.dart';
import '../widgets/invoice/invoice_service_list.dart';
import 'invoice_payment.dart';

class InvoiceFormPage extends StatefulWidget {
  final Map<String, dynamic>? task;

  const InvoiceFormPage({super.key, this.task});

  @override
  State<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends State<InvoiceFormPage> {
  final Color mainColor = const Color(0xFFDC2626);
  final TextEditingController technicianNoteController =
      TextEditingController();

  final List<Map<String, dynamic>> serviceList = [
    {"nama": "Servis besar", "jenis": "Jasa Pekerjaan", "harga": 450000},
    {"nama": "Ganti Kampas rem", "jenis": "Sparepart", "harga": 250000},
    {"nama": "Ganti Ban Belakang", "jenis": "Sparepart", "harga": 380000},
  ];

  final List<String> jenisOptions = [
    "Jasa Pekerjaan",
    "Sparepart",
    "Biaya Tambahan",
    "Lainnya (PPN, dll)"
  ];

  void _addService() {
    setState(() {
      serviceList.add({"nama": "", "jenis": "Jasa Pekerjaan", "harga": 0});
    });
  }

  void _editService(int index) {
    final namaController =
        TextEditingController(text: serviceList[index]["nama"]);
    final hargaController =
        TextEditingController(text: serviceList[index]["harga"].toString());
    String selectedJenis = serviceList[index]["jenis"];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Servis",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: const InputDecoration(labelText: "Nama Servis"),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedJenis,
              decoration: const InputDecoration(labelText: "Jenis Servis"),
              items: jenisOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) => selectedJenis = value!,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: hargaController,
              decoration: const InputDecoration(labelText: "Harga Servis"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          TextButton(
            onPressed: () {
              setState(() {
                serviceList[index]["nama"] = namaController.text;
                serviceList[index]["jenis"] = selectedJenis;
                serviceList[index]["harga"] =
                    int.tryParse(hargaController.text) ?? 0;
              });
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _deleteService(int index) {
    setState(() => serviceList.removeAt(index));
  }

  void _onJenisChanged(int index, String value) {
    setState(() {
      serviceList[index]['jenis'] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(title: "Invoice Form", showBack: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InvoiceCustomerHeader(task: task),
                  const SizedBox(height: 18),
                  Center(
                    child: Text("Informasi Servis",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  InvoiceServiceInfo(task: task, mainColor: mainColor),
                  const SizedBox(height: 18),
                  InvoiceServiceList(
                    serviceList: serviceList,
                    jenisOptions: jenisOptions,
                    mainColor: mainColor,
                    onAdd: _addService,
                    onEdit: _editService,
                    onDelete: _deleteService,
                    onJenisChanged: _onJenisChanged,
                  ),
                  const SizedBox(height: 16),
                  Text("Catatan Teknisi",
                      style: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: technicianNoteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Masukkan catatan teknisi...",
                      hintStyle: GoogleFonts.poppins(fontSize: 13),
                      contentPadding: const EdgeInsets.all(10),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: mainColor, width: 1.2)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              BorderSide(color: mainColor, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                      ),
                      child: Text("Batalkan",
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PaymentInvoicePage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        elevation: 4,
                      ),
                      child: Text("Lanjutkan",
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
