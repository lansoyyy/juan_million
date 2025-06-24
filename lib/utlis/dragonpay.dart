import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:url_launcher/url_launcher.dart';

void launchDragonpayPayment() async {
  const merchantId = 'JUAN4ALL';
  const password = 'uEo3VuyhPB94BFF';
  const txnId = 'TXN123456';
  const amount = '100.00';
  const currency = 'PHP';
  const description = 'Payment for Zippy';
  const email = 'olanalans12345@gmail.com';

  const toSign =
      '$merchantId:$txnId:$amount:$currency:$description:$email:$password';
  final bytes = utf8.encode(toSign);
  final digest = sha1.convert(bytes).toString();

  final url =
      'https://test.dragonpay.ph/Pay.aspx?merchantid=$merchantId&txnid=$txnId&amount=$amount&ccy=$currency&description=${Uri.encodeComponent(description)}&email=$email&digest=$digest';

  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch Dragonpay URL';
  }
}
