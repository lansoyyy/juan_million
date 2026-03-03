import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:juan_million/utlis/colors.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DragonPayWebView extends StatefulWidget {
  final String txnId;
  final String amount; // e.g. "100.00"
  final String currency; // e.g. "PHP"
  final String description;
  final String email;

  const DragonPayWebView({
    super.key,
    required this.txnId,
    required this.amount,
    this.currency = 'PHP',
    required this.description,
    required this.email,
  });

  @override
  State<DragonPayWebView> createState() => _DragonPayWebViewState();
}

class _DragonPayWebViewState extends State<DragonPayWebView> {
  late final WebViewController _controller;
  late final Uri _paymentUrl;
  bool _isLoading = true;

  // Web platform: polling payment status
  Timer? _pollingTimer;
  bool _paymentLaunched = false;
  String _statusMessage =
      'Opening payment page in a new tab.\nComplete your payment then return here.';

  @override
  void initState() {
    super.initState();

    final merchantId = 'JUAN4ALL'.trim();
    final password = 'e28b2d43b2cdb2b793ddabc15dd2d505cdd35e51'.trim();
    final toSign =
        '$merchantId:${widget.txnId}:${widget.amount}:${widget.currency}:${widget.description}:${widget.email}:$password';
    final digest = sha1.convert(utf8.encode(toSign)).toString();

    _paymentUrl = Uri.parse(
        'https://test.dragonpay.ph/Pay.aspx?merchantid=$merchantId'
        '&txnid=${widget.txnId}'
        '&amount=${widget.amount}'
        '&ccy=${widget.currency}'
        '&description=${Uri.encodeComponent(widget.description)}'
        '&email=${Uri.encodeComponent(widget.email)}'
        '&digest=$digest');

    if (!kIsWeb) {
      // Native: use WebView widget (initialized here, not in build)
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.contains('juanmillion://payment')) {
                final uri = Uri.parse(request.url);
                final status = uri.queryParameters['status'];
                if (mounted) Navigator.pop(context, status == 'S');
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Error loading payment page: ${error.description}'),
                  ),
                );
              }
            },
          ),
        )
        ..loadRequest(_paymentUrl);
    } else {
      // Web: open URL in browser + poll Firestore for status
      _launchWebPayment();
    }
  }

  Future<void> _launchWebPayment() async {
    try {
      final launched =
          await launchUrl(_paymentUrl, mode: LaunchMode.externalApplication);
      if (mounted) {
        setState(() {
          _paymentLaunched = launched;
          _statusMessage = launched
              ? 'Payment page opened in a new browser tab.\nComplete your payment then return here.'
              : 'Could not open payment page automatically.\nTap "Open Payment" below to try again.';
        });
      }
      if (launched) _startPolling();
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage =
              'Could not open payment page.\nTap "Open Payment" below to try again.';
        });
      }
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('Payments')
            .doc(widget.txnId)
            .get();
        if (!doc.exists || !mounted) return;
        final status = doc.data()?['status'] as String?;
        if (status != null && status != 'Pending') {
          timer.cancel();
          if (mounted) Navigator.pop(context, status == 'Successful');
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ── Web platform build ──────────────────────────────────────────────────
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, false),
          ),
          title: TextWidget(
            text: 'Payment',
            fontSize: 20,
            fontFamily: 'Bold',
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _paymentLaunched
                      ? Icons.open_in_browser
                      : Icons.payment_rounded,
                  size: 80,
                  color: primary,
                ),
                const SizedBox(height: 24),
                TextWidget(
                  text: _statusMessage,
                  fontSize: 16,
                  maxLines: 5,
                  color: Colors.black87,
                  fontFamily: 'Medium',
                ),
                const SizedBox(height: 30),
                if (_paymentLaunched) ...[
                  CircularProgressIndicator(color: primary),
                  const SizedBox(height: 12),
                  TextWidget(
                    text: 'Checking payment status automatically...',
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'Regular',
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primary),
                        onPressed: _launchWebPayment,
                        icon: const Icon(Icons.open_in_new,
                            color: Colors.white),
                        label: TextWidget(
                          text: 'Re-open Payment',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: primary),
                    onPressed: _launchWebPayment,
                    icon:
                        const Icon(Icons.open_in_new, color: Colors.white),
                    label: TextWidget(
                      text: 'Open Payment',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // ── Native platform build ───────────────────────────────────────────────
    return Scaffold(
      appBar: AppBar(
        title: TextWidget(
          text: 'Payment',
          fontSize: 24,
          fontFamily: 'Bold',
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
