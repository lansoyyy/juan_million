import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DragonPayWebView extends StatelessWidget {
  const DragonPayWebView({super.key});

  @override
  Widget build(BuildContext context) {
    final merchantId = 'JUAN4ALL'.trim();
    final password = 'e28b2d43b2cdb2b793ddabc15dd2d505cdd35e51'.trim();

    final txnId = 'TXN${DateTime.now().millisecondsSinceEpoch}';
    final amount = '100.00';
    final currency = 'PHP';
    final description = 'Payment for JUAN4ALL';
    final email = 'olanalans12345@gmail.com';

    final toSign =
        '$merchantId:$txnId:$amount:$currency:$description:$email:$password';
    final digest = sha1.convert(utf8.encode(toSign)).toString();

    final url =
        Uri.parse('https://test.dragonpay.ph/Pay.aspx?merchantid=$merchantId'
            '&txnid=$txnId'
            '&amount=$amount'
            '&ccy=$currency'
            '&description=${Uri.encodeComponent(description)}'
            '&email=${Uri.encodeComponent(email)}'
            '&digest=$digest');

    return Scaffold(
      appBar: AppBar(title: const Text("DragonPay Payment")),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (NavigationRequest request) {
                if (request.url.contains('juanmillion://payment')) {
                  final uri = Uri.parse(request.url);
                  final status = uri.queryParameters['status'];
                  Navigator.pop(context, status == 'S');
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              onPageStarted: (String url) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Loading payment page...')),
                );
              },
              onPageFinished: (String url) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              onWebResourceError: (WebResourceError error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Error loading payment page: ${error.description}')),
                );
              },
            ),
          )
          ..loadRequest(url),
      ),
    );
  }
}
