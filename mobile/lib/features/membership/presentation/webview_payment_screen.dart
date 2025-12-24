import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class WebviewPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String title;

  const WebviewPaymentScreen({
    super.key,
    required this.paymentUrl,
    this.title = 'Pembayaran',
  });

  @override
  State<WebviewPaymentScreen> createState() => _WebviewPaymentScreenState();
}

class _WebviewPaymentScreenState extends State<WebviewPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _pageTitle = '';

  @override
  void initState() {
    super.initState();
    _pageTitle = widget.title;
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();
            // Check for success/finish indicators from Midtrans
            if (url.contains('finish') || 
                url.contains('example.com') || 
                url.contains('transaction_status=settlement') || 
                url.contains('transaction_status=pending') ||
                url.contains('transaction_status=capture')) {
                  
              // Close WebView and return success
              Navigator.of(context).pop(true); 
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_pageTitle),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(), // Close as cancelled/unknown
        ),
        actions: [
           TextButton(
             onPressed: () => Navigator.of(context).pop(true), // Close as success manual
             child: const Text('Selesai', style: TextStyle(color: AppColors.primaryRed, fontWeight: FontWeight.bold)),
           )
        ],
        titleTextStyle: AppTextStyles.heading4(color: Colors.black),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primaryRed),
            ),
        ],
      ),
    );
  }
}
