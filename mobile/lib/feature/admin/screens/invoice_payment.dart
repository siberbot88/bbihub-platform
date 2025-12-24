import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_header.dart';
import '../widgets/invoice/payment_invoice_card.dart';

class PaymentInvoicePage extends StatefulWidget {
  const PaymentInvoicePage({super.key});

  @override
  State<PaymentInvoicePage> createState() => _PaymentInvoicePageState();
}

class _PaymentInvoicePageState extends State<PaymentInvoicePage> {
  bool _sent = false;

  void _sendInvoice() {
    setState(() => _sent = true);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 12),
        elevation: 0,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 2),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26), // 0.10 * 255
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Invoice berhasil dikirimkan',
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomHeader(
        title: 'Nota Pembayaran',
        showBack: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB31217), Color(0xFFE52D27)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: PaymentInvoiceCard(
                    vehicleName: 'BEAT 2012',
                    invoiceNumber: 'PR26051420004799',
                    licensePlate: 'SU814NTO',
                    phoneNumber: '08956733xxx',
                    serviceItems: const [
                      {'name': 'Servis besar', 'price': '450000'},
                      {'name': 'Ganti kampas rem', 'price': '250000'},
                      {'name': 'Ganti Ban belakang', 'price': '380000'},
                    ],
                    totalAmount: 'IDR.1,080K',
                    notes:
                        'Perlu perawatan dan pengecheckan rutinan\nsetiap 3 bulan sekali kedepannya',
                    customerName: 'Prabowo',
                    customerAddress:
                        'Jl. Krestal No.32 Torjun, Sampang\nJawa Timur',
                    totalTagihan: 'IDR. 1,080K',
                    invoiceDate: 'SEP 4, 2026',
                    isSent: _sent,
                    onSend: _sendInvoice,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}