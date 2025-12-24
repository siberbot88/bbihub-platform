import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Midtrans Payment WebView
/// Opens Midtrans Snap payment page and handles callbacks
class MidtransPaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final String snapToken;

  const MidtransPaymentWebView({
    Key? key,
    required this.paymentUrl,
    required this.snapToken,
  }) : super(key: key);

  @override
  State<MidtransPaymentWebView> createState() => _MidtransPaymentWebViewState();
}

class _MidtransPaymentWebViewState extends State<MidtransPaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    debugPrint('Initializing WebView with URL: ${widget.paymentUrl}');
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('🌐 WebView started loading: $url');
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            debugPrint('✅ WebView finished loading: $url');
            setState(() => _isLoading = false);
            _checkPaymentStatus(url);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebView error: ${error.description}');
            debugPrint('❌ Error code: ${error.errorCode}');
            debugPrint('❌ Error type: ${error.errorType}');
            
            // Show error to user
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error loading payment: ${error.description}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('📍 Navigation request: ${request.url}');
            // Allow all navigation within WebView
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentStatus(String url) {
    debugPrint('Checking payment status from URL: $url');
    
    // Midtrans callback URLs typically contain status
    if (url.contains('status_code=200') || 
        url.contains('transaction_status=settlement') ||
        url.contains('transaction_status=capture')) {
      debugPrint('✅ Payment successful!');
      Navigator.pop(context, 'success');
    } else if (url.contains('status_code=201')) {
      debugPrint('⏳ Payment pending');
      Navigator.pop(context, 'pending');
    } else if (url.contains('transaction_status=deny') ||
               url.contains('transaction_status=cancel') ||
               url.contains('transaction_status=expire')) {
      debugPrint('❌ Payment failed/cancelled');
      Navigator.pop(context, 'error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Trial'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            debugPrint('User cancelled payment');
            Navigator.pop(context, 'cancelled');
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading payment page...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
