import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:juan_million/widgets/text_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DragonPayWebView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final merchantId = 'JUAN4ALL'.trim();
    final password = 'e28b2d43b2cdb2b793ddabc15dd2d505cdd35e51'.trim();

    final toSign =
        '$merchantId:$txnId:$amount:$currency:$description:$email:$password';
    final digest = sha1.convert(utf8.encode(toSign)).toString();

    final url = Uri.parse(
        'https://test.dragonpay.ph/Pay.aspx?merchantid=$merchantId'
        '&txnid=$txnId'
        '&amount=$amount'
        '&ccy=$currency'
        '&description=${Uri.encodeComponent(description)}'
        '&email=${Uri.encodeComponent(email)}'
        '&digest=$digest');

    return Scaffold(
      appBar: AppBar(
        title: TextWidget(
          text: 'Payment',
          fontSize: 24,
          fontFamily: 'Bold',
        ),
        centerTitle: true,
      ),
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
