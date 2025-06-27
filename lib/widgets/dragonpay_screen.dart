import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DragonPayWebView extends StatelessWidget {
  const DragonPayWebView({super.key});

  @override
  Widget build(BuildContext context) {
    final merchantId = 'JUAN4ALL'.trim(); // <-- Must match Dragonpay
    final password = 'e28b2d43b2cdb2b793ddabc15dd2d505cdd35e51'
        .trim(); // <-- Check this carefully

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

    print('toSign: $toSign');
    print('digest: $digest');
    print('url: $url');

    return Scaffold(
      appBar: AppBar(title: const Text("DragonPay Payment")),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(url),
      ),
    );
  }
}
